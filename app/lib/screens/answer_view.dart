import 'package:action_design_system/action_design_system.dart';
import 'package:four_questions/model/answer.dart';
import 'package:four_questions/model/question.dart';

/// [name]'s answer to [question] as an answer set shows it: Yes / No when the
/// question asks for one, and the note.
ActionAnswer answerView(
  Question question,
  String name,
  Answer? answer, {
  String placeholder = 'Not answered yet',
}) =>
    ActionAnswer(
      name: name,
      choice: !question.yesNo || answer?.yes == null
          ? null
          : answer!.yes!
              ? 'Yes'
              : 'No',
      note: answer?.note ?? '',
      placeholder: placeholder,
    );
