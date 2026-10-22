import 'package:four_questions/model/local_day.dart';

/// "Hovi", "Hovi and Sam", "Hovi, Sam and Lee".
String listOfNames(List<String> names) => switch (names.length) {
      0 => '',
      1 => names.single,
      _ => '${names.sublist(0, names.length - 1).join(', ')} '
          'and ${names.last}',
    };

String answeredBy(List<String> names) => 'Answered by ${listOfNames(names)}';

String answeredByToday(List<String> names) => '${answeredBy(names)} today';

/// "Yesterday", "Monday 19 October", or "Friday 12 December 2025" in
/// another year than [today]'s.
String dayName(LocalDay day, LocalDay today) {
  if (day == today.addDays(-1)) return 'Yesterday';
  return day.year == today.year ? day.spoken : '${day.spoken} ${day.year}';
}

/// "1 question", "3 questions".
String questionCount(int count) =>
    count == 1 ? '1 question' : '$count questions';
