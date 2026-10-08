import 'package:action_design_system/action_design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:four_questions/app_controller.dart';
import 'package:four_questions/screens/shell/signed_in_shell.dart';
import 'package:four_questions/screens/wording.dart';

/// One of today's questions: Yes / No when it asks for one, notes when it
/// allows them, and Back / Skip / Next beneath.
class QuestionUi extends StatelessWidget {
  const QuestionUi({super.key, required this.controller});

  final AppController controller;

  static const _yesNo = [
    ActionChoice(value: true, label: 'Yes'),
    ActionChoice(value: false, label: 'No'),
  ];

  @override
  Widget build(BuildContext context) {
    final store = controller.store!;
    final questions = store.questions;
    final index = controller.questionIndex!;
    final question = controller.currentQuestion!;
    final answer = store.mine(question.id);
    final answered = store.isAnswered(question);
    final others = store.othersWhoAnswered(question);
    final last = index == questions.length - 1;

    return SignedInShell(
      controller: controller,
      child: ActionPage(
        width: ActionPageWidth.focus,
        backLabel: controller.canShowSummary ? "Today's answers" : null,
        onBack: controller.showSummary,
        footer: ActionInline(
          justify: ActionInlineJustify.spaceBetween,
          children: [
            ActionButton(
              label: 'Back',
              icon: ActionIcons.back,
              variant: ActionButtonVariant.text,
              onPressed: index == 0 ? null : controller.back,
            ),
            ActionButton(
              label: last
                  ? 'Finish'
                  : answered
                      ? 'Next'
                      : 'Skip',
              icon: last
                  ? ActionIcons.selected
                  : answered
                      ? ActionIcons.forward
                      : ActionIcons.skip,
              variant: answered || last
                  ? ActionButtonVariant.filled
                  : ActionButtonVariant.outlined,
              onPressed: controller.next,
            ),
          ],
        ),
        child: ActionStack(
          rhythm: ActionRhythm.section,
          children: [
            ActionStepTrack(
              stepLabel: 'Question',
              current: index,
              onSelect: controller.goToQuestion,
              steps: [
                for (final (i, q) in questions.indexed)
                  store.isAnswered(q)
                      ? ActionStepState.done
                      : i < index || controller.canShowSummary
                          ? ActionStepState.skipped
                          : ActionStepState.upcoming,
              ],
            ),
            ActionStepSwitcher(
              forward: controller.forward,
              child: ActionPrompt(
                key: ValueKey('${store.day.iso}/${question.id}'),
                eyebrow: 'Question ${index + 1} of ${questions.length}',
                prompt: question.text,
                pills: [
                  if (others.isNotEmpty)
                    ActionPill(
                      answeredByToday(others),
                      icon: ActionIcons.people,
                      tone: ActionTone.positive,
                    ),
                ],
                child: ActionStack(
                  rhythm: ActionRhythm.section,
                  children: [
                    if (question.yesNo)
                      ActionChoiceGroup<bool>(
                        semanticLabel: question.text,
                        choices: _yesNo,
                        value: answer?.yes,
                        onChanged: (yes) => store.setYes(question, yes),
                      ),
                    if (question.takesNote)
                      ActionNoteField(
                        label: question.yesNo ? 'Notes' : 'Your answer',
                        minLines: 3,
                        value: answer?.note ?? '',
                        onChanged: (note) => store.setNote(question, note),
                        hint: question.yesNo
                            ? 'Anything you would like to add'
                            : 'Write your answer',
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
