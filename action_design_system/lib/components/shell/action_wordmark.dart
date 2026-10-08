import 'package:flutter/material.dart';
import 'package:action_design_system/foundations/brands/action_brand.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';

class ActionWordmark extends StatelessWidget {
  const ActionWordmark({
    super.key,
    this.size = 24,
    this.onTap,
    this.logoOnly = false,
  });

  const ActionWordmark.hero({super.key})
      : size = 72,
        onTap = null,
        logoOnly = true;

  final double size;

  final bool logoOnly;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assets = theme.extension<ActionBrandAssets>();
    final logo = assets?.logoBuilder?.call(context, size: size);
    final name = assets?.name ?? 'Action';

    final mark = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (logo != null && logoOnly) logo,
        if (logo != null && !logoOnly) ...[
          logo,
          const SizedBox(width: ActionSpacing.sm + 2),
        ],
        if (logo == null || !logoOnly)
          Text(
            name,
            style: TextStyle(
              fontFamily: theme.textTheme.titleLarge?.fontFamily,
              fontSize: size * 0.75,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              height: 1,
              color: theme.colorScheme.primary,
            ),
          ),
      ],
    );

    if (onTap == null) return ExcludeSemantics(child: mark);

    return Semantics(
      button: true,
      label: '$name home',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ActionSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ActionSpacing.xs,
            vertical: ActionSpacing.xs,
          ),
          child: mark,
        ),
      ),
    );
  }
}
