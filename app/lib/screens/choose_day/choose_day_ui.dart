import 'package:action_design_system/action_design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:four_questions/app_controller.dart';
import 'package:four_questions/screens/shell/signed_in_shell.dart';
import 'package:four_questions/screens/wording.dart';

/// Before starting a day: yesterday's questions are not all answered, so
/// they can be answered now instead of today's — with what others said
/// yesterday alongside.
class ChooseDayUi extends StatelessWidget {
  const ChooseDayUi({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final store = controller.store!;
    final count = store.questions.length;
    final yesterday = store.yesterday;
    final mine = store.answeredOn(yesterday);
    final others = store.othersOn(yesterday);

    return SignedInShell(
      controller: controller,
      child: ActionPage(
        title: 'Which day?',
        subtitle: mine == 0
            ? "You did not answer yesterday's questions."
            : "You did not finish yesterday's questions.",
        width: ActionPageWidth.focus,
        child: ActionListCard(
          children: [
            ActionListRow(
              icon: ActionIcons.history,
              iconTone: ActionTone.accent,
              title: 'Answer for yesterday',
              subtitle: [
                yesterday.spoken,
                '$mine of $count answered',
                if (others.isNotEmpty) answeredBy(others),
              ].join(' · '),
              onTap: controller.answerYesterday,
              wrap: true,
            ),
            ActionListRow(
              icon: ActionIcons.today,
              title: 'Answer for today',
              subtitle: store.day.spoken,
              onTap: controller.answerToday,
              wrap: true,
            ),
          ],
        ),
      ),
    );
  }
}
