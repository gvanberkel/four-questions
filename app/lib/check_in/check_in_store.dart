import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:four_questions/auth/account.dart';
import 'package:four_questions/check_in/answer_history.dart';
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
/// background. Earlier days' answers come with each refresh and are kept for
/// the session only.
///
/// The questions are answered for [answering]: today, unless yesterday's
/// were chosen instead with [answerFor].
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

  /// Yesterday, while its questions are being answered; otherwise null.
  LocalDay? _answering;
  List<Question>? _questions;
  Map<String, Answer> _answers = {};
  Map<String, Answer> _earlier = {};
  AnswerHistory? _history;
  Map<String, String> _people = {};
  final Map<String, Answer> _pending = {};
  String? _pendingName;
  String? _chosenName;

  bool _fromSheet = false;
  bool _earlierFromSheet = false;
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

  /// Today.
  LocalDay get day => _day;

  LocalDay get yesterday => _day.addDays(-1);

  /// The day the questions are being answered for: today, or yesterday.
  LocalDay get answering => _answering ?? _day;

  /// Whether yesterday's questions are being answered rather than today's.
  bool get answeringYesterday => _answering != null;

  /// Answers the questions for [day] from now on: today or yesterday.
  void answerFor(LocalDay day) {
    final next = day == yesterday ? day : null;
    if (next == _answering) return;
    _answering = next;
    _notify();
  }

  /// Whether there is anything to draw — from the device or the sheet.
  bool get hasData => _questions != null;

  /// Whether the sheet itself has answered this session.
  bool get fromSheet => _fromSheet;

  bool get refreshing => _refreshing;

  /// Why the last refresh failed, while it has not since succeeded.
  Object? get refreshError => _refreshError;

  SyncStatus get sync => _sync;

  /// Whether earlier days' answers have been read from the sheet this
  /// session; until they have, [history] holds only what this device has
  /// yet to send.
  bool get hasHistory => _earlierFromSheet;

  /// Everyone's answers on the days before today.
  AnswerHistory get history => _history ??=
      AnswerHistory(questions: [...?_questions], answers: _earlier.values);

  /// The active questions, in sheet order.
  List<Question> get questions =>
      [...?_questions?.where((q) => q.active)];

  /// Everyone's answers on [day], wherever they are kept.
  Map<String, Answer> _keptFor(LocalDay day) =>
      day == _day ? _answers : _earlier;

  Iterable<Answer> get _answeringAnswers {
    final day = answering;
    return _keptFor(day).values.where((a) => a.day == day);
  }

  Answer? _onDay(LocalDay day, String questionId, String email) =>
      _keptFor(day)[Answer.keyOf(day, questionId, email)];

  /// My answer for the day being answered.
  Answer? mine(String questionId) => answerOf(questionId, me.email);

  Answer? answerOf(String questionId, String email) =>
      _onDay(answering, questionId, email);

  bool isAnswered(Question question) =>
      mine(question.id)?.answers(question) ?? false;

  int get answeredCount => questions.where(isAnswered).length;

  bool get allAnswered => hasData && questions.every(isAnswered);

  /// How many of the questions I answered on [day].
  int answeredOn(LocalDay day) => questions
      .where((q) => _onDay(day, q.id, me.email)?.answers(q) ?? false)
      .length;

  /// Whether yesterday's questions are worth offering: I have answered on
  /// an earlier day, so I keep up with them, but not all of yesterday's.
  bool get yesterdayOpen =>
      hasData &&
      questions.isNotEmpty &&
      answeredOn(yesterday) < questions.length &&
      _earlier.values.any((a) =>
          a.isBy(me.email) && a.day.compareTo(yesterday) <= 0);

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

  /// The names of the other people who answered [question] on the day
  /// being answered.
  List<String> othersWhoAnswered(Question question) => [
        for (final a in _answeringAnswers)
          if (a.questionId == question.id &&
              !a.isBy(me.email) &&
              a.answers(question))
            nameOf(a.email),
      ];

  /// What the other people who answered [question] on the day being
  /// answered said, most recent first, at most [limit] of them. The sheet keeps answers in the order
  /// they were first given, and so does the store.
  List<({String name, Answer answer})> othersAnswers(
    Question question, {
    int limit = 5,
  }) =>
      [
        for (final a in _answeringAnswers.toList().reversed)
          if (a.questionId == question.id &&
              !a.isBy(me.email) &&
              a.answers(question))
            (name: nameOf(a.email), answer: a),
      ].take(limit).toList();

  /// The names of everyone else who answered anything on [day], in the
  /// order they first answered.
  List<String> othersOn(LocalDay day) {
    final active = {for (final q in questions) q.id: q};
    final emails = <String>{};
    for (final a in _keptFor(day).values) {
      final question = active[a.questionId];
      if (a.day != day || a.isBy(me.email) || question == null) continue;
      if (a.answers(question)) emails.add(a.email.toLowerCase());
    }
    return [for (final e in emails) nameOf(e)];
  }

  /// Everyone else who answered on the day being answered, with how many of
  /// the questions.
  List<({String email, String name, int answered})> get othersOnDay {
    final counts = <String, int>{};
    final active = {for (final q in questions) q.id: q};
    for (final a in _answeringAnswers) {
      final question = active[a.questionId];
      if (a.isBy(me.email) || question == null || !a.answers(question)) {
        continue;
      }
      counts.update(a.email.toLowerCase(), (n) => n + 1, ifAbsent: () => 1);
    }
    return [
      for (final e in counts.entries)
        (email: e.key, name: nameOf(e.key), answered: e.value),
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
    // The device keeps one day's answers: today's, or an earlier day's when
    // the sheet has not been read since, which says whether I answered then.
    final kept = local.keptAnswers;
    _answers = {for (final a in kept) if (a.day == _day) a.key: a};
    _earlier = {
      for (final a in kept)
        if (a.day.compareTo(_day) < 0) a.key: a,
    };
    _history = null;
    _overlay(_pending.values);
  }

  void _overlay(Iterable<Answer> answers) {
    for (final a in answers) {
      if (a.day == _day) {
        _answers[a.key] = a;
      } else if (a.day.compareTo(_day) < 0) {
        _earlier[a.key] = a;
        _history = null;
      }
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
      _earlier = {for (final a in snapshot.earlier) a.key: a};
      _history = null;
      if (_savesCompleted != savesBefore) {
        _overlay(_recentlySaved.values);
      } else {
        _recentlySaved.clear();
      }
      _overlay(_pending.values);
      _fromSheet = true;
      _earlierFromSheet = true;
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
    if (_day.compareTo(today) < 0) _earlier.addAll(_answers);
    _day = today;
    _answering = null;
    _history = null;
    _recentlySaved.clear();
    _answers = {for (final a in local.answersFor(_day)) a.key: a};
    _overlay(_pending.values);
    _notify();
    unawaited(refresh());
  }

  void setChoice(Question question, String choice) {
    _record(question, (a) => a.copyWith(choice: choice));
    unawaited(flush());
  }

  void setNote(Question question, String note) {
    _record(question, (a) => a.copyWith(note: note));
    _flushTimer?.cancel();
    _flushTimer = Timer(noteDelay, () => unawaited(flush()));
  }

  void _record(Question question, Answer Function(Answer) change) {
    final day = answering;
    final current = mine(question.id) ??
        Answer(day: day, questionId: question.id, email: me.email);
    final next = change(current);
    if (next == current) return;

    _keptFor(day)[next.key] = next;
    if (day != _day) _history = null;
    _pending[next.key] = next;
    local.pending = _pending.values.toList();
    if (day == _day) local.putAnswers(_day, _answers.values.toList());
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
