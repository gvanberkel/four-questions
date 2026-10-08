import 'package:four_questions/model/answer.dart';
import 'package:four_questions/model/local_day.dart';
import 'package:four_questions/model/question.dart';

/// What the sheet holds for one day.
class SheetSnapshot {
  const SheetSnapshot({
    required this.questions,
    required this.answers,
    required this.people,
  });

  /// Every question, in sheet order, active or not.
  final List<Question> questions;

  /// Everyone's answers for the day asked for.
  final List<Answer> answers;

  /// Email (lower case) to the name the person goes by.
  final Map<String, String> people;
}

/// The spreadsheet, as the app uses it.
abstract interface class SheetsGateway {
  Future<SheetSnapshot> load(LocalDay day);

  /// Writes each answer over the person's earlier answer to the same question
  /// that day, or as a new row.
  Future<void> saveAnswers(List<Answer> answers);

  /// Records the name [email] goes by, creating the People sheet if needed.
  Future<void> savePerson(String email, String name);

  /// Whether the signed-in account may edit the spreadsheet.
  Future<bool> canEdit();
}

/// The access token was refused: it has expired or been revoked.
class SheetsAuthException implements Exception {
  const SheetsAuthException();
  @override
  String toString() => 'The Google sign-in has expired.';
}

/// The account may not read, or may not edit, the spreadsheet.
class SheetsAccessException implements Exception {
  const SheetsAccessException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// The sheet could not be reached or answered with an error; worth retrying.
class SheetsUnavailableException implements Exception {
  const SheetsUnavailableException(this.message);
  final String message;
  @override
  String toString() => message;
}
