import 'package:flutter/material.dart';
import 'package:action_design_system/foundations/icons/action_icons.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';

class ActionValueRow extends StatelessWidget {
  const ActionValueRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: ActionSpacing.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: scheme.onSurfaceVariant),
              const SizedBox(width: ActionSpacing.sm + 4),
            ],
            Expanded(
              child: Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15)),
            ),
            const SizedBox(width: ActionSpacing.sm),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 15),
            ),
            if (onTap != null) ...[
              const SizedBox(width: ActionSpacing.xs),
              Icon(ActionIcons.expandMore, size: 18, color: scheme.outline),
            ],
          ],
        ),
      ),
    );

    if (onTap == null) return content;

    return Semantics(
      button: true,
      label: '$label, $value',
      child: InkWell(onTap: onTap, child: content),
    );
  }
}
