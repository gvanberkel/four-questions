import 'dart:convert';

import 'package:four_questions/config.dart';
import 'package:four_questions/data/sheet_table.dart';
import 'package:four_questions/data/sheets_gateway.dart';
import 'package:four_questions/model/answer.dart';
import 'package:four_questions/model/local_day.dart';
import 'package:http/http.dart' as http;

/// [SheetsGateway] over the Google Sheets REST API (v4), authorised with the
/// signed-in person's access token.
class GoogleSheetsGateway implements SheetsGateway {
  GoogleSheetsGateway({
    required this.accessToken,
    http.Client? client,
    this.spreadsheetId = AppConfig.spreadsheetId,
  }) : _client = client ?? http.Client();

  final String? Function() accessToken;
  final String spreadsheetId;
  final http.Client _client;

  static const _questions = AppConfig.questionsSheet;
  static const _answers = AppConfig.answersSheet;
  static const _people = AppConfig.peopleSheet;

  static const _read = {
    'valueRenderOption': 'UNFORMATTED_VALUE',
    'dateTimeRenderOption': 'SERIAL_NUMBER',
  };

  @override
  Future<SheetSnapshot> load(LocalDay day) async {
    final (tables, people) = await (
      _batchGet(['$_questions!A:Z', '$_answers!A:Z']),
      _getOrNull('$_people!A:Z'),
    ).wait;

    return SheetSnapshot(
      questions: parseQuestions(tables[0]),
      answers: [
        for (final entry in parseAnswers(tables[1], day: day).values)
          entry.answer,
      ],
      people: {
        for (final e in parsePeople(people ?? SheetTable(const [])).entries)
          e.key: e.value.name,
      },
    );
  }

  @override
  Future<void> saveAnswers(List<Answer> answers) async {
    if (answers.isEmpty) return;
    final table = await _get('$_answers!A:Z');
    final width = table.width(AnswerColumns.all);
    final lastColumn = columnLetter(width - 1);

    final existing = <String, int>{};
    for (final day in answers.map((a) => a.day).toSet()) {
      for (final e in parseAnswers(table, day: day).entries) {
        existing[e.key] = e.value.rowNumber;
      }
    }

    final updates = <Map<String, Object?>>[];
    final appends = <List<Object?>>[];
    for (final answer in answers) {
      final row = answerRow(table, answer);
      final rowNumber = existing[answer.key];
      if (rowNumber == null) {
        appends.add(row);
      } else {
        updates.add({
          'range': '$_answers!A$rowNumber:$lastColumn$rowNumber',
          'values': [row],
        });
      }
    }

    await Future.wait([
      if (updates.isNotEmpty)
        _send('POST', 'values:batchUpdate', body: {
          'valueInputOption': 'USER_ENTERED',
          'data': updates,
        }),
      if (appends.isNotEmpty) _append('$_answers!A1:${lastColumn}1', appends),
    ]);
  }

  @override
  Future<void> savePerson(String email, String name) async {
    var table = await _getOrNull('$_people!A:Z');
    if (table == null) {
      await _send('POST', ':batchUpdate', body: {
        'requests': [
          {
            'addSheet': {
              'properties': {'title': _people},
            },
          },
        ],
      });
      await _send(
        'PUT',
        'values/${Uri.encodeComponent('$_people!A1:B1')}',
        query: {'valueInputOption': 'RAW'},
        body: {
          'values': [PeopleColumns.headers],
        },
      );
      table = SheetTable(const [PeopleColumns.headers]);
    }

    final row = personRow(table, email, name);
    final existing = parsePeople(table)[email.toLowerCase()];
    if (existing == null) {
      final lastColumn = columnLetter(table.width(PeopleColumns.all) - 1);
      await _append('$_people!A1:${lastColumn}1', [row]);
    } else {
      final r = existing.rowNumber;
      await _send(
        'PUT',
        'values/${Uri.encodeComponent('$_people!A$r:${columnLetter(row.length - 1)}$r')}',
        query: {'valueInputOption': 'USER_ENTERED'},
        body: {
          'values': [row],
        },
      );
    }
  }

  /// An empty batch update changes nothing but is refused unless the account
  /// may edit.
  @override
  Future<bool> canEdit() async {
    try {
      await _send('POST', ':batchUpdate', body: {'requests': <Object>[]});
      return true;
    } on SheetsAccessException {
      return false;
    } on SheetsUnavailableException catch (e) {
      // A request Sheets will not take says nothing about access; the first
      // write will tell.
      if (e.message.startsWith('400')) return true;
      rethrow;
    }
  }

  Future<List<SheetTable>> _batchGet(List<String> ranges) async {
    final json = await _send('GET', 'values:batchGet', query: {
      ..._read,
      'ranges': ranges,
    });
    final valueRanges = (json['valueRanges'] as List?) ?? const [];
    return [
      for (final range in valueRanges)
        SheetTable(_rows((range as Map)['values'])),
    ];
  }

  Future<SheetTable> _get(String range) async {
    final json = await _send(
      'GET',
      'values/${Uri.encodeComponent(range)}',
      query: _read,
    );
    return SheetTable(_rows(json['values']));
  }

  /// Null when the sheet the range names does not exist.
  Future<SheetTable?> _getOrNull(String range) async {
    try {
      return await _get(range);
    } on SheetsUnavailableException catch (e) {
      if (e.message.contains('Unable to parse range')) return null;
      rethrow;
    }
  }

  Future<void> _append(String range, List<List<Object?>> rows) => _send(
        'POST',
        'values/${Uri.encodeComponent(range)}:append',
        query: {
          'valueInputOption': 'USER_ENTERED',
          'insertDataOption': 'INSERT_ROWS',
        },
        body: {'values': rows},
      );

  static List<List<Object?>> _rows(Object? values) => [
        for (final row in (values as List?) ?? const [])
          List<Object?>.from(row as List),
      ];

  Future<Map<String, Object?>> _send(
    String method,
    String path, {
    Map<String, Object>? query,
    Object? body,
  }) async {
    final token = accessToken();
    if (token == null) throw const SheetsAuthException();

    final base = 'https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId';
    final uri = Uri.parse(path.startsWith(':') ? '$base$path' : '$base/$path')
        .replace(queryParameters: query);
    final request = http.Request(method, uri)
      ..headers['Authorization'] = 'Bearer $token';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    final http.Response response;
    try {
      response = await http.Response.fromStream(await _client.send(request));
    } catch (e) {
      throw SheetsUnavailableException('Could not reach Google Sheets: $e');
    }

    Map<String, Object?> json;
    try {
      json = response.body.isEmpty
          ? const {}
          : (jsonDecode(response.body) as Map).cast<String, Object?>();
    } on FormatException {
      json = const {};
    }
    if (response.statusCode < 300) return json;

    final error = json['error'];
    final message = error is Map ? '${error['message']}' : response.body;
    throw switch (response.statusCode) {
      401 => const SheetsAuthException(),
      403 || 404 => SheetsAccessException(message),
      _ => SheetsUnavailableException('${response.statusCode} $message'),
    };
  }
}
