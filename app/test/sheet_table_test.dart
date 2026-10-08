import 'package:flutter_test/flutter_test.dart';
import 'package:four_questions/data/sheet_table.dart';
import 'package:four_questions/model/answer.dart';
import 'package:four_questions/model/local_day.dart';

void main() {
  const today = LocalDay(2026, 10, 8);
  // 2026-10-08 as Google Sheets counts days.
  final serial = today.date.difference(DateTime(1899, 12, 30)).inDays;

  group('questions', () {
    test('read in sheet order, with Yes/No flags and inactive ones', () {
      final questions = parseQuestions(SheetTable([
        ['Question ID', 'Question', 'Active', 'Yes/No', 'Allow notes'],
        [1, 'Have you had fun today?', 'Yes', 'Yes', 'Yes'],
        [2, 'Have you taken a moment for yourself today?', 'Yes', 'Yes', 'No'],
        [5, 'Is this question no longer used?', 'No', 'Yes', 'Yes'],
        [6, 'What made you laugh?', true, false, true],
        [null, '', null, null, null],
      ]));

      expect(questions.map((q) => q.id), ['1', '2', '5', '6']);
      expect(questions[0].active && questions[0].yesNo && questions[0].allowNotes,
          isTrue);
      expect(questions[1].allowNotes, isFalse);
      expect(questions[2].active, isFalse);
      expect(questions[3].yesNo, isFalse);
      expect(questions[3].takesNote, isTrue);
    });

    test('columns are found by header, wherever they are', () {
      final questions = parseQuestions(SheetTable([
        ['Active', 'Question', 'Allow notes', 'Question ID', 'Yes/No'],
        ['Yes', 'Reordered?', 'No', 9, 'Yes'],
      ]));

      expect(questions.single.id, '9');
      expect(questions.single.text, 'Reordered?');
      expect(questions.single.allowNotes, isFalse);
    });
  });

  group('answers', () {
    final header = ['Date', 'Question ID', 'Answered By', 'Yes/No', 'Note'];

    test('only the day asked for, by serial date or ISO text', () {
      final answers = parseAnswers(
        SheetTable([
          header,
          [serial, 1, 'greg@example.com', 'Yes', 'Park'],
          [serial - 1, 1, 'greg@example.com', 'No', ''],
          ['2026-10-08', 2, 'hovi@example.com', 'No', null],
        ]),
        day: today,
      );

      expect(answers.length, 2);
      final greg = answers[Answer.keyOf(today, '1', 'greg@example.com')]!;
      expect(greg.rowNumber, 2);
      expect(greg.answer.yes, isTrue);
      expect(greg.answer.note, 'Park');
      final hovi = answers[Answer.keyOf(today, '2', 'hovi@example.com')]!;
      expect(hovi.rowNumber, 4);
      expect(hovi.answer.yes, isFalse);
    });

    test('a later row for the same person and question wins', () {
      final answers = parseAnswers(
        SheetTable([
          header,
          [serial, 1, 'Greg@Example.com', 'Yes', ''],
          [serial, 1, 'greg@example.com', 'No', 'changed my mind'],
        ]),
        day: today,
      );

      expect(answers.length, 1);
      expect(answers.values.single.rowNumber, 3);
      expect(answers.values.single.answer.yes, isFalse);
    });

    test('the old "Person" header still finds the email column', () {
      final answers = parseAnswers(
        SheetTable([
          ['Date', 'Question ID', 'Person', 'Yes/No', 'Note'],
          [serial, 3, 'greg@example.com', 'Yes'],
        ]),
        day: today,
      );

      expect(answers.values.single.answer.email, 'greg@example.com');
      expect(answers.values.single.answer.note, '');
    });

    test('a row is laid out in the sheet\'s own column order', () {
      final table = SheetTable([
        ['Answered By', 'Date', 'Note', 'Question ID', 'Yes/No'],
      ]);
      final row = answerRow(
        table,
        const Answer(
          day: today,
          questionId: '4',
          email: 'greg@example.com',
          yes: false,
          note: '=not a formula',
        ),
      );

      expect(row, ['greg@example.com', '2026-10-08', "'=not a formula", 4, 'No']);
    });

    test('an unanswered yes/no is written blank', () {
      final row = answerRow(
        SheetTable([header]),
        const Answer(day: today, questionId: 'q7', email: 'a@b.c', note: 'hi'),
      );

      expect(row, ['2026-10-08', 'q7', 'a@b.c', '', 'hi']);
    });
  });

  group('people', () {
    test('by lower-case email', () {
      final people = parsePeople(SheetTable([
        ['Email', 'Name'],
        ['Hovi@Example.com', 'Hovi'],
        ['nobody@example.com', ''],
      ]));

      expect(people.keys, ['hovi@example.com']);
      expect(people['hovi@example.com']!.name, 'Hovi');
      expect(people['hovi@example.com']!.rowNumber, 2);
    });
  });

  test('column letters', () {
    expect(columnLetter(0), 'A');
    expect(columnLetter(4), 'E');
    expect(columnLetter(25), 'Z');
    expect(columnLetter(26), 'AA');
  });

  test('days from the sheet', () {
    expect(LocalDay.fromSheetsSerial(serial), today);
    expect(LocalDay.tryParse('2026/10/08'), today);
    expect(LocalDay.tryParse('2026-02-30'), isNull);
    expect(today.spoken, 'Thursday 8 October');
  });
}
