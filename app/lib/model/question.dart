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
    this.options = defaultOptions,
  });

  factory Question.fromJson(Map<String, Object?> json) => Question(
        id: json['id']! as String,
        text: json['text']! as String,
        active: json['active']! as bool,
        yesNo: json['yesNo']! as bool,
        allowNotes: json['allowNotes']! as bool,
        options: (json['options'] as List?)?.cast<String>() ?? defaultOptions,
      );

  static const defaultOptions = ['Yes', 'No'];

  final String id;
  final String text;
  final bool active;

  /// Answered by picking one of [options].
  final bool yesNo;
  final bool allowNotes;

  /// What a [yesNo] question offers, in order: Yes / No unless the sheet
  /// names others.
  final List<String> options;

  /// A question that is neither yes/no nor open to notes would have no way to
  /// be answered, so it takes a note.
  bool get takesNote => allowNotes || !yesNo;

  /// [choice] as this question spells it, so "yes" from the sheet still
  /// selects "Yes"; a choice it no longer offers is kept as given.
  String? optionFor(String? choice) {
    if (choice == null) return null;
    final wanted = choice.trim().toLowerCase();
    for (final option in options) {
      if (option.toLowerCase() == wanted) return option;
    }
    return choice;
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'text': text,
        'active': active,
        'yesNo': yesNo,
        'allowNotes': allowNotes,
        'options': options,
      };

  @override
  bool operator ==(Object other) =>
      other is Question &&
      other.id == id &&
      other.text == text &&
      other.active == active &&
      other.yesNo == yesNo &&
      other.allowNotes == allowNotes &&
      listEquals(other.options, options);

  @override
  int get hashCode => Object.hash(
      id, text, active, yesNo, allowNotes, Object.hashAll(options));
}
