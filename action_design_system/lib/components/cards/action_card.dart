import 'package:flutter/material.dart';
import 'package:action_design_system/foundations/tokens/action_radii.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';

enum ActionCardDensity {
  compact(EdgeInsets.all(ActionSpacing.sm)),

  regular(EdgeInsets.all(ActionSpacing.md)),

  roomy(EdgeInsets.symmetric(
    horizontal: ActionSpacing.xl,
    vertical: ActionSpacing.lg,
  ));

  const ActionCardDensity(this.padding);
  final EdgeInsets padding;
}

class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.child,
    this.onTap,
    this.density = ActionCardDensity.regular,
    this.semanticLabel,
  }) : padding = null;

  const ActionCard.inset({
    super.key,
    required this.child,
    required this.padding,
    this.onTap,
    this.semanticLabel,
  }) : density = ActionCardDensity.regular;

  final Widget child;
  final VoidCallback? onTap;
  final ActionCardDensity density;
  final EdgeInsetsGeometry? padding;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding ?? density.padding, child: child);

    final card = Card(
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              borderRadius: ActionRadii.lgAll,
              child: content,
            ),
    );

    if (semanticLabel == null) return card;

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      container: true,
      child: card,
    );
  }
}
