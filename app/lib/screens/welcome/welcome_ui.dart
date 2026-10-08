import 'package:action_design_system/action_design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:four_questions/app_controller.dart';
import 'package:four_questions/config.dart';

/// A first sign-in: the name the person goes by, for the People sheet and
/// for the "Answered by … today" tags others see.
class WelcomeUi extends StatelessWidget {
  const WelcomeUi({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final account = controller.account!;
    final ready = controller.nameDraft.trim().isNotEmpty;

    return ActionScaffold.blank(
      child: ActionPage(
        width: ActionPageWidth.focus,
        centerVertically: true,
        child: ActionHeroPanel(
          title: 'Welcome to ${AppConfig.appName}',
          message: 'What should we call you? Others see this name next to '
              'the questions you have answered.',
          footnote: 'Signed in as ${account.email}',
          children: [
            ActionTextField(
              label: 'Your name',
              value: controller.nameDraft,
              onChanged: controller.setNameDraft,
              hint: 'Your first name, or the name you go by',
              autofocus: true,
              onSubmitted: ready ? controller.saveName : null,
            ),
            ActionButton(
              label: 'Continue',
              icon: ActionIcons.forward,
              expand: true,
              onPressed: ready ? controller.saveName : null,
            ),
          ],
        ),
      ),
    );
  }
}
