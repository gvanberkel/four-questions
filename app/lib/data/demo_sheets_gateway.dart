import 'dart:convert';

import 'package:four_questions/data/sheets_gateway.dart';
import 'package:four_questions/model/answer.dart';
import 'package:four_questions/model/local_day.dart';
import 'package:four_questions/model/question.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A pretend sheet for `--dart-define=DEMO=true` and for tests: the real
/// questions, and Hovi has already answered the first one today. Given
/// [earlierDays], Hovi and the demo account also answered on that many days
/// before today. Given [prefs], it outlives a page reload, as the real sheet
/// would.
class DemoSheetsGateway implements SheetsGateway {
  DemoSheetsGateway({
    this.latency = const Duration(milliseconds: 700),
    LocalDay? today,
    this.prefs,
    int earlierDays = 0,
  }) : _day = today ?? LocalDay.of(DateTime.now()) {
    if (_restore()) return;
    for (var back = earlierDays; back > 0; back--) {
      _seedEarlier(_day.addDays(-back), back);
    }
    answers.add(Answer(
      day: _day,
      questionId: '1',
      email: 'hovi@example.com',
      yes: true,
    ));
  }

  final Duration latency;
  final SharedPreferences? prefs;
  final LocalDay _day;

  static const _key = 'demo.sheet';

  final questions = <Question>[
    const Question(id: '1', text: 'Have you had fun today?', allowNotes: true),
    const Question(
      id: '2',
      text: 'Have you taken a moment for yourself today?',
      allowNotes: true,
    ),
    const Question(
        id: '3', text: 'Have you eaten 3 meals today?', allowNotes: true),
    const Question(
      id: '4',
      text: 'Have you been gentle with your kids today?',
      allowNotes: true,
    ),
    const Question(
      id: '5',
      text: 'Is this question no longer used?',
      active: false,
      allowNotes: true,
    ),
  ];

  final answers = <Answer>[];
  final people = <String, String>{'hovi@example.com': 'Hovi'};

  bool editable = true;
  bool reachable = true;
  int saves = 0;

  static const _hoviNotes = [
    'Swings at the park',
    'A long bath',
    '',
    'Mostly',
    'Pancakes for supper',
  ];

  /// Hovi answers every question; the demo account skips every third day.
  void _seedEarlier(LocalDay day, int back) {
    for (final q in questions.where((q) => q.active)) {
      final n = back + int.parse(q.id);
      answers.add(Answer(
        day: day,
        questionId: q.id,
        email: 'hovi@example.com',
        yes: n % 4 != 0,
        note: _hoviNotes[n % _hoviNotes.length],
      ));
    }
    if (back % 3 == 0) return;
    for (final q in questions.where((q) => q.active && q.id != '4')) {
      final n = back * 2 + int.parse(q.id);
      answers.add(Answer(
        day: day,
        questionId: q.id,
        email: 'demo@example.com',
        yes: n % 3 != 0,
        note: n % 2 == 0 ? 'Some of it' : '',
      ));
    }
  }

  bool _restore() {
    final raw = prefs?.getString(_key);
    if (raw == null) return false;
    final json = (jsonDecode(raw) as Map).cast<String, Object?>();
    if (json['day'] != _day.iso) return false;
    answers.addAll([
      for (final a in json['answers']! as List)
        Answer.fromJson((a as Map).cast()),
    ]);
    people
      ..clear()
      ..addAll((json['people']! as Map).cast());
    return true;
  }

  void _persist() => prefs?.setString(
        _key,
        jsonEncode({
          'day': _day.iso,
          'answers': answers.map((a) => a.toJson()).toList(),
          'people': people,
        }),
      );

  Future<void> _wait() async {
    await Future<void>.delayed(latency);
    if (!reachable) {
      throw const SheetsUnavailableException('The demo sheet is offline.');
    }
  }

  @override
  Future<SheetSnapshot> load(LocalDay day) async {
    await _wait();
    return SheetSnapshot(
      questions: List.of(questions),
      answers: answers.where((a) => a.day == day).toList(),
      people: Map.of(people),
      earlier: answers.where((a) => a.day.compareTo(day) < 0).toList(),
    );
  }

  @override
  Future<void> saveAnswers(List<Answer> list) async {
    await _wait();
    saves++;
    for (final answer in list) {
      final i = answers.indexWhere((a) => a.key == answer.key);
      if (i >= 0) {
        answers[i] = answer;
      } else {
        answers.add(answer);
      }
    }
    _persist();
  }

  @override
  Future<void> savePerson(String email, String name) async {
    await _wait();
    people[email.toLowerCase()] = name;
    _persist();
  }

  @override
  Future<bool> canEdit() async {
    await _wait();
    return editable;
  }
}
