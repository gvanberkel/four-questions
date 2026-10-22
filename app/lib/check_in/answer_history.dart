import 'package:four_questions/model/answer.dart';
import 'package:four_questions/model/local_day.dart';
import 'package:four_questions/model/question.dart';

/// Everyone's answers on the days before today, as the earlier-days screen
/// reads them: which days anyone answered, and what was said on each.
class AnswerHistory {
  AnswerHistory({
    required List<Question> questions,
    required Iterable<Answer> answers,
  }) : _questions = questions {
    final byId = {for (final q in questions) q.id: q};
    for (final a in answers) {
      final question = byId[a.questionId];
      if (question == null || !a.answers(question)) continue;
      _byDay.putIfAbsent(a.day, () => []).add(a);
    }
    days = _byDay.keys.toList()..sort((a, b) => b.compareTo(a));
  }

  /// Every question, active or not: a question since retired still has its
  /// old answers.
  final List<Question> _questions;
  final _byDay = <LocalDay, List<Answer>>{};

  /// The days anyone answered anything, most recent first.
  late final List<LocalDay> days;

  /// Each question answered on [day], in sheet order, with the answers given
  /// to it in the order they were first given.
  List<({Question question, List<Answer> answers})> on(LocalDay day) {
    final answers = _byDay[day] ?? const [];
    return [
      for (final q in _questions)
        if (answers.any((a) => a.questionId == q.id))
          (
            question: q,
            answers: [
              for (final a in answers)
                if (a.questionId == q.id) a,
            ],
          ),
    ];
  }

  /// The emails (lower case) of everyone who answered on [day], in the order
  /// they first answered.
  List<String> peopleOn(LocalDay day) => {
        for (final a in _byDay[day] ?? const <Answer>[]) a.email.toLowerCase(),
      }.toList();
}
