import 'package:flutter/material.dart';
import 'package:action_design_system/foundations/tokens/action_radii.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';
import 'package:action_design_system/models/action_menu_item.dart';

class ActionMenuEntry extends StatelessWidget {
  const ActionMenuEntry({super.key, required this.item});

  final ActionMenuItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = item.onSelected != null;
    final color = !enabled
        ? scheme.outline
        : item.destructive
            ? scheme.error
            : scheme.onSurface;

    return MenuItemButton(
      onPressed: item.onSelected,
      style: MenuItemButton.styleFrom(
        minimumSize: const Size(200, 44),
        padding: const EdgeInsets.symmetric(horizontal: ActionSpacing.sm + 4),
        shape: const RoundedRectangleBorder(borderRadius: ActionRadii.mdAll),
        foregroundColor: color,
        textStyle:
            theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      leadingIcon:
          item.icon == null ? null : Icon(item.icon, size: 18, color: color),
      child: Text(item.label),
    );
  }
}
