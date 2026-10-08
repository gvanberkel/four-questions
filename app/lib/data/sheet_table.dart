import 'package:four_questions/model/answer.dart';
import 'package:four_questions/model/local_day.dart';
import 'package:four_questions/model/question.dart';

/// A column found by its header, so the sheet's columns can be renamed within
/// [names] or reordered without breaking the app. [fallback] is where it sits
/// when no header matches.
class SheetColumn {
  const SheetColumn(this.names, this.fallback);

  final List<String> names;
  final int fallback;
}

abstract final class QuestionColumns {
  static const id = SheetColumn(['Question ID', 'ID'], 0);
  static const text = SheetColumn(['Question'], 1);
  static const active = SheetColumn(['Active'], 2);
  static const yesNo = SheetColumn(['Yes/No', 'Yes No'], 3);
  static const allowNotes = SheetColumn(['Allow notes', 'Notes'], 4);
}

abstract final class AnswerColumns {
  static const date = SheetColumn(['Date', 'Day'], 0);
  static const questionId = SheetColumn(['Question ID', 'Question'], 1);
  static const email = SheetColumn(['Answered By', 'Person', 'Email'], 2);
  static const yesNo = SheetColumn(['Yes/No', 'Yes No', 'Answer'], 3);
  static const note = SheetColumn(['Note', 'Notes'], 4);

  static const all = [date, questionId, email, yesNo, note];
  static const headers = ['Date', 'Question ID', 'Answered By', 'Yes/No', 'Note'];
}

abstract final class PeopleColumns {
  static const email = SheetColumn(['Email', 'Answered By'], 0);
  static const name = SheetColumn(['Name', 'First name'], 1);

  static const all = [email, name];
  static const headers = ['Email', 'Name'];
}

/// A sheet's values as the Sheets API returns them (rows of cells, header
/// first), read with `UNFORMATTED_VALUE` and `SERIAL_NUMBER` dates.
class SheetTable {
  SheetTable(List<List<Object?>> values)
      : _header = values.isEmpty ? const [] : values.first,
        _rows = values.length <= 1 ? const [] : values.sublist(1);

  final List<Object?> _header;
  final List<List<Object?>> _rows;

  static String _normalise(Object? header) =>
      '$header'.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');

  int indexOf(SheetColumn column) {
    final wanted = column.names.map(_normalise).toList();
    for (final name in wanted) {
      final index = _header.indexWhere((h) => _normalise(h) == name);
      if (index >= 0) return index;
    }
    return column.fallback;
  }

  /// Rows under the header with their 1-based row number on the sheet.
  Iterable<({int rowNumber, List<Object?> cells})> get rows sync* {
    for (final (i, cells) in _rows.indexed) {
      yield (rowNumber: i + 2, cells: cells);
    }
  }

  /// A row laid out in this sheet's column order. Cells for columns not in
  /// [values] are null, which the Sheets API leaves untouched on update.
  List<Object?> layOut(Map<SheetColumn, Object?> values) {
    final indexed = {for (final e in values.entries) indexOf(e.key): e.value};
    final width = indexed.keys.fold(0, (w, i) => i + 1 > w ? i + 1 : w);
    return [for (var i = 0; i < width; i++) indexed[i]];
  }

  int width(List<SheetColumn> columns) =>
      columns.map(indexOf).fold(0, (w, i) => i + 1 > w ? i + 1 : w);
}

/// Turning cells into values and values into cells.
abstract final class Cells {
  static Object? at(List<Object?> cells, int index) =>
      index < cells.length ? cells[index] : null;

  static String text(Object? cell) {
    if (cell == null) return '';
    if (cell is double && cell == cell.roundToDouble()) {
      return cell.toInt().toString();
    }
    return '$cell'.trim();
  }

  static bool? flag(Object? cell) {
    if (cell is bool) return cell;
    return switch (text(cell).toLowerCase()) {
      'yes' || 'y' || 'true' || '1' => true,
      'no' || 'n' || 'false' || '0' => false,
      _ => null,
    };
  }

  static LocalDay? day(Object? cell) {
    if (cell is num) return LocalDay.fromSheetsSerial(cell);
    return LocalDay.tryParse(text(cell));
  }

  /// A question id goes back as a number when it is one, so it matches the
  /// Questions sheet's own ids.
  static Object id(String id) => int.tryParse(id) ?? id;

  /// Notes are written as the person typed them: a leading `=`, `+`, `-` or
  /// `@` would otherwise make Sheets read the note as a formula.
  static String literal(String text) =>
      RegExp(r'^[=+\-@]').hasMatch(text) ? "'$text" : text;

  static String yesNo(bool? yes) => switch (yes) {
        true => 'Yes',
        false => 'No',
        null => '',
      };
}

List<Question> parseQuestions(SheetTable table) {
  final id = table.indexOf(QuestionColumns.id);
  final text = table.indexOf(QuestionColumns.text);
  final active = table.indexOf(QuestionColumns.active);
  final yesNo = table.indexOf(QuestionColumns.yesNo);
  final allowNotes = table.indexOf(QuestionColumns.allowNotes);

  return [
    for (final row in table.rows)
      if (Cells.text(Cells.at(row.cells, id)).isNotEmpty &&
          Cells.text(Cells.at(row.cells, text)).isNotEmpty)
        Question(
          id: Cells.text(Cells.at(row.cells, id)),
          text: Cells.text(Cells.at(row.cells, text)),
          active: Cells.flag(Cells.at(row.cells, active)) ?? false,
          yesNo: Cells.flag(Cells.at(row.cells, yesNo)) ?? false,
          allowNotes: Cells.flag(Cells.at(row.cells, allowNotes)) ?? false,
        ),
  ];
}

/// The answers on [day] with the sheet row each came from. When a person
/// answered a question twice that day, the later row wins.
Map<String, ({int rowNumber, Answer answer})> parseAnswers(
  SheetTable table, {
  required LocalDay day,
}) {
  final date = table.indexOf(AnswerColumns.date);
  final questionId = table.indexOf(AnswerColumns.questionId);
  final email = table.indexOf(AnswerColumns.email);
  final yesNo = table.indexOf(AnswerColumns.yesNo);
  final note = table.indexOf(AnswerColumns.note);

  final answers = <String, ({int rowNumber, Answer answer})>{};
  for (final row in table.rows) {
    if (Cells.day(Cells.at(row.cells, date)) != day) continue;
    final id = Cells.text(Cells.at(row.cells, questionId));
    final who = Cells.text(Cells.at(row.cells, email));
    if (id.isEmpty || who.isEmpty) continue;

    final answer = Answer(
      day: day,
      questionId: id,
      email: who,
      yes: Cells.flag(Cells.at(row.cells, yesNo)),
      note: Cells.text(Cells.at(row.cells, note)),
    );
    answers[answer.key] = (rowNumber: row.rowNumber, answer: answer);
  }
  return answers;
}

/// Email (lower case) to the name the person goes by, with its sheet row.
Map<String, ({int rowNumber, String name})> parsePeople(SheetTable table) {
  final email = table.indexOf(PeopleColumns.email);
  final name = table.indexOf(PeopleColumns.name);

  return {
    for (final row in table.rows)
      if (Cells.text(Cells.at(row.cells, email)).isNotEmpty &&
          Cells.text(Cells.at(row.cells, name)).isNotEmpty)
        Cells.text(Cells.at(row.cells, email)).toLowerCase(): (
          rowNumber: row.rowNumber,
          name: Cells.text(Cells.at(row.cells, name)),
        ),
  };
}

List<Object?> answerRow(SheetTable table, Answer answer) => table.layOut({
      AnswerColumns.date: answer.day.iso,
      AnswerColumns.questionId: Cells.id(answer.questionId),
      AnswerColumns.email: answer.email,
      AnswerColumns.yesNo: Cells.yesNo(answer.yes),
      AnswerColumns.note: Cells.literal(answer.note),
    });

List<Object?> personRow(SheetTable table, String email, String name) =>
    table.layOut({
      PeopleColumns.email: email,
      PeopleColumns.name: Cells.literal(name),
    });

/// "A", "B", … "Z", "AA" — the column letters of a 0-based index.
String columnLetter(int index) {
  var n = index + 1;
  var letters = '';
  while (n > 0) {
    final r = (n - 1) % 26;
    letters = String.fromCharCode(65 + r) + letters;
    n = (n - 1) ~/ 26;
  }
  return letters;
}
