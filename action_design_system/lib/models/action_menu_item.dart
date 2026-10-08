import 'package:flutter/widgets.dart';

@immutable
class ActionMenuItem {
  const ActionMenuItem({
    required this.label,
    required this.onSelected,
    this.icon,
    this.destructive = false,
  });

  final String label;
  final IconData? icon;

  final VoidCallback? onSelected;
  final bool destructive;
}
