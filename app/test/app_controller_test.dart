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
          Answer(day: today, questionId: id, email: greg.email, choice: 'Yes'),
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

  test('earlier days: the most recent first, back a day, on to today',
      () async {
    signedIn();
    answered(['1', '2', '3', '4']);
    sheet.answers.addAll(const [
      Answer(day: LocalDay(2026, 10, 7), questionId: '1', email: 'hovi@example.com', choice: 'Yes'),
      Answer(day: LocalDay(2026, 10, 5), questionId: '2', email: 'greg@example.com', choice: 'No'),
    ]);
    final c = controller()..start();
    await pumpEventQueue();

    c.showHistory();
    expect(c.stage, AppStage.history);
    expect(c.historyDay, const LocalDay(2026, 10, 7));

    c.earlierDay();
    expect(c.historyDay, const LocalDay(2026, 10, 5));
    c.earlierDay();
    expect(c.historyDay, const LocalDay(2026, 10, 5), reason: 'the oldest');

    c.laterDay();
    expect(c.historyDay, const LocalDay(2026, 10, 7));
    c.laterDay();
    expect(c.stage, AppStage.summary);

    c.showHistory();
    expect(c.historyDay, const LocalDay(2026, 10, 7), reason: 'opens fresh');
    c.edit(c.store!.questions[2]);
    expect(c.stage, AppStage.question);
  });

  group('yesterday not finished', () {
    const yesterday = LocalDay(2026, 10, 7);

    // Greg keeps up (he answered two days ago) but answered only the first
    // of yesterday's questions; Hovi answered the second.
    setUp(() => sheet.answers.addAll(const [
          Answer(day: LocalDay(2026, 10, 6), questionId: '1', email: 'greg@example.com', choice: 'Yes'),
          Answer(day: yesterday, questionId: '1', email: 'greg@example.com', choice: 'Yes'),
          Answer(day: yesterday, questionId: '2', email: 'hovi@example.com', choice: 'No', note: 'Busy day'),
        ]));

    test('asks which day before starting; yesterday shows what Hovi said',
        () async {
      signedIn();
      final c = controller()..start();
      await pumpEventQueue();
      expect(c.stage, AppStage.chooseDay);

      c.answerYesterday();
      final store = c.store!;
      expect(c.stage, AppStage.question);
      expect(store.answering, yesterday);
      expect(c.currentQuestion!.id, '2', reason: "yesterday's first open one");
      expect(store.othersAnswers(c.currentQuestion!).single.answer.note,
          'Busy day');

      store.setChoice(c.currentQuestion!, 'Yes');
      await pumpEventQueue();
      expect(
        sheet.answers.where((a) => a.day == yesterday && a.isBy(greg.email)),
        hasLength(2),
        reason: "saved against yesterday",
      );
      expect(store.answeredOn(today), 0, reason: 'today untouched');

      c
        ..next()
        ..next()
        ..next();
      expect(c.stage, AppStage.summary);
      expect(store.answeringYesterday, isTrue);

      c.answerToday();
      expect(store.answering, today);
      expect(c.stage, AppStage.question);
      expect(c.currentQuestion!.id, '1');
    });

    test('answering for today passes yesterday over', () async {
      signedIn();
      final c = controller()..start();
      await pumpEventQueue();

      c.answerToday();
      expect(c.stage, AppStage.question);
      expect(c.store!.answering, today);
      expect(c.currentQuestion!.id, '1');
    });

    test('not asked once today is started or yesterday is done', () async {
      signedIn();
      answered(['1']);
      final c = controller()..start();
      await pumpEventQueue();
      expect(c.stage, AppStage.question, reason: 'today already started');
      c.dispose();

      sheet.answers
        ..removeWhere((a) => a.day == today && a.isBy(greg.email))
        ..addAll([
          for (final id in ['2', '3', '4'])
            Answer(day: yesterday, questionId: id, email: greg.email, choice: 'No'),
        ]);
      final done = controller()..start();
      await pumpEventQueue();
      expect(done.stage, AppStage.question, reason: 'yesterday is done');
    });

    test('not asked of someone who has never answered', () async {
      sheet.answers.removeWhere((a) => a.isBy(greg.email));
      signedIn();
      final c = controller()..start();
      await pumpEventQueue();
      expect(c.stage, AppStage.question);
    });

    test('answering yesterday survives the renewal round trip', () async {
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
        ..answerYesterday()
        ..next();
      expect(c.questionIndex, 2);

      clock = now.add(const Duration(minutes: 47));
      browser.visible.add(null);
      await pumpEventQueue();
      c.dispose();

      signIn.next = SignedIn(
        greg,
        AccessToken(value: 'new', expiresAt: clock.add(const Duration(hours: 1))),
      );
      final back = page();
      await pumpEventQueue();

      expect(back.stage, AppStage.question);
      expect(back.store!.answering, yesterday);
      expect(back.questionIndex, 2);
    });
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
