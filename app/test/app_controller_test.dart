import 'package:flutter_test/flutter_test.dart';
import 'package:four_questions/app_controller.dart';
import 'package:four_questions/auth/account.dart';
import 'package:four_questions/auth/google_auth.dart';
import 'package:four_questions/auth/sign_in_service.dart';
import 'package:four_questions/data/demo_sheets_gateway.dart';
import 'package:four_questions/data/local_store.dart';
import 'package:four_questions/model/answer.dart';
import 'package:four_questions/model/local_day.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'google_auth_test.dart' show FakeBrowser;

const today = LocalDay(2026, 10, 8);
const greg = Account(email: 'greg@example.com', name: 'Greg', givenName: 'Greg');

class RecordingSignIn implements SignInService {
  final requests = <({SignInPrompt prompt, String? loginHint})>[];
  SignInResult? next;

  @override
  bool get configured => true;

  @override
  void signIn({SignInPrompt prompt = SignInPrompt.auto, String? loginHint}) =>
      requests.add((prompt: prompt, loginHint: loginHint));

  @override
  SignInResult? takeResult() {
    final result = next;
    next = null;
    return result;
  }
}

void main() {
  final now = DateTime(2026, 10, 8, 7, 30);
  late LocalStore local;
  late DemoSheetsGateway sheet;
  late RecordingSignIn signIn;
  late FakeBrowser browser;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    local = await LocalStore.open();
    sheet = DemoSheetsGateway(latency: Duration.zero, today: today);
    sheet.people['greg@example.com'] = 'Greg';
    signIn = RecordingSignIn();
    browser = FakeBrowser();
  });

  AppController controller() => AppController(
        local: local,
        signIn: signIn,
        browser: browser,
        openGateway: (_) => sheet,
        now: () => now,
        today: () => today,
      );

  void signedIn({Duration left = const Duration(minutes: 50)}) => local
    ..account = greg
    ..token = AccessToken(value: 't', expiresAt: now.add(left));

  void answered(List<String> ids) => sheet.answers.addAll([
        for (final id in ids)
          Answer(day: today, questionId: id, email: greg.email, yes: true),
      ]);

  test('no one signed in: the sign-in screen', () {
    final c = controller()..start();
    expect(c.stage, AppStage.signedOut);
    expect(c.account, isNull);
  });

  test('opens on the first question not yet answered today', () async {
    signedIn();
    answered(['1', '2']);
    final c = controller()..start();
    await pumpEventQueue();

    expect(c.stage, AppStage.question);
    expect(c.currentQuestion!.id, '3');
  });

  test('opens on the summary when every question is answered', () async {
    signedIn();
    answered(['1', '2', '3', '4']);
    final c = controller()..start();
    await pumpEventQueue();

    expect(c.stage, AppStage.summary);
  });

  test('back, skip and finish', () async {
    signedIn();
    final c = controller()..start();
    await pumpEventQueue();
    expect(c.questionIndex, 0);

    c.back();
    expect(c.questionIndex, 0, reason: 'nothing before the first');
    c
      ..next()
      ..next();
    expect(c.questionIndex, 2);
    c.back();
    expect(c.questionIndex, 1);
    expect(c.forward, isFalse);
    c
      ..next()
      ..next()
      ..next();
    expect(c.stage, AppStage.summary);

    c.edit(c.store!.questions[1]);
    expect(c.stage, AppStage.question);
    expect(c.questionIndex, 1);
    expect(c.canShowSummary, isTrue);
  });

  test('a first sign-in asks for a name, prefilled from Google', () async {
    sheet.people.remove('greg@example.com');
    signedIn();
    final c = controller()..start();
    await pumpEventQueue();

    expect(c.stage, AppStage.welcome);
    expect(c.nameDraft, 'Greg');

    c
      ..setNameDraft('Gregory')
      ..saveName();
    expect(c.stage, AppStage.question);
    await pumpEventQueue();
    expect(sheet.people['greg@example.com'], 'Gregory');
  });

  test('an account that cannot edit is turned away', () async {
    sheet.editable = false;
    signedIn();
    final c = controller()..start();
    await pumpEventQueue();

    expect(c.stage, AppStage.noAccess);
    expect(local.confirmedEditor, isNull);
  });

  test('a returning editor sees the device copy before the sheet answers',
      () async {
    signedIn();
    final first = controller()..start();
    await pumpEventQueue();
    first.dispose();

    final slow = DemoSheetsGateway(
        latency: const Duration(seconds: 5), today: today);
    final c = AppController(
      local: local,
      signIn: signIn,
      browser: browser,
      openGateway: (_) => slow,
      now: () => now,
      today: () => today,
    )..start();

    expect(c.stage, AppStage.question, reason: 'no waiting on the sheet');
    c.dispose();
  });

  test('an expired token is renewed silently, at most once a minute', () {
    signedIn(left: -const Duration(minutes: 1));
    final c = controller()..start();

    expect(c.stage, AppStage.renewing);
    expect(signIn.requests.single.prompt, SignInPrompt.none);
    expect(signIn.requests.single.loginHint, greg.email);

    // Google came back needing a tap: no second silent attempt.
    signIn.next = const SignInFailed('interaction_required', silent: true);
    final again = controller()..start();
    expect(again.stage, AppStage.signedOut);
    expect(again.account, greg, reason: 'offered "Continue as Greg"');
    expect(signIn.requests.length, 1);
  });

  test('a token about to expire is renewed, after drawing the screen',
      () async {
    signedIn(left: const Duration(minutes: 3));
    controller().start();

    expect(signIn.requests.single.prompt, SignInPrompt.none);
  });

  test('where the person was survives the renewal round trip', () async {
    var clock = now;
    AppController page() => AppController(
          local: local,
          signIn: signIn,
          browser: browser,
          openGateway: (_) => sheet,
          now: () => clock,
          today: () => today,
        )..start();

    signedIn();
    final c = page();
    await pumpEventQueue();
    c
      ..next()
      ..next();
    expect(c.questionIndex, 2);

    // Back to the tab 47 minutes later: the token has 3 minutes left.
    clock = now.add(const Duration(minutes: 47));
    browser.visible.add(null);
    await pumpEventQueue();
    expect(signIn.requests.single.prompt, SignInPrompt.none);
    c.dispose();

    // The page comes back from Google with a new token.
    signIn.next = SignedIn(
      greg,
      AccessToken(value: 'new', expiresAt: clock.add(const Duration(hours: 1))),
    );
    final back = page();
    await pumpEventQueue();

    expect(back.stage, AppStage.question);
    expect(back.questionIndex, 2);
  });
}
