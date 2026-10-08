import 'package:action_design_system/action_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:four_questions/app_controller.dart';
import 'package:four_questions/application.dart';
import 'package:four_questions/auth/account.dart';
import 'package:four_questions/data/demo_sheets_gateway.dart';
import 'package:four_questions/data/local_store.dart';
import 'package:four_questions/model/local_day.dart';
import 'package:four_questions/splash/splash_handoff.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_controller_test.dart' show RecordingSignIn;
import 'google_auth_test.dart' show FakeBrowser;

/// The splash in `web/index.html` covers the cold start and comes down at the
/// first real screen. If a screen is ever built without [SplashHandoff], only
/// the eight-second backstop takes the splash down — the app would look
/// frozen on every load, and only on the web, where no test runs. And if a
/// renewal or a first load were wrapped, the splash would drop to a spinner
/// and come back.
///
/// So the wiring is pinned here rather than left to review.
class _Brand extends ActionBrand {
  const _Brand();
  @override
  String get name => 'Test';
  @override
  ColorScheme get colorScheme => const ColorScheme.light();
}

void main() {
  const today = LocalDay(2026, 10, 8);
  final now = DateTime(2026, 10, 8, 7, 30);
  const greg = Account(email: 'greg@example.com', name: 'Greg', givenName: 'Greg');

  late LocalStore local;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    local = await LocalStore.open();
  });

  Future<AppController> pumpApp(
    WidgetTester tester, {
    Duration latency = Duration.zero,
  }) async {
    final sheet = DemoSheetsGateway(latency: latency, today: today);
    sheet.people[greg.email] = 'Greg';
    final controller = AppController(
      local: local,
      signIn: RecordingSignIn(),
      browser: FakeBrowser(),
      openGateway: (_) => sheet,
      now: () => now,
      today: () => today,
    )..start();
    await tester.pumpWidget(
      Application(brand: const _Brand(), controller: controller),
    );
    return controller;
  }

  testWidgets('the sign-in screen hands the splash over', (tester) async {
    final c = await pumpApp(tester);

    expect(c.stage, AppStage.signedOut);
    expect(find.byType(SplashHandoff), findsOneWidget);
  });

  testWidgets('a question hands the splash over', (tester) async {
    local
      ..account = greg
      ..token = AccessToken(value: 't', expiresAt: now.add(const Duration(hours: 1)));
    final c = await pumpApp(tester);
    await tester.pumpAndSettle();

    expect(c.stage, AppStage.question);
    expect(find.byType(SplashHandoff), findsOneWidget);
  });

  testWidgets('a token renewal stays behind the splash', (tester) async {
    local
      ..account = greg
      ..token = AccessToken(value: 't', expiresAt: now);
    final c = await pumpApp(tester);

    expect(c.stage, AppStage.renewing);
    expect(find.byType(SplashHandoff), findsNothing);
  });

  testWidgets('a first visit waits for the sheet behind the splash',
      (tester) async {
    local
      ..account = greg
      ..token = AccessToken(value: 't', expiresAt: now.add(const Duration(hours: 1)));
    final c = await pumpApp(tester, latency: const Duration(seconds: 1));

    expect(c.stage, AppStage.loading);
    expect(find.byType(SplashHandoff), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(c.stage, AppStage.question);
    expect(find.byType(SplashHandoff), findsOneWidget);
  });
}
