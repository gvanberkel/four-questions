import 'dart:convert';
import 'dart:math';

import 'package:four_questions/auth/account.dart';
import 'package:four_questions/auth/browser.dart';

enum SignInPrompt {
  /// Straight back without showing anything; fails if Google would need to
  /// ask the person something.
  none,

  /// Google asks only what it must — consent the first time, an account when
  /// it cannot tell which.
  auto,

  /// Always show Google's account chooser.
  chooseAccount,
}

sealed class SignInResult {
  const SignInResult();
}

class SignedIn extends SignInResult {
  const SignedIn(this.account, this.token);
  final Account account;
  final AccessToken token;
}

class SignInFailed extends SignInResult {
  const SignInFailed(this.reason, {this.silent = false});

  /// Google's error code, or one of the app's below.
  final String reason;

  /// Whether this was a silent (`prompt=none`) attempt.
  final bool silent;

  static const sheetsNotGranted = 'sheets_not_granted';
  static const stale = 'stale';

  /// The person declined, as opposed to something going wrong.
  bool get declined => reason == 'access_denied';
}

/// Signing in with Google by OAuth 2.0 redirect (the token flow for
/// browser apps): the page goes to Google and comes back with an access token
/// in the URL fragment. No popup, so it works under any opener policy, and a
/// `prompt=none` round trip renews an expired token without a tap.
class GoogleAuth {
  GoogleAuth({
    required this.browser,
    required this.clientId,
    DateTime Function()? now,
    Random? random,
  })  : _now = now ?? DateTime.now,
        _random = random ?? Random.secure();

  final Browser browser;
  final String clientId;
  final DateTime Function() _now;
  final Random _random;

  static const sheetsScope = 'https://www.googleapis.com/auth/spreadsheets';
  static const scopes = ['openid', 'email', 'profile', sheetsScope];

  static const _pendingKey = 'fq.oauth';

  bool get configured => clientId.isNotEmpty;

  /// Registered with the OAuth client as an authorised redirect URI.
  Uri get redirectUri => Uri.parse('${browser.location.origin}/');

  Uri authorizationUrl({
    required String state,
    required String nonce,
    SignInPrompt prompt = SignInPrompt.auto,
    String? loginHint,
  }) =>
      Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
        'client_id': clientId,
        'redirect_uri': redirectUri.toString(),
        'response_type': 'token id_token',
        'scope': scopes.join(' '),
        'include_granted_scopes': 'true',
        'state': state,
        'nonce': nonce,
        if (prompt == SignInPrompt.none) 'prompt': 'none',
        if (prompt == SignInPrompt.chooseAccount) 'prompt': 'select_account',
        if (loginHint != null && prompt != SignInPrompt.chooseAccount)
          'login_hint': loginHint,
      });

  /// Leaves the app for Google; it comes back to [redirectUri].
  void signIn({SignInPrompt prompt = SignInPrompt.auto, String? loginHint}) {
    final state = _token();
    final nonce = _token();
    browser.setSessionValue(
      _pendingKey,
      jsonEncode({
        'state': state,
        'nonce': nonce,
        'silent': prompt == SignInPrompt.none,
      }),
    );
    browser.navigateTo(authorizationUrl(
      state: state,
      nonce: nonce,
      prompt: prompt,
      loginHint: loginHint,
    ));
  }

  /// The outcome of a round trip to Google, read from the address bar, which
  /// is then cleaned. Null when the page was not opened by Google.
  SignInResult? takeResult() {
    final location = browser.location;
    final params = Uri.splitQueryString(location.fragment);
    if (!params.containsKey('access_token') && !params.containsKey('error')) {
      return null;
    }
    browser.replaceLocation(location.removeFragment());

    final pendingJson = browser.sessionValue(_pendingKey);
    browser.setSessionValue(_pendingKey, null);
    final pending = pendingJson == null
        ? null
        : (jsonDecode(pendingJson) as Map).cast<String, Object?>();
    if (pending == null || pending['state'] != params['state']) {
      return const SignInFailed(SignInFailed.stale);
    }
    final silent = pending['silent'] == true;

    final error = params['error'];
    if (error != null) return SignInFailed(error, silent: silent);

    final granted = (params['scope'] ?? '').split(' ');
    if (!granted.contains(sheetsScope)) {
      return SignInFailed(SignInFailed.sheetsNotGranted, silent: silent);
    }

    final claims = _claims(params['id_token']);
    final email = claims?['email'] as String?;
    if (claims == null || email == null || claims['nonce'] != pending['nonce']) {
      return SignInFailed('invalid_id_token', silent: silent);
    }

    final expiresIn = int.tryParse(params['expires_in'] ?? '') ?? 3600;
    return SignedIn(
      Account(
        email: email,
        name: claims['name'] as String? ?? email,
        givenName: claims['given_name'] as String?,
      ),
      AccessToken(
        value: params['access_token']!,
        expiresAt: _now().add(Duration(seconds: expiresIn)),
      ),
    );
  }

  /// The ID token's claims. It came straight from Google over TLS in answer
  /// to this tab's request (state and nonce match), and only names the
  /// person; the Sheets API checks the access token itself.
  static Map<String, Object?>? _claims(String? idToken) {
    final parts = idToken?.split('.');
    if (parts == null || parts.length != 3) return null;
    try {
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      return (jsonDecode(payload) as Map).cast<String, Object?>();
    } on FormatException {
      return null;
    }
  }

  String _token() => [
        for (var i = 0; i < 16; i++)
          _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ].join();
}
