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
      home: Scaffold(body: Center(child: child)),
    );

const _yesNo = [
  ActionChoice(value: true, label: 'Yes'),
  ActionChoice(value: false, label: 'No'),
];

void main() {
  testWidgets('a choice group starts with nothing chosen', (tester) async {
    await tester.pumpWidget(_host(ActionChoiceGroup<bool>(
      choices: _yesNo,
      value: null,
      onChanged: (_) {},
    )));

    expect(find.byIcon(ActionIcons.selected), findsNothing);
    expect(
      tester.getSemantics(find.text('Yes')),
      isSemantics(
        label: 'Yes',
        isButton: true,
        isInMutuallyExclusiveGroup: true,
        hasCheckedState: true,
        hasTapAction: true,
      ),
    );
  });

  testWidgets('a choice reports its value and ticks only when told',
      (tester) async {
    bool? chosen;
    var value = null as bool?;
    await tester.pumpWidget(_host(StatefulBuilder(
      builder: (context, setState) => ActionChoiceGroup<bool>(
        choices: _yesNo,
        value: value,
        onChanged: (v) {
          chosen = v;
          setState(() => value = v);
        },
      ),
    )));

    await tester.tap(find.text('No'));
    await tester.pump();

    expect(chosen, isFalse);
    expect(find.byIcon(ActionIcons.selected), findsOneWidget);

    chosen = null;
    await tester.tap(find.text('No'));
    await tester.pump();
    expect(chosen, isNull, reason: 'the chosen option is not tappable again');
  });

  testWidgets('the note field keeps the cursor where the person types',
      (tester) async {
    var note = 'hello world';
    await tester.pumpWidget(_host(StatefulBuilder(
      builder: (context, setState) => ActionNoteField(
        value: note,
        onChanged: (v) => setState(() => note = v),
      ),
    )));

    final field = find.byType(EditableText);
    await tester.tap(field);
    await tester.pump();
    final editable = tester.state<EditableTextState>(field);
    editable.userUpdateTextEditingValue(
      const TextEditingValue(
        text: 'hello, world',
        selection: TextSelection.collapsed(offset: 6),
      ),
      SelectionChangedCause.keyboard,
    );
    await tester.pump();

    expect(note, 'hello, world');
    expect(editable.textEditingValue.selection.baseOffset, 6);
  });

  testWidgets('the note field takes a value replaced from outside',
      (tester) async {
    Widget field(String value) =>
        _host(ActionNoteField(value: value, onChanged: (_) {}));

    await tester.pumpWidget(field('first'));
    await tester.pumpWidget(field('second'));

    expect(find.text('second'), findsOneWidget);
  });

  testWidgets('the step track reports the segment tapped', (tester) async {
    int? selected;
    await tester.pumpWidget(_host(SizedBox(
      width: 300,
      child: ActionStepTrack(
        stepLabel: 'Question',
        steps: const [
          ActionStepState.done,
          ActionStepState.skipped,
          ActionStepState.upcoming,
        ],
        current: 2,
        onSelect: (i) => selected = i,
      ),
    )));

    await tester.tap(find.bySemanticsLabel('Question 2 of 3, skipped'));
    expect(selected, 1);
    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp('Question 3 of 3'))),
      isSemantics(isSelected: true, hasSelectedState: true, isButton: true,
          hasTapAction: true, label: 'Question 3 of 3, not answered yet'),
    );
  });

  testWidgets('the prompt shows eyebrow, question and pills', (tester) async {
    await tester.pumpWidget(_host(const ActionPrompt(
      eyebrow: 'Question 1 of 4',
      prompt: 'Have you had fun today?',
      pills: [ActionPill('Answered by Hovi today')],
    )));

    expect(find.text('QUESTION 1 OF 4'), findsOneWidget);
    expect(find.text('Have you had fun today?'), findsOneWidget);
    expect(find.text('Answered by Hovi today'), findsOneWidget);
  });

  group('an answer set', () {
    const pair = ActionAnswerSet(
      title: 'Have you had fun today?',
      layout: ActionAnswerLayout.sideBySide,
      answers: [
        ActionAnswer(name: 'Greg', choice: 'Yes', note: 'A kite at the beach'),
        ActionAnswer(name: 'Hovi', placeholder: 'Not answered yet'),
      ],
    );

    testWidgets('puts two side by side when there is room', (tester) async {
      await tester.pumpWidget(_host(const SizedBox(width: 600, child: pair)));

      final greg = tester.getTopLeft(find.text('Greg'));
      final hovi = tester.getTopLeft(find.text('Hovi'));
      expect(hovi.dy, greg.dy);
      expect(hovi.dx, greaterThan(greg.dx));
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('A kite at the beach'), findsOneWidget);
      expect(find.text('Not answered yet'), findsOneWidget);
    });

    testWidgets('stacks them when the columns would be too narrow',
        (tester) async {
      await tester.pumpWidget(_host(const SizedBox(width: 280, child: pair)));

      final greg = tester.getTopLeft(find.text('Greg'));
      final hovi = tester.getTopLeft(find.text('Hovi'));
      expect(hovi.dy, greaterThan(greg.dy));
      expect(hovi.dx, greg.dx);
    });

    testWidgets('reports a tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_host(ActionAnswerSet(
        title: 'Have you had fun today?',
        onTap: () => taps++,
        answers: const [ActionAnswer(name: 'Hovi', choice: 'No')],
      )));

      await tester.tap(find.text('Have you had fun today?'));
      expect(taps, 1);
    });
  });
}
