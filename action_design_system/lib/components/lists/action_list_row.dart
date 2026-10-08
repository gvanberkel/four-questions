import 'package:flutter/material.dart';
import 'package:action_design_system/components/cards/action_card.dart';
import 'package:action_design_system/foundations/icons/action_icons.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';
import 'package:action_design_system/models/action_tone.dart';

class ActionListRow extends StatelessWidget {
  const ActionListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconTone = ActionTone.neutral,
    this.trailing,
    this.onTap,
    this.emphasis,
  });

  final String title;
  final String? subtitle;

  final IconData? icon;
  final ActionTone iconTone;

  final Widget? trailing;

  final VoidCallback? onTap;

  final ActionTone? emphasis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ActionSpacing.md,
        vertical: ActionSpacing.sm - 2,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Row(
          children: [
            if (icon != null) ...[
              _IconDisc(icon: icon!, tone: iconTone),
              const SizedBox(width: ActionSpacing.sm + 4),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: ActionSpacing.sm + 4),
              trailing!,
            ] else if (onTap != null) ...[
              const SizedBox(width: ActionSpacing.sm),
              Icon(ActionIcons.open, size: 20, color: scheme.outline),
            ],
          ],
        ),
      ),
    );

    final tinted = emphasis == null
        ? content
        : ColoredBox(
            color: Color.alphaBlend(
              emphasis!.resolve(scheme).background.withValues(alpha: 0.45),
              scheme.surfaceContainerLow,
            ),
            child: content,
          );

    if (onTap == null) return tinted;

    return Semantics(
      button: true,
      label: subtitle == null ? title : '$title, $subtitle',
      child: InkWell(onTap: onTap, child: tinted),
    );
  }
}

class _IconDisc extends StatelessWidget {
  const _IconDisc({required this.icon, required this.tone});

  final IconData icon;
  final ActionTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = tone.resolve(Theme.of(context).colorScheme);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: colors.background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(icon, size: 18, color: colors.emphasis),
    );
  }
}

class ActionListDivider extends StatelessWidget {
  const ActionListDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: ActionSpacing.md),
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

class ActionListCard extends StatelessWidget {
  const ActionListCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ActionCard.inset(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0) const ActionListDivider(),
            child,
          ],
        ],
      ),
    );
  }
}
