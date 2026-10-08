import 'package:flutter/foundation.dart';
import 'package:four_questions/model/local_day.dart';
import 'package:four_questions/model/question.dart';

/// A row of the Answers sheet: one person's answer to one question on one day.
@immutable
class Answer {
  const Answer({
    required this.day,
    required this.questionId,
    required this.email,
    this.yes,
    this.note = '',
  });

  factory Answer.fromJson(Map<String, Object?> json) => Answer(
        day: LocalDay.tryParse(json['day']! as String)!,
        questionId: json['questionId']! as String,
        email: json['email']! as String,
        yes: json['yes'] as bool?,
        note: json['note'] as String? ?? '',
      );

  final LocalDay day;
  final String questionId;
  final String email;

  /// Null until a yes/no question has been answered.
  final bool? yes;
  final String note;

  /// One answer per person, question and day; a later row replaces an
  /// earlier one with the same key.
  static String keyOf(LocalDay day, String questionId, String email) =>
      '${day.iso}|$questionId|${email.toLowerCase()}';

  String get key => keyOf(day, questionId, email);

  bool isBy(String other) => email.toLowerCase() == other.toLowerCase();

  /// A yes/no question is answered by its yes or no; any other by a note.
  bool answers(Question question) =>
      question.yesNo ? yes != null : note.trim().isNotEmpty;

  Answer copyWith({bool? yes, String? note}) => Answer(
        day: day,
        questionId: questionId,
        email: email,
        yes: yes ?? this.yes,
        note: note ?? this.note,
      );

  Map<String, Object?> toJson() => {
        'day': day.iso,
        'questionId': questionId,
        'email': email,
        'yes': yes,
        'note': note,
      };

  @override
  bool operator ==(Object other) =>
      other is Answer &&
      other.day == day &&
      other.questionId == questionId &&
      other.email == email &&
      other.yes == yes &&
      other.note == note;

  @override
  int get hashCode => Object.hash(day, questionId, email, yes, note);

  @override
  String toString() => 'Answer($key, yes: $yes, note: "$note")';
}
