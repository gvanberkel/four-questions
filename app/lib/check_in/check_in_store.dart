import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:four_questions/auth/account.dart';
import 'package:four_questions/data/local_store.dart';
import 'package:four_questions/data/sheets_gateway.dart';
import 'package:four_questions/model/answer.dart';
import 'package:four_questions/model/local_day.dart';
import 'package:four_questions/model/question.dart';

enum SyncStatus {
  /// Everything on this device is on the sheet.
  idle,

  /// Answers are on their way to the sheet.
  saving,

  /// The sheet could not be reached; answers are safe here and will be
  /// retried.
  offline,

  /// Google refused the token; nothing reaches the sheet until the person is
  /// signed in again.
  signedOut,
}

/// Today's questions and answers, local first: everything is drawn from the
/// device at once and refreshed from the sheet when it answers; answers are
/// kept on the device the moment they are given and sent to the sheet in the
/// background.
class CheckInStore extends ChangeNotifier {
  CheckInStore({
    required this.local,
    required this.gateway,
    required this.me,
    LocalDay Function()? today,
    this.noteDelay = const Duration(milliseconds: 1200),
    this.onAuthExpired,
    this.onAccessDenied,
  })  : _today = today ?? (() => LocalDay.of(DateTime.now())),
        _day = (today ?? (() => LocalDay.of(DateTime.now())))();

  final LocalStore local;
  final SheetsGateway gateway;
  final Account me;
  final LocalDay Function() _today;

  /// How long typing must pause before a note is sent.
  final Duration noteDelay;

  final VoidCallback? onAuthExpired;
  final ValueChanged<String>? onAccessDenied;

  LocalDay _day;
  List<Question>? _questions;
  Map<String, Answer> _answers = {};
  Map<String, String> _people = {};
  final Map<String, Answer> _pending = {};
  String? _pendingName;
  String? _chosenName;

  bool _fromSheet = false;
  bool _refreshing = false;
  Object? _refreshError;
  SyncStatus _sync = SyncStatus.idle;

  // Saves that finished while a refresh was in flight are laid over its
  // result, which may have been read before they landed.
  int _savesCompleted = 0;
  final Map<String, Answer> _recentlySaved = {};

  Timer? _flushTimer;
  Future<void>? _flushing;
  bool _flushAgain = false;
  Duration _retryDelay = _firstRetry;
  static const _firstRetry = Duration(seconds: 2);
  static const _lastRetry = Duration(minutes: 1);
  bool _disposed = false;

  LocalDay get day => _day;

  /// Whether there is anything to draw — from the device or the sheet.
  bool get hasData => _questions != null;

  /// Whether the sheet itself has answered this session.
  bool get fromSheet => _fromSheet;

  bool get refreshing => _refreshing;

  /// Why the last refresh failed, while it has not since succeeded.
  Object? get refreshError => _refreshError;

  SyncStatus get sync => _sync;

  /// The active questions, in sheet order.
  List<Question> get questions =>
      [...?_questions?.where((q) => q.active)];

  Answer? mine(String questionId) =>
      _answers[Answer.keyOf(_day, questionId, me.email)];

  bool isAnswered(Question question) =>
      mine(question.id)?.answers(question) ?? false;

  int get answeredCount => questions.where(isAnswered).length;

  bool get allAnswered => hasData && questions.every(isAnswered);

  String nameOf(String email) =>
      _people[email.toLowerCase()] ?? email.split('@').first;

  String get myName =>
      _people[me.email.toLowerCase()] ??
      _pendingName ??
      _chosenName ??
      me.firstName;

  /// A first sign-in: the People sheet has no name for this account yet.
  bool get needsName =>
      _fromSheet &&
      _chosenName == null &&
      _pendingName == null &&
      !_people.containsKey(me.email.toLowerCase());

  /// The names of the other people who answered [question] today.
  List<String> othersWhoAnswered(Question question) => [
        for (final a in _answers.values)
          if (a.questionId == question.id &&
              !a.isBy(me.email) &&
              a.answers(question))
            nameOf(a.email),
      ];

  /// Everyone else who answered today, with how many of today's questions.
  List<({String name, int answered})> get othersToday {
    final counts = <String, int>{};
    final active = {for (final q in questions) q.id: q};
    for (final a in _answers.values) {
      final question = active[a.questionId];
      if (a.isBy(me.email) || question == null || !a.answers(question)) {
        continue;
      }
      counts.update(a.email.toLowerCase(), (n) => n + 1, ifAbsent: () => 1);
    }
    return [
      for (final e in counts.entries) (name: nameOf(e.key), answered: e.value),
    ];
  }

  /// Draws from the device, then asks the sheet.
  Future<void> start() {
    _readLocal();
    _notify();
    unawaited(flush());
    return refresh();
  }

  void _readLocal() {
    _questions = local.questions;
    _people = Map.of(local.people);
    _pendingName = local.pendingName;
    _pending
      ..clear()
      ..addEntries(local.pending.map((a) => MapEntry(a.key, a)));
    _answers = {for (final a in local.answersFor(_day)) a.key: a};
    _overlay(_pending.values);
  }

  void _overlay(Iterable<Answer> answers) {
    for (final a in answers) {
      if (a.day == _day) _answers[a.key] = a;
    }
  }

  Future<void> refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    _notify();

    final day = _day;
    final savesBefore = _savesCompleted;
    try {
      final snapshot = await gateway.load(day);
      if (_disposed || day != _day) return;

      _questions = snapshot.questions;
      _people = Map.of(snapshot.people);
      _answers = {for (final a in snapshot.answers) a.key: a};
      if (_savesCompleted != savesBefore) {
        _overlay(_recentlySaved.values);
      } else {
        _recentlySaved.clear();
      }
      _overlay(_pending.values);
      _fromSheet = true;
      _refreshError = null;

      local
        ..questions = _questions
        ..people = _people
        ..putAnswers(_day, _answers.values.toList());
    } on SheetsAuthException catch (e) {
      _refreshError = e;
      _setSync(SyncStatus.signedOut);
      onAuthExpired?.call();
    } on SheetsAccessException catch (e) {
      _refreshError = e;
      onAccessDenied?.call(e.message);
    } on Object catch (e) {
      _refreshError = e;
    } finally {
      _refreshing = false;
      _notify();
    }
  }

  /// Starts a new day if the date has moved on since the store last looked.
  void checkDay() {
    final today = _today();
    if (today == _day) return;
    _day = today;
    _recentlySaved.clear();
    _answers = {for (final a in local.answersFor(_day)) a.key: a};
    _overlay(_pending.values);
    _notify();
    unawaited(refresh());
  }

  void setYes(Question question, bool yes) {
    _record(question, (a) => a.copyWith(yes: yes));
    unawaited(flush());
  }

  void setNote(Question question, String note) {
    _record(question, (a) => a.copyWith(note: note));
    _flushTimer?.cancel();
    _flushTimer = Timer(noteDelay, () => unawaited(flush()));
  }

  void _record(Question question, Answer Function(Answer) change) {
    final current = mine(question.id) ??
        Answer(day: _day, questionId: question.id, email: me.email);
    final next = change(current);
    if (next == current) return;

    _answers[next.key] = next;
    _pending[next.key] = next;
    local
      ..pending = _pending.values.toList()
      ..putAnswers(_day, _answers.values.toList());
    if (_sync == SyncStatus.idle) _sync = SyncStatus.saving;
    _notify();
  }

  void saveName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _chosenName = trimmed;
    _pendingName = trimmed;
    _people[me.email.toLowerCase()] = trimmed;
    local
      ..pendingName = trimmed
      ..people = _people;
    _notify();
    unawaited(flush());
  }

  /// Sends whatever is waiting. Safe to call at any time; calls made while a
  /// send is in flight are folded into one more send after it.
  Future<void> flush() {
    _flushTimer?.cancel();
    final inFlight = _flushing;
    if (inFlight != null) {
      _flushAgain = true;
      return inFlight;
    }
    final run = _send();
    _flushing = run;
    return run.whenComplete(() {
      _flushing = null;
      if (_flushAgain && !_disposed) {
        _flushAgain = false;
        unawaited(flush());
      }
    });
  }

  Future<void> _send() async {
    final name = _pendingName;
    final batch = _pending.values.toList();
    if (batch.isEmpty && name == null) {
      if (_sync != SyncStatus.signedOut) _setSync(SyncStatus.idle);
      return;
    }

    _setSync(SyncStatus.saving);
    try {
      if (name != null) {
        await gateway.savePerson(me.email, name);
        if (_pendingName == name) {
          _pendingName = null;
          local.pendingName = null;
        }
      }
      if (batch.isNotEmpty) await gateway.saveAnswers(batch);
      if (_disposed) return;

      for (final a in batch) {
        if (_pending[a.key] == a) _pending.remove(a.key);
        _recentlySaved[a.key] = a;
      }
      _savesCompleted++;
      local.pending = _pending.values.toList();
      _retryDelay = _firstRetry;

      final more = _pending.isNotEmpty || _pendingName != null;
      if (more) _flushAgain = true;
      _setSync(more ? SyncStatus.saving : SyncStatus.idle);
    } on SheetsAuthException {
      _flushAgain = false;
      _setSync(SyncStatus.signedOut);
      onAuthExpired?.call();
    } on SheetsAccessException catch (e) {
      _flushAgain = false;
      _setSync(SyncStatus.offline);
      onAccessDenied?.call(e.message);
    } on Object {
      // The retry timer owns the next attempt, not a call made meanwhile.
      _flushAgain = false;
      _setSync(SyncStatus.offline);
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    _flushTimer?.cancel();
    _flushTimer = Timer(_retryDelay, () => unawaited(flush()));
    final next = _retryDelay * 2;
    _retryDelay = next > _lastRetry ? _lastRetry : next;
  }

  /// Signed in again: the sheet can be tried at once.
  void resume() {
    if (_sync == SyncStatus.signedOut) _sync = SyncStatus.idle;
    _retryDelay = _firstRetry;
    unawaited(flush());
    unawaited(refresh());
  }

  void _setSync(SyncStatus status) {
    if (_sync == status) return;
    _sync = status;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _flushTimer?.cancel();
    super.dispose();
  }
}
