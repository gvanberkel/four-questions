import 'package:flutter/material.dart';

enum ActionAvatarSize {
  chip(20, 9),

  row(32, 13),

  large(40, 16),

  hero(56, 22);

  const ActionAvatarSize(this.dimension, this.fontSize);
  final double dimension;
  final double fontSize;
}

class ActionAvatar extends StatelessWidget {
  const ActionAvatar({
    super.key,
    required this.name,
    this.size = ActionAvatarSize.row,
    this.pending = false,
  });

  final String name;
  final ActionAvatarSize size;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return ExcludeSemantics(
      child: Container(
        width: size.dimension,
        height: size.dimension,
        decoration: BoxDecoration(
          color: pending ? scheme.surfaceContainer : scheme.secondaryContainer,
          shape: BoxShape.circle,
          border: pending ? Border.all(color: scheme.outline, width: 1) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: TextStyle(
            fontSize: size.fontSize,
            fontWeight: FontWeight.w600,
            height: 1,
            color: pending ? scheme.outline : scheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
