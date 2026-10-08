import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:action_design_system/action_design_system.dart';

class _Brand extends ActionBrand {
  const _Brand();
  @override
  String get name => 'Test';
  @override
  ColorScheme get colorScheme => const ColorScheme.light();
}

Widget _host(Widget child) => MaterialApp(
      theme: buildActionTheme(const _Brand()),
      home: Scaffold(body: Align(alignment: Alignment.topRight, child: child)),
    );

void main() {
  testWidgets('opens to identity, appearance toggle and version', (tester) async {
    ThemeMode? chosen;
    await tester.pumpWidget(_host(ActionAccountMenu(
      name: 'Thandi Nkosi',
      email: 'thandi@example.com',
      rolesLabel: 'Member',
      versionLabel: 'Test v1.2.3 · build abc',
      themeMode: ThemeMode.system,
      onThemeModeChanged: (m) => chosen = m,
      onSignOut: () {},
    )));

    expect(find.text('thandi@example.com'), findsNothing);

    await tester.tap(find.text('Thandi Nkosi'));
    await tester.pumpAndSettle();

    expect(find.text('thandi@example.com'), findsOneWidget);
    expect(find.text('Member'), findsOneWidget);
    expect(find.text('Test v1.2.3 · build abc'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('APPEARANCE'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pump();
    expect(chosen, ThemeMode.dark);
    expect(find.text('Light'), findsOneWidget);
  });

  testWidgets('without a session there is no sign out, and no toggle without '
      'both theme props', (tester) async {
    await tester.pumpWidget(_host(const ActionAccountMenu(
      name: 'Guest',
      rolesLabel: 'Not signed in',
      themeMode: ThemeMode.light,
    )));
    await tester.tap(find.text('Guest'));
    await tester.pumpAndSettle();

    expect(find.text('Not signed in'), findsOneWidget);
    expect(find.text('Sign out'), findsNothing);
    expect(find.text('APPEARANCE'), findsNothing);
  });

  testWidgets('settings rows sit in the menu and stay open when used',
      (tester) async {
    var reminders = true;
    await tester.pumpWidget(_host(StatefulBuilder(
      builder: (context, setState) => ActionAccountMenu(
        name: 'Thandi Nkosi',
        settings: [
          ActionSwitchRow(
            title: 'Check-in reminders',
            subtitle: reminders ? 'Reminding you weekly' : 'No reminders',
            value: reminders,
            onChanged: (value) => setState(() => reminders = value),
          ),
        ],
      ),
    )));

    expect(find.text('Check-in reminders'), findsNothing);
    await tester.tap(find.text('Thandi Nkosi'));
    await tester.pumpAndSettle();

    expect(find.text('Check-in reminders'), findsOneWidget);
    await tester.tap(find.text('Check-in reminders'));
    await tester.pumpAndSettle();

    expect(reminders, isFalse);
    expect(find.text('No reminders'), findsOneWidget);
  });

  testWidgets('segmented toggle reports the tapped value only', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(_host(ActionSegmentedToggle<int>(
      segments: const [
        ActionSegment(value: 1, label: 'One'),
        ActionSegment(value: 2, label: 'Two'),
      ],
      value: 1,
      onChanged: taps.add,
    )));
    await tester.tap(find.text('One'));
    await tester.tap(find.text('Two'));
    expect(taps, [2]);
  });
}
