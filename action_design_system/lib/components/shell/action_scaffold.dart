import 'package:flutter/material.dart';
import 'package:action_design_system/components/shell/action_side_nav.dart';
import 'package:action_design_system/components/shell/action_wordmark.dart';
import 'package:action_design_system/foundations/icons/action_icons.dart';
import 'package:action_design_system/foundations/tokens/action_breakpoints.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';
import 'package:action_design_system/models/action_nav.dart';

enum ActionScaffoldMode {
  navigation,

  blank,
}

class ActionScaffold extends StatelessWidget {
  const ActionScaffold({
    super.key,
    required this.child,
    this.sections = const [],
    this.selectedId,
    this.onSelect,
    this.onHome,
    this.account,
    this.barTrailing,
    this.banner,
  }) : mode = ActionScaffoldMode.navigation;

  const ActionScaffold.blank({
    super.key,
    required this.child,
    this.onHome,
    this.banner,
  })  : mode = ActionScaffoldMode.blank,
        sections = const [],
        selectedId = null,
        onSelect = null,
        account = null,
        barTrailing = null;

  final ActionScaffoldMode mode;
  final Widget child;
  final List<ActionNavSection> sections;
  final String? selectedId;
  final ValueChanged<String>? onSelect;

  final VoidCallback? onHome;

  final Widget? account;

  final Widget? barTrailing;

  final Widget? banner;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final compact = ActionBreakpoints.isCompact(width);
        final narrow = ActionBreakpoints.isNarrow(width);
        final hasNav =
            mode == ActionScaffoldMode.navigation && sections.isNotEmpty;
        final navInDrawer = hasNav && compact;

        final nav = hasNav
            ? ActionSideNav(
                sections: sections,
                selectedId: selectedId,
                onSelect: (id) {
                  if (navInDrawer) Navigator.of(context).maybePop();
                  onSelect?.call(id);
                },
                inDrawer: navInDrawer,
              )
            : null;

        return Scaffold(
          drawer: navInDrawer
              ? Drawer(width: ActionBreakpoints.navWidth, child: nav)
              : null,
          body: Column(
            children: [
              _Bar(
                showMenuButton: navInDrawer,
                narrow: narrow,
                onHome: onHome,
                account: account,
                barTrailing: barTrailing,
              ),
              ?banner,
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (nav != null && !navInDrawer) nav,
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.showMenuButton,
    required this.narrow,
    required this.onHome,
    required this.account,
    required this.barTrailing,
  });

  final bool showMenuButton;
  final bool narrow;
  final VoidCallback? onHome;
  final Widget? account;
  final Widget? barTrailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: ActionBreakpoints.barHeight,
      padding: EdgeInsets.symmetric(
        horizontal: narrow ? ActionSpacing.md : ActionSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          if (showMenuButton)
            Padding(
              padding: const EdgeInsets.only(right: ActionSpacing.sm),
              child: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(ActionIcons.menu),
                  tooltip: 'Open navigation',
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
          ActionWordmark(size: narrow ? 22 : 24, onTap: onHome),
          const Spacer(),
          if (barTrailing != null) ...[
            barTrailing!,
            const SizedBox(width: ActionSpacing.sm),
          ],
          ?account,
        ],
      ),
    );
  }
}
