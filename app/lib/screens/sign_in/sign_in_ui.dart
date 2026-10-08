import 'package:action_design_system/action_design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:four_questions/app_controller.dart';
import 'package:four_questions/config.dart';

/// The front door. Someone who has signed in here before is offered to
/// continue as themselves.
class SignInUi extends StatelessWidget {
  const SignInUi({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final known = controller.account;
    final message = controller.signInMessage;
    final configured = controller.signInConfigured;

    return ActionScaffold.blank(
      child: ActionPage(
        width: ActionPageWidth.focus,
        centerVertically: true,
        child: controller.stage == AppStage.renewing
            ? const ActionEmptyState(busy: true, message: 'Signing you in…')
            : ActionHeroPanel(
                title: AppConfig.appName,
                message: 'A few questions, once a day. Sign in with a Google '
                    'account that can edit the family sheet.',
                notice: message != null
                    ? ActionBanner(
                        icon: ActionIcons.attention,
                        tone: ActionTone.attention,
                        message: message,
                      )
                    : !configured
                        ? const ActionBanner(
                            icon: ActionIcons.attention,
                            tone: ActionTone.attention,
                            title: 'Sign-in is not set up yet',
                            message: 'This build has no Google OAuth client '
                                'ID. See docs/GOOGLE-SIGN-IN.md.',
                          )
                        : null,
                footnote: known == null ? null : 'Signed in before as ${known.email}',
                children: [
                  ActionButton(
                    label: known == null
                        ? 'Sign in with Google'
                        : 'Continue as ${known.firstName}',
                    icon: ActionIcons.signIn,
                    expand: true,
                    onPressed: configured ? controller.signInWithGoogle : null,
                  ),
                  if (known != null)
                    ActionButton(
                      label: 'Use another account',
                      variant: ActionButtonVariant.text,
                      expand: true,
                      onPressed:
                          configured ? controller.useAnotherAccount : null,
                    ),
                ],
              ),
      ),
    );
  }
}
