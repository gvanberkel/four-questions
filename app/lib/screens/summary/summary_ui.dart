import 'package:action_design_system/action_design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:four_questions/app_controller.dart';
import 'package:four_questions/check_in/check_in_store.dart';
import 'package:four_questions/model/question.dart';
import 'package:four_questions/screens/shell/signed_in_shell.dart';
import 'package:four_questions/screens/wording.dart';

/// Today at a glance: each question and how it was answered, and who else
/// has answered today. Tapping a question goes back to it.
class SummaryUi extends StatelessWidget {
  const SummaryUi({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final store = controller.store!;
    final questions = store.questions;
    final answered = store.answeredCount;
    final remaining = questions.length - answered;
    final others = store.othersToday;
    final firstOpen = questions.indexWhere((q) => !store.isAnswered(q));

    return SignedInShell(
      controller: controller,
      child: ActionPage(
        title: 'Today',
        subtitle: questions.isEmpty
            ? store.day.spoken
            : '${store.day.spoken} · $answered of ${questions.length} answered',
        width: ActionPageWidth.reading,
        actions: [
          if (questions.isNotEmpty)
            ActionButton(
              label: 'Edit answers',
              icon: ActionIcons.edit,
              variant: ActionButtonVariant.outlined,
              onPressed: () => controller.goToQuestion(0),
            ),
        ],
        child: questions.isEmpty
            ? const ActionEmptyState(
                icon: ActionIcons.info,
                message: 'No questions today',
                detail: 'There are no active questions on the sheet.',
              )
            : ActionStack(
                rhythm: ActionRhythm.page,
                children: [
                  if (remaining == 0)
                    ActionBanner(
                      icon: ActionIcons.positive,
                      tone: ActionTone.positive,
                      title: 'All done for today',
                      message: store.sync == SyncStatus.idle
                          ? 'Your answers are saved to the sheet.'
                          : 'Your answers are kept on this device and will '
                              'reach the sheet as soon as it can be reached.',
                    )
                  else
                    ActionBanner(
                      icon: ActionIcons.info,
                      title: '${questionCount(remaining)} still to answer',
                      message: 'Tap a question to answer it, or carry on '
                          'where you left off.',
                      trailing: ActionRowAction(
                        label: 'Continue',
                        icon: ActionIcons.forward,
                        filled: true,
                        onPressed: () => controller.goToQuestion(firstOpen),
                      ),
                    ),
                  ActionStack(
                    rhythm: ActionRhythm.tight,
                    children: [
                      const ActionSectionHeader(title: 'Your answers'),
                      ActionListCard(
                        children: [
                          for (final question in questions)
                            _answerRow(store, question),
                        ],
                      ),
                    ],
                  ),
                  ActionStack(
                    rhythm: ActionRhythm.tight,
                    children: [
                      const ActionSectionHeader(title: 'Also answered today'),
                      if (others.isEmpty)
                        const ActionBodyText(
                          'No one else has answered yet today.',
                          muted: true,
                        )
                      else
                        ActionListCard(
                          children: [
                            for (final other in others)
                              ActionListRow(
                                icon: ActionIcons.person,
                                title: other.name,
                                subtitle: '${other.answered} of '
                                    '${questionCount(questions.length)} '
                                    'answered',
                              ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _answerRow(CheckInStore store, Question question) {
    final answer = store.mine(question.id);
    final answered = store.isAnswered(question);
    final note = answer?.note.trim() ?? '';
    final yes = question.yesNo ? answer?.yes : null;

    return ActionListRow(
      icon: answered ? ActionIcons.positive : ActionIcons.unanswered,
      iconTone: answered ? ActionTone.positive : ActionTone.neutral,
      title: question.text,
      subtitle: note.isNotEmpty
          ? note
          : answered
              ? null
              : 'Not answered yet',
      trailing: yes == null
          ? null
          : ActionPill(yes ? 'Yes' : 'No', tone: ActionTone.accent),
      onTap: () => controller.edit(question),
      wrap: true,
    );
  }
}
