import 'package:flutter/material.dart';
import 'package:action_design_system/foundations/tokens/action_radii.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';
import 'package:action_design_system/models/action_tone.dart';

class ActionPill extends StatelessWidget {
  const ActionPill(
    this.label, {
    super.key,
    this.tone = ActionTone.neutral,
    this.icon,
  });

  final String label;
  final ActionTone tone;

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = tone.resolve(theme.colorScheme);

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: ActionSpacing.sm + 2),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: ActionRadii.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: colors.foreground),
            const SizedBox(width: ActionSpacing.xs),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
