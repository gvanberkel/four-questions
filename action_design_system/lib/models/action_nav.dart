import 'package:flutter/widgets.dart';

@immutable
class ActionNavItem {
  const ActionNavItem({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

@immutable
class ActionNavSection {
  const ActionNavSection({this.title, required this.items});

  final String? title;
  final List<ActionNavItem> items;
}
