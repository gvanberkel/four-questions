import 'package:flutter/material.dart';
import 'package:action_design_system/foundations/tokens/action_radii.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';
import 'package:action_design_system/models/action_tone.dart';

class ActionBanner extends StatelessWidget {
  const ActionBanner({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.tone = ActionTone.neutral,
    this.outlined = false,
    this.trailing,
  });

  final String message;
  final String? title;
  final IconData? icon;
  final ActionTone tone;

  final bool outlined;

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = tone.resolve(scheme);
    final neutral = tone == ActionTone.neutral;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ActionSpacing.md,
        vertical: ActionSpacing.sm + 4,
      ),
      decoration: BoxDecoration(
        color: neutral && !outlined ? scheme.surfaceContainerLow : colors.background,
        borderRadius: ActionRadii.lgAll,
        border: Border.all(
          color: outlined ? colors.emphasis : scheme.outlineVariant,
          width: outlined ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: neutral ? scheme.onSurfaceVariant : colors.emphasis),
            const SizedBox(width: ActionSpacing.sm + 4),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: neutral ? scheme.onSurface : colors.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                ],
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: neutral ? scheme.onSurfaceVariant : colors.foreground,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: ActionSpacing.sm + 4),
            trailing!,
          ],
        ],
      ),
    );
  }
}
