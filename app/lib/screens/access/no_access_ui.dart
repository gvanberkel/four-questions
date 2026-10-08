import 'package:action_design_system/action_design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:four_questions/app_controller.dart';

/// The account cannot edit the sheet, so it cannot use the app.
class NoAccessUi extends StatelessWidget {
  const NoAccessUi({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final account = controller.account!;
    final reason = controller.accessMessage;

    return ActionScaffold.blank(
      child: ActionPage(
        width: ActionPageWidth.focus,
        centerVertically: true,
        child: ActionHeroPanel(
          title: 'You need edit access',
          message: 'Four Questions keeps its answers in a Google Sheet. Ask '
              'its owner to share it with ${account.email} as an editor, '
              'then try again.',
          notice: reason == null
              ? null
              : ActionBanner(
                  icon: ActionIcons.info,
                  title: 'Google said',
                  message: reason,
                ),
          children: [
            ActionButton(
              label: 'Try again',
              icon: ActionIcons.refresh,
              expand: true,
              onPressed: controller.recheckAccess,
            ),
            ActionButton(
              label: 'Use another account',
              variant: ActionButtonVariant.outlined,
              expand: true,
              onPressed: controller.useAnotherAccount,
            ),
            ActionButton(
              label: 'Sign out',
              variant: ActionButtonVariant.text,
              expand: true,
              onPressed: controller.signOut,
            ),
          ],
        ),
      ),
    );
  }
}
