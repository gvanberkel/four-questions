import 'package:flutter/material.dart';
import 'package:action_design_system/foundations/icons/action_icons.dart';
import 'package:action_design_system/foundations/tokens/action_radii.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';

class ActionLink extends StatelessWidget {
  const ActionLink({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        onTap == null ? theme.colorScheme.outline : theme.colorScheme.primary;
    final style = theme.textTheme.labelMedium
        ?.copyWith(color: color, fontWeight: FontWeight.w600);

    return Semantics(
      link: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: ActionRadii.smAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ActionSpacing.xs,
            vertical: ActionSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: ActionSpacing.xs + 2),
              ],
              Text(label, style: style),
              if (trailingIcon != null) ...[
                const SizedBox(width: ActionSpacing.xs),
                Icon(trailingIcon, size: 16, color: color),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ActionBackLink extends StatelessWidget {
  const ActionBackLink({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ActionLink(label: label, onTap: onTap, icon: ActionIcons.back);
  }
}
