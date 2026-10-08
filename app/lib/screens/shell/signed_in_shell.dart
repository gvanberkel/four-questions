import 'package:action_design_system/action_design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:four_questions/app_controller.dart';
import 'package:four_questions/check_in/check_in_store.dart';
import 'package:four_questions/config.dart';

/// The bar every signed-in screen sits under: the wordmark (home is today's
/// summary), whether answers are still on their way, and the account menu.
class SignedInShell extends StatelessWidget {
  const SignedInShell({
    super.key,
    required this.controller,
    required this.child,
  });

  final AppController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final store = controller.store;
    final account = controller.account!;

    return ActionScaffold(
      onHome: store != null && store.hasData ? controller.showSummary : null,
      barTrailing: switch (store?.sync) {
        SyncStatus.saving =>
          const ActionPill('Saving…', icon: ActionIcons.saving),
        SyncStatus.offline => const ActionPill(
            'Saved on device',
            icon: ActionIcons.offline,
            tone: ActionTone.attention,
          ),
        SyncStatus.signedOut => ActionButton(
            label: 'Reconnect',
            icon: ActionIcons.signIn,
            size: ActionButtonSize.small,
            variant: ActionButtonVariant.text,
            onPressed: controller.signInWithGoogle,
          ),
        SyncStatus.idle || null => null,
      },
      account: ActionAccountMenu(
        name: store?.myName ?? account.firstName,
        email: account.email,
        themeMode: controller.themeMode.value,
        onThemeModeChanged: controller.setThemeMode,
        extraItems: [
          ActionMenuItem(
            label: 'Refresh',
            icon: ActionIcons.refresh,
            onSelected: controller.refresh,
          ),
          ActionMenuItem(
            label: 'Open the sheet',
            icon: ActionIcons.sheet,
            onSelected: controller.openSheet,
          ),
        ],
        onSignOut: controller.signOut,
        versionLabel: '${AppConfig.appName} ${AppConfig.version}'
            '${AppConfig.demo ? ' · demo' : ''}',
      ),
      child: child,
    );
  }
}
