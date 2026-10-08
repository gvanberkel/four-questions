import 'package:four_questions/auth/account.dart';
import 'package:four_questions/auth/google_auth.dart';

/// How the app gets a Google account and token: [GoogleAuth] for real, the
/// demo for trying the app without Google.
abstract interface class SignInService {
  bool get configured;

  /// Starts signing in. Google leaves the page and comes back; the demo
  /// signs in on the spot and the result is ready from [takeResult].
  void signIn({SignInPrompt prompt = SignInPrompt.auto, String? loginHint});

  /// The result of the last sign-in, once.
  SignInResult? takeResult();
}

class GoogleSignInService implements SignInService {
  GoogleSignInService(this.auth);

  final GoogleAuth auth;

  @override
  bool get configured => auth.configured;

  @override
  void signIn({SignInPrompt prompt = SignInPrompt.auto, String? loginHint}) =>
      auth.signIn(prompt: prompt, loginHint: loginHint);

  @override
  SignInResult? takeResult() => auth.takeResult();
}

class DemoSignInService implements SignInService {
  SignInResult? _result;

  static const account = Account(
    email: 'demo@example.com',
    name: 'Demo Person',
    givenName: 'Demo',
  );

  @override
  bool get configured => true;

  @override
  void signIn({SignInPrompt prompt = SignInPrompt.auto, String? loginHint}) {
    _result = SignedIn(
      account,
      AccessToken(
        value: 'demo',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      ),
    );
  }

  @override
  SignInResult? takeResult() {
    final result = _result;
    _result = null;
    return result;
  }
}
