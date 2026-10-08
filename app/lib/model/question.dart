import 'package:flutter/foundation.dart';

/// A row of the Questions sheet.
@immutable
class Question {
  const Question({
    required this.id,
    required this.text,
    this.active = true,
    this.yesNo = true,
    this.allowNotes = false,
  });

  factory Question.fromJson(Map<String, Object?> json) => Question(
        id: json['id']! as String,
        text: json['text']! as String,
        active: json['active']! as bool,
        yesNo: json['yesNo']! as bool,
        allowNotes: json['allowNotes']! as bool,
      );

  final String id;
  final String text;
  final bool active;
  final bool yesNo;
  final bool allowNotes;

  /// A question that is neither yes/no nor open to notes would have no way to
  /// be answered, so it takes a note.
  bool get takesNote => allowNotes || !yesNo;

  Map<String, Object?> toJson() => {
        'id': id,
        'text': text,
        'active': active,
        'yesNo': yesNo,
        'allowNotes': allowNotes,
      };

  @override
  bool operator ==(Object other) =>
      other is Question &&
      other.id == id &&
      other.text == text &&
      other.active == active &&
      other.yesNo == yesNo &&
      other.allowNotes == allowNotes;

  @override
  int get hashCode => Object.hash(id, text, active, yesNo, allowNotes);
}
