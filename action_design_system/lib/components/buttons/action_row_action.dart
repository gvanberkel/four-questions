import 'package:flutter/material.dart';
import 'package:action_design_system/foundations/tokens/action_radii.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';

class ActionRowAction extends StatelessWidget {
  const ActionRowAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.filled = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  final bool filled;

  final bool expand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onPressed != null;
    final foreground = !enabled
        ? scheme.outline
        : filled
            ? scheme.onPrimary
            : scheme.primary;
    final background = !enabled
        ? (filled ? scheme.surfaceContainerHighest : Colors.transparent)
        : (filled ? scheme.primary : Colors.transparent);

    final button = Material(
      color: background,
      shape: StadiumBorder(
        side: filled
            ? BorderSide.none
            : BorderSide(
                color: enabled ? scheme.outline : scheme.outlineVariant,
                width: 1.5,
              ),
      ),
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: ActionSpacing.md),
          child: SizedBox(
            height: 44,
            child: Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: foreground),
                  const SizedBox(width: ActionSpacing.sm - 2),
                ],
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return ClipRRect(borderRadius: ActionRadii.pillAll, child: button);
  }
}
