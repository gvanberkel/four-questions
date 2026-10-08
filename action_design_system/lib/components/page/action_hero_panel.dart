import 'package:flutter/material.dart';
import 'package:action_design_system/components/shell/action_wordmark.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';

/// A front door: the brand's hero mark over a title and a line of
/// explanation, an optional notice, then the panel's controls. Signing in,
/// a first-run welcome, a door that will not open.
class ActionHeroPanel extends StatelessWidget {
  const ActionHeroPanel({
    super.key,
    required this.title,
    this.message,
    this.notice,
    this.children = const [],
    this.footnote,
  });

  final String title;
  final String? message;

  /// Shown between the message and the controls — usually an ActionBanner.
  final Widget? notice;

  /// The controls, stretched to the panel's width.
  final List<Widget> children;

  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Center(child: ActionWordmark.hero()),
        const SizedBox(height: ActionSpacing.lg),
        Semantics(
          header: true,
          child: Text(
            title,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: ActionSpacing.sm),
          Text(
            message!,
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
        if (notice != null) ...[
          const SizedBox(height: ActionSpacing.lg),
          notice!,
        ],
        if (children.isNotEmpty) ...[
          const SizedBox(height: ActionSpacing.xl),
          for (final (i, child) in children.indexed) ...[
            if (i > 0) const SizedBox(height: ActionSpacing.sm + 4),
            child,
          ],
        ],
        if (footnote != null) ...[
          const SizedBox(height: ActionSpacing.lg),
          Text(
            footnote!,
            style: theme.textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
