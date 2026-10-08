/// "Hovi", "Hovi and Sam", "Hovi, Sam and Lee".
String listOfNames(List<String> names) => switch (names.length) {
      0 => '',
      1 => names.single,
      _ => '${names.sublist(0, names.length - 1).join(', ')} '
          'and ${names.last}',
    };

String answeredByToday(List<String> names) =>
    'Answered by ${listOfNames(names)} today';

/// "1 question", "3 questions".
String questionCount(int count) =>
    count == 1 ? '1 question' : '$count questions';
