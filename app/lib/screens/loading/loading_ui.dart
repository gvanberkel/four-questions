import 'package:action_design_system/action_design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:four_questions/app_controller.dart';
import 'package:four_questions/screens/shell/signed_in_shell.dart';

/// The first visit on a device: nothing to show until the sheet answers.
class LoadingUi extends StatelessWidget {
  const LoadingUi({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return SignedInShell(
      controller: controller,
      child: ActionPage(
        width: ActionPageWidth.focus,
        centerVertically: true,
        child: controller.stage == AppStage.failed
            ? ActionEmptyState(
                icon: ActionIcons.offline,
                message: 'Could not reach the sheet',
                detail: '${controller.failure}',
                action: ActionButton(
                  label: 'Try again',
                  icon: ActionIcons.refresh,
                  onPressed: controller.retry,
                ),
              )
            : const ActionEmptyState(
                busy: true,
                message: "Getting today's questions…",
              ),
      ),
    );
  }
}
