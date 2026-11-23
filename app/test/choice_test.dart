import 'package:flutter_test/flutter_test.dart';
import 'package:four_questions/model/answer.dart';
import 'package:four_questions/model/local_day.dart';
import 'package:four_questions/model/question.dart';

void main() {
  const gentle = Question(
    id: '4',
    text: 'Have you been gentle with your kids today?',
    options: ['Yes', 'Half-Half', 'No'],
  );

  test('a choice is matched to the option however it was typed', () {
    expect(gentle.optionFor('half-half'), 'Half-Half');
    expect(gentle.optionFor(' yes '), 'Yes');
    expect(gentle.optionFor('Sometimes'), 'Sometimes');
    expect(gentle.optionFor(null), isNull);
  });

  test('answers saved on the device as yes / no come back as words', () {
    Answer read(Object? yes) => Answer.fromJson({
          'day': '2026-11-23',
          'questionId': '1',
          'email': 'greg@example.com',
          'yes': yes,
          'note': '',
        });

    expect(read(true).choice, 'Yes');
    expect(read(false).choice, 'No');
    expect(read(null).choice, isNull);
  });

  test('a choice and the options survive the device round trip', () {
    const answer = Answer(
      day: LocalDay(2026, 11, 23),
      questionId: '4',
      email: 'greg@example.com',
      choice: 'Half-Half',
    );
    expect(Answer.fromJson(answer.toJson()), answer);
    expect(Question.fromJson(gentle.toJson()), gentle);

    final cached = gentle.toJson()..remove('options');
    expect(Question.fromJson(cached).options, ['Yes', 'No']);
  });
}
