import 'package:action_design_system/action_design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:four_questions/app_controller.dart';
import 'package:four_questions/check_in/check_in_store.dart';
import 'package:four_questions/model/answer.dart';
import 'package:four_questions/model/local_day.dart';
import 'package:four_questions/model/question.dart';
import 'package:four_questions/screens/answer_view.dart';
import 'package:four_questions/screens/shell/signed_in_shell.dart';
import 'package:four_questions/screens/wording.dart';

/// An earlier day's answers, everyone's, one day at a time: to look back on,
/// not to change. Earlier and Later step between the days anyone answered;
/// Later from the most recent comes back to today.
class HistoryUi extends StatelessWidget {
  const HistoryUi({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final store = controller.store!;
    final history = store.history;
    final day = store.hasHistory ? controller.historyDay : null;
    final days = history.days;
    final index = day == null ? -1 : days.indexOf(day);
    final people = day == null ? const <String>[] : _people(store, day);

    return SignedInShell(
      controller: controller,
      child: ActionPage(
        // A fresh page per day, so each opens at its top.
        key: ValueKey(day?.iso),
        title: day == null ? 'Earlier days' : dayName(day, store.day),
        subtitle: day == null
            ? null
            : [
                if (day == store.day.addDays(-1)) day.spoken,
                answeredBy([for (final p in people) _name(store, p)]),
              ].join(' · '),
        width: ActionPageWidth.reading,
        backLabel: "Today's answers",
        onBack: controller.showSummary,
        footer: day == null
            ? null
            : ActionInline(
                justify: ActionInlineJustify.spaceBetween,
                children: [
                  ActionButton(
                    label: 'Earlier',
                    icon: ActionIcons.back,
                    variant: ActionButtonVariant.text,
                    onPressed: index + 1 < days.length
                        ? controller.earlierDay
                        : null,
                  ),
                  ActionButton(
                    label: index > 0 ? 'Later' : 'Today',
                    icon: index > 0 ? ActionIcons.forward : ActionIcons.today,
                    variant: ActionButtonVariant.outlined,
                    onPressed: controller.laterDay,
                  ),
                ],
              ),
        child: day == null
            ? _noDay(store)
            : ActionStack(
                rhythm: ActionRhythm.group,
                children: [
                  for (final entry in history.on(day))
                    _answerSet(store, entry.question, entry.answers, people),
                ],
              ),
      ),
    );
  }

  Widget _noDay(CheckInStore store) {
    if (store.hasHistory) {
      return const ActionEmptyState(
        icon: ActionIcons.history,
        message: 'No earlier answers yet',
        detail: "Once a day has passed, everyone's answers to it are here.",
      );
    }
    if (store.refreshError != null && !store.refreshing) {
      return ActionEmptyState(
        icon: ActionIcons.offline,
        message: 'Earlier answers could not be fetched',
        detail: 'They are read from the sheet, which cannot be reached just '
            'now.',
        action: ActionButton(
          label: 'Try again',
          icon: ActionIcons.refresh,
          variant: ActionButtonVariant.outlined,
          onPressed: controller.refresh,
        ),
      );
    }
    return const ActionEmptyState(
      busy: true,
      message: 'Fetching earlier answers…',
    );
  }

  /// Everyone who answered on [day], you first.
  List<String> _people(CheckInStore store, LocalDay day) {
    final me = store.me.email.toLowerCase();
    final people = store.history.peopleOn(day);
    return [
      if (people.contains(me)) me,
      for (final p in people)
        if (p != me) p,
    ];
  }

  String _name(CheckInStore store, String email) =>
      email == store.me.email.toLowerCase()
          ? store.myName
          : store.nameOf(email);

  /// With two people that day, both sit side by side on every question, in
  /// the same order; otherwise each answer that was given, yours first.
  Widget _answerSet(
    CheckInStore store,
    Question question,
    List<Answer> answers,
    List<String> people,
  ) {
    final pair = people.length == 2;
    Answer? by(String email) =>
        answers.where((a) => a.isBy(email)).firstOrNull;

    return ActionAnswerSet(
      title: question.text,
      layout: pair ? ActionAnswerLayout.sideBySide : ActionAnswerLayout.stacked,
      answers: [
        for (final email in people)
          if (pair || by(email) != null)
            answerView(
              question,
              _name(store, email),
              by(email),
              placeholder: 'Not answered',
            ),
      ],
    );
  }
}
