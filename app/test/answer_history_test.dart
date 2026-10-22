import 'package:flutter_test/flutter_test.dart';
import 'package:four_questions/check_in/answer_history.dart';
import 'package:four_questions/model/answer.dart';
import 'package:four_questions/model/local_day.dart';
import 'package:four_questions/model/question.dart';

void main() {
  const monday = LocalDay(2026, 10, 5);
  const tuesday = LocalDay(2026, 10, 6);
  const questions = [
    Question(id: '1', text: 'Fun?'),
    Question(id: '2', text: 'Retired?', active: false),
    Question(id: '3', text: 'Words', yesNo: false),
  ];

  Answer a(LocalDay day, String id, String email, {bool? yes, String note = ''}) =>
      Answer(day: day, questionId: id, email: email, yes: yes, note: note);

  test('days with an answer, most recent first; blanks and unknowns left out',
      () {
    final history = AnswerHistory(questions: questions, answers: [
      a(monday, '1', 'greg@example.com', yes: true),
      a(tuesday, '1', 'greg@example.com'), // a yes/no left blank
      a(tuesday, '9', 'greg@example.com', yes: true), // not on the sheet
      a(LocalDay(2026, 10, 7), '2', 'hovi@example.com', yes: false),
    ]);

    expect(history.days, [const LocalDay(2026, 10, 7), monday]);
  });

  test("a day's questions in sheet order, retired ones too, and who answered",
      () {
    final history = AnswerHistory(questions: questions, answers: [
      a(monday, '3', 'Hovi@example.com', note: 'A walk'),
      a(monday, '2', 'greg@example.com', yes: true),
      a(monday, '3', 'greg@example.com', note: 'Reading'),
    ]);

    final day = history.on(monday);
    expect([for (final e in day) e.question.id], ['2', '3']);
    expect([for (final a in day[1].answers) a.note], ['A walk', 'Reading']);
    expect(history.peopleOn(monday), ['hovi@example.com', 'greg@example.com']);
    expect(history.on(tuesday), isEmpty);
  });
}
