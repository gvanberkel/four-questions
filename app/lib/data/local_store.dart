import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:four_questions/auth/account.dart';
import 'package:four_questions/model/answer.dart';
import 'package:four_questions/model/local_day.dart';
import 'package:four_questions/model/question.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What the app keeps on the device (localStorage on the web): enough to
/// draw every screen before the sheet answers, and the answers still waiting
/// to reach it.
class LocalStore {
  LocalStore(this._prefs);

  static Future<LocalStore> open() async =>
      LocalStore(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  static const _account = 'fq.account';
  static const _token = 'fq.token';
  static const _editor = 'fq.editor';
  static const _questions = 'fq.questions';
  static const _answersDay = 'fq.answersDay';
  static const _answers = 'fq.answers';
  static const _people = 'fq.people';
  static const _pending = 'fq.pending';
  static const _pendingName = 'fq.pendingName';
  static const _themeMode = 'fq.themeMode';

  Object? _json(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  void _put(String key, Object? value) {
    if (value == null) {
      _prefs.remove(key);
    } else {
      _prefs.setString(key, jsonEncode(value));
    }
  }

  /// The person last signed in on this device, kept after their token expires
  /// so Google can be asked for a new one without a prompt.
  Account? get account {
    final json = _json(_account);
    return json is Map ? Account.fromJson(json.cast()) : null;
  }

  set account(Account? value) => _put(_account, value?.toJson());

  AccessToken? get token {
    final json = _json(_token);
    return json is Map ? AccessToken.fromJson(json.cast()) : null;
  }

  set token(AccessToken? value) => _put(_token, value?.toJson());

  /// The email of the account last confirmed able to edit the sheet.
  String? get confirmedEditor => _prefs.getString(_editor);
  set confirmedEditor(String? email) => email == null
      ? _prefs.remove(_editor)
      : _prefs.setString(_editor, email);

  List<Question>? get questions {
    final json = _json(_questions);
    if (json is! List) return null;
    return [for (final q in json) Question.fromJson((q as Map).cast())];
  }

  set questions(List<Question>? value) =>
      _put(_questions, value?.map((q) => q.toJson()).toList());

  /// Everyone's answers for [day], or nothing when the store holds another
  /// day's.
  List<Answer> answersFor(LocalDay day) {
    if (_prefs.getString(_answersDay) != day.iso) return const [];
    return _answerList(_answers);
  }

  void putAnswers(LocalDay day, List<Answer> answers) {
    _prefs.setString(_answersDay, day.iso);
    _put(_answers, answers.map((a) => a.toJson()).toList());
  }

  Map<String, String> get people {
    final json = _json(_people);
    return json is Map ? json.cast<String, String>() : const {};
  }

  set people(Map<String, String> value) => _put(_people, value);

  /// Answers saved here but not yet on the sheet, newest per question.
  List<Answer> get pending => _answerList(_pending);
  set pending(List<Answer> value) =>
      _put(_pending, value.map((a) => a.toJson()).toList());

  /// The name the person chose, until the People sheet has it.
  String? get pendingName => _prefs.getString(_pendingName);
  set pendingName(String? name) => name == null
      ? _prefs.remove(_pendingName)
      : _prefs.setString(_pendingName, name);

  ThemeMode get themeMode => ThemeMode.values.firstWhere(
        (m) => m.name == _prefs.getString(_themeMode),
        orElse: () => ThemeMode.system,
      );

  set themeMode(ThemeMode mode) => _prefs.setString(_themeMode, mode.name);

  List<Answer> _answerList(String key) {
    final json = _json(key);
    if (json is! List) return const [];
    final answers = <Answer>[];
    for (final a in json) {
      try {
        answers.add(Answer.fromJson((a as Map).cast()));
      } on Object {
        // A row from an older format is dropped rather than failing the load.
      }
    }
    return answers;
  }

  /// Everything about the person and their sheet; the theme stays.
  void forgetPerson() {
    for (final key in [
      _account, _token, _editor, _questions, _answersDay, _answers, _people, //
      _pending, _pendingName,
    ]) {
      _prefs.remove(key);
    }
  }
}
