import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:four_questions/auth/account.dart';
import 'package:four_questions/check_in/check_in_store.dart';
import 'package:four_questions/data/demo_sheets_gateway.dart';
import 'package:four_questions/data/local_store.dart';
import 'package:four_questions/data/sheets_gateway.dart';
import 'package:four_questions/model/answer.dart';
import 'package:four_questions/model/local_day.dart';
import 'package:four_questions/model/question.dart';
import 'package:shared_preferences/shared_preferences.dart';

const today = LocalDay(2026, 10, 8);
const me = Account(email: 'greg@example.com', name: 'Greg van Berkel', givenName: 'Greg');

/// A demo sheet whose loads and saves wait until the test lets them go.
class GatedGateway extends DemoSheetsGateway {
  GatedGateway() : super(latency: Duration.zero, today: today);

  Completer<void>? loadGate;
  Completer<void>? saveGate;
  final saved = <List<Answer>>[];

  @override
  Future<SheetSnapshot> load(LocalDay day) async {
    await loadGate?.future;
    return super.load(day);
  }

  @override
  Future<void> saveAnswers(List<Answer> list) async {
    await saveGate?.future;
    await super.saveAnswers(list);
    saved.add(list);
  }
}

void main() {
  late LocalStore local;
  late GatedGateway sheet;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    local = await LocalStore.open();
    sheet = GatedGateway();
  });

  CheckInStore store({Duration noteDelay = Duration.zero}) => CheckInStore(
        local: local,
        gateway: sheet,
        me: me,
        today: () => today,
        noteDelay: noteDelay,
      );

  Question q(String id) => sheet.questions.firstWhere((q) => q.id == id);

  test('draws from the device before the sheet answers', () async {
    local
      ..questions = [const Question(id: '1', text: 'Cached question?')]
      ..putAnswers(today, [
        const Answer(day: today, questionId: '1', email: 'greg@example.com', yes: true),
      ]);
    sheet.loadGate = Completer();

    final s = store();
    final started = s.start();

    expect(s.hasData, isTrue);
    expect(s.fromSheet, isFalse);
    expect(s.questions.single.text, 'Cached question?');
    expect(s.allAnswered, isTrue);

    sheet.loadGate!.complete();
    await started;

    expect(s.fromSheet, isTrue);
    expect(s.questions.length, 4, reason: 'the inactive question is left out');
    expect(s.allAnswered, isFalse);
    expect(local.questions!.length, 5, reason: 'the sheet is cached');
  });

  test('an answer is kept at once and reaches the sheet in the background',
      () async {
    final s = store();
    await s.start();
    sheet.saveGate = Completer();

    s.setYes(q('2'), true);

    expect(s.isAnswered(q('2')), isTrue);
    expect(s.sync, SyncStatus.saving);
    expect(local.pending.single.yes, isTrue,
        reason: 'safe on the device before the sheet has it');

    sheet.saveGate!.complete();
    await s.flush();

    expect(sheet.answers.where((a) => a.isBy(me.email)).single.yes, isTrue);
    expect(local.pending, isEmpty);
    expect(s.sync, SyncStatus.idle);
  });

  test('changes made while a save is in flight are sent after it, coalesced',
      () async {
    final s = store();
    await s.start();
    sheet.saveGate = Completer();

    s.setYes(q('1'), true);
    final first = s.flush();
    s
      ..setYes(q('1'), false)
      ..setNote(q('1'), 'went to the park')
      ..setYes(q('2'), true);

    sheet.saveGate!.complete();
    await first;
    await s.flush();
    await pumpEventQueue();

    expect(sheet.saved.length, 2);
    expect(sheet.saved[1].length, 2, reason: 'one row per question');
    final mine = sheet.answers.where((a) => a.isBy(me.email)).toList();
    expect(mine.firstWhere((a) => a.questionId == '1').yes, isFalse);
    expect(mine.firstWhere((a) => a.questionId == '1').note, 'went to the park');
    expect(local.pending, isEmpty);
  });

  test('offline answers wait on the device and are sent on the next try',
      () async {
    final s = store();
    await s.start();
    sheet.reachable = false;

    s.setYes(q('3'), true);
    await s.flush();

    expect(s.sync, SyncStatus.offline);
    expect(local.pending.single.questionId, '3');

    sheet.reachable = true;
    await s.flush();

    expect(s.sync, SyncStatus.idle);
    expect(local.pending, isEmpty);
  });

  test('pending answers survive a restart and win over the sheet', () async {
    final first = store();
    await first.start();
    sheet.reachable = false;
    first.setYes(q('1'), false);
    await first.flush();
    first.dispose();

    sheet.reachable = true;
    sheet.loadGate = Completer();
    final second = store();
    final started = second.start();
    expect(second.mine('1')!.yes, isFalse);

    sheet.loadGate!.complete();
    await started;
    await second.flush();

    expect(second.mine('1')!.yes, isFalse);
    expect(sheet.answers.where((a) => a.isBy(me.email)).single.yes, isFalse);
  });

  test('a refresh read before a save landed does not undo it', () async {
    final s = store();
    await s.start();

    sheet.loadGate = Completer();
    final refresh = s.refresh();
    s.setYes(q('4'), true);
    await s.flush();
    sheet.answers.clear(); // the refresh "read" the sheet before the save
    sheet.loadGate!.complete();
    await refresh;

    expect(s.mine('4')?.yes, isTrue);
  });

  test('who else answered, by the name on the People sheet', () async {
    sheet.answers.add(const Answer(
      day: today,
      questionId: '1',
      email: 'sam@example.com',
      note: 'only a note, on a yes/no question',
    ));
    final s = store();
    await s.start();

    expect(s.othersWhoAnswered(q('1')), ['Hovi']);
    expect(s.othersWhoAnswered(q('2')), isEmpty);
    expect(s.othersToday.single, (name: 'Hovi', answered: 1));
  });

  test('a first sign-in needs a name; choosing one saves it', () async {
    final s = store();
    await s.start();

    expect(s.needsName, isTrue);
    expect(s.myName, 'Greg');

    s.saveName('  Gregory ');
    expect(s.needsName, isFalse);
    expect(s.myName, 'Gregory');
    await s.flush();

    expect(sheet.people['greg@example.com'], 'Gregory');
    expect(local.pendingName, isNull);
  });

  test('typing waits for a pause before it is sent', () async {
    final s = store(noteDelay: const Duration(milliseconds: 50));
    await s.start();

    s
      ..setNote(q('2'), 'a')
      ..setNote(q('2'), 'ab')
      ..setNote(q('2'), 'abc');
    expect(sheet.saved, isEmpty);

    await Future<void>.delayed(const Duration(milliseconds: 80));
    await pumpEventQueue();

    expect(sheet.saved.single.single.note, 'abc');
  });

  test('a new day starts empty', () async {
    var day = today;
    final s = CheckInStore(
      local: local,
      gateway: sheet,
      me: me,
      today: () => day,
    );
    await s.start();
    s.setYes(q('1'), true);
    await s.flush();
    expect(s.answeredCount, 1);

    day = const LocalDay(2026, 10, 9);
    s.checkDay();
    await pumpEventQueue();

    expect(s.day, day);
    expect(s.answeredCount, 0);
  });
}
