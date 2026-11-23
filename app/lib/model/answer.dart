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
    this.choice,
    this.note = '',
  });

  factory Answer.fromJson(Map<String, Object?> json) => Answer(
        day: LocalDay.tryParse(json['day']! as String)!,
        questionId: json['questionId']! as String,
        email: json['email']! as String,
        choice: json['choice'] as String? ?? _legacyChoice(json['yes']),
        note: json['note'] as String? ?? '',
      );

  final LocalDay day;
  final String questionId;
  final String email;

  /// The option picked — "Yes", "No", "Half-Half" — null until a yes/no
  /// question has been answered.
  final String? choice;
  final String note;

  /// One answer per person, question and day; a later row replaces an
  /// earlier one with the same key.
  static String keyOf(LocalDay day, String questionId, String email) =>
      '${day.iso}|$questionId|${email.toLowerCase()}';

  String get key => keyOf(day, questionId, email);

  bool isBy(String other) => email.toLowerCase() == other.toLowerCase();

  /// A yes/no question is answered by its yes or no; any other by a note.
  bool answers(Question question) =>
      question.yesNo ? choice != null : note.trim().isNotEmpty;

  Answer copyWith({String? choice, String? note}) => Answer(
        day: day,
        questionId: questionId,
        email: email,
        choice: choice ?? this.choice,
        note: note ?? this.note,
      );

  Map<String, Object?> toJson() => {
        'day': day.iso,
        'questionId': questionId,
        'email': email,
        'choice': choice,
        'note': note,
      };

  @override
  bool operator ==(Object other) =>
      other is Answer &&
      other.day == day &&
      other.questionId == questionId &&
      other.email == email &&
      other.choice == choice &&
      other.note == note;

  @override
  int get hashCode => Object.hash(day, questionId, email, choice, note);

  @override
  String toString() => 'Answer($key, choice: $choice, note: "$note")';

  /// Answers kept on the device before choices were words.
  static String? _legacyChoice(Object? yes) => switch (yes) {
        true => 'Yes',
        false => 'No',
        _ => null,
      };
}
