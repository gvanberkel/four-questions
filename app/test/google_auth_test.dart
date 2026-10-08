import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:four_questions/auth/browser.dart';
import 'package:four_questions/auth/google_auth.dart';

class FakeBrowser implements Browser {
  FakeBrowser([String url = 'https://four.example.com/']) : location = Uri.parse(url);

  @override
  Uri location;
  Uri? navigatedTo;
  final session = <String, String>{};

  @override
  void replaceLocation(Uri uri) => location = uri;

  @override
  void navigateTo(Uri uri) => navigatedTo = uri;

  @override
  void openInNewTab(Uri uri) {}

  @override
  String? sessionValue(String key) => session[key];

  @override
  void setSessionValue(String key, String? value) =>
      value == null ? session.remove(key) : session[key] = value;

  final visible = StreamController<void>.broadcast();

  @override
  Stream<void> get onVisible => visible.stream;

  @override
  Stream<void> get onOnline => const Stream.empty();

  /// Google's answer, as it lands in the address bar.
  void returnFromGoogle(Map<String, String> params) => location = location
      .replace(fragment: Uri(queryParameters: params).query);
}

String idToken(Map<String, Object?> claims) {
  String part(Object json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  return '${part({'alg': 'RS256'})}.${part(claims)}.signature';
}

void main() {
  final now = DateTime(2026, 10, 8, 7, 30);
  late FakeBrowser browser;
  late GoogleAuth auth;

  setUp(() {
    browser = FakeBrowser();
    auth = GoogleAuth(
      browser: browser,
      clientId: 'client-123.apps.googleusercontent.com',
      now: () => now,
      random: Random(1),
    );
  });

  Map<String, String> sent() => browser.navigatedTo!.queryParameters;

  test('signing in goes to Google with the token flow and Sheets scope', () {
    auth.signIn(loginHint: 'greg@example.com');

    final url = browser.navigatedTo!;
    expect(url.host, 'accounts.google.com');
    expect(sent()['response_type'], 'token id_token');
    expect(sent()['redirect_uri'], 'https://four.example.com/');
    expect(sent()['scope']!.split(' '), contains(GoogleAuth.sheetsScope));
    expect(sent()['login_hint'], 'greg@example.com');
    expect(sent().containsKey('prompt'), isFalse);
  });

  test('a silent renewal asks Google to show nothing', () {
    auth.signIn(prompt: SignInPrompt.none, loginHint: 'greg@example.com');
    expect(sent()['prompt'], 'none');
  });

  test('a token is read from the address bar, which is then cleaned', () {
    auth.signIn();
    browser.returnFromGoogle({
      'access_token': 'ya29.token',
      'expires_in': '3599',
      'scope': 'email profile openid ${GoogleAuth.sheetsScope}',
      'state': sent()['state']!,
      'id_token': idToken({
        'email': 'greg@example.com',
        'name': 'Greg van Berkel',
        'given_name': 'Greg',
        'nonce': sent()['nonce'],
      }),
    });

    final result = auth.takeResult();

    expect(result, isA<SignedIn>());
    final signedIn = result! as SignedIn;
    expect(signedIn.account.email, 'greg@example.com');
    expect(signedIn.account.firstName, 'Greg');
    expect(signedIn.token.value, 'ya29.token');
    expect(signedIn.token.expiresAt, now.add(const Duration(seconds: 3599)));
    expect(browser.location.hasFragment, isFalse);
    expect(auth.takeResult(), isNull, reason: 'read once');
  });

  test('an answer this tab did not ask for is ignored', () {
    auth.signIn();
    browser.returnFromGoogle({
      'access_token': 'ya29.token',
      'state': 'someone-elses-state',
    });

    expect(auth.takeResult(), isA<SignInFailed>()
        .having((f) => f.reason, 'reason', SignInFailed.stale));
  });

  test('without the Sheets permission the sign-in does not count', () {
    auth.signIn();
    browser.returnFromGoogle({
      'access_token': 'ya29.token',
      'scope': 'email profile openid',
      'state': sent()['state']!,
    });

    expect(auth.takeResult(), isA<SignInFailed>().having(
        (f) => f.reason, 'reason', SignInFailed.sheetsNotGranted));
  });

  test('a silent renewal that needs the person says so', () {
    auth.signIn(prompt: SignInPrompt.none);
    browser.returnFromGoogle({
      'error': 'interaction_required',
      'state': sent()['state']!,
    });

    final failed = auth.takeResult()! as SignInFailed;
    expect(failed.silent, isTrue);
    expect(failed.reason, 'interaction_required');
  });

  test('an ID token for another request is refused', () {
    auth.signIn();
    browser.returnFromGoogle({
      'access_token': 'ya29.token',
      'scope': GoogleAuth.sheetsScope,
      'state': sent()['state']!,
      'id_token': idToken({'email': 'x@example.com', 'nonce': 'replayed'}),
    });

    expect(auth.takeResult(), isA<SignInFailed>());
  });
}
