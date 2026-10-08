import 'package:flutter/material.dart';
import 'package:action_design_system/foundations/icons/action_icons.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';

class ActionChoice<T> {
  const ActionChoice({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// An answer picked from a few large options. Nothing is chosen until the
/// person chooses — unlike [ActionSegmentedToggle], `value` may be null.
class ActionChoiceGroup<T> extends StatelessWidget {
  const ActionChoiceGroup({
    super.key,
    required this.choices,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  }) : assert(choices.length >= 2);

  final List<ActionChoice<T>> choices;

  final T? value;
  final ValueChanged<T> onChanged;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Row(
        children: [
          for (final (i, choice) in choices.indexed) ...[
            if (i > 0) const SizedBox(width: ActionSpacing.sm + 4),
            Expanded(
              child: _ChoiceButton(
                label: choice.label,
                icon: choice.icon,
                selected: choice.value == value,
                onTap: () => onChanged(choice.value),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  static const double _height = 56;

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = selected ? scheme.onPrimary : scheme.onSurface;
    final leading = selected ? ActionIcons.selected : icon;

    return Semantics(
      button: true,
      inMutuallyExclusiveGroup: true,
      checked: selected,
      label: label,
      onTap: selected ? null : onTap,
      excludeSemantics: true,
      child: Material(
        color: selected ? scheme.primary : scheme.surfaceContainerLowest,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outline,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: selected ? null : onTap,
          child: SizedBox(
            height: _height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leading != null) ...[
                  Icon(leading, size: 20, color: foreground),
                  const SizedBox(width: ActionSpacing.sm),
                ],
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: foreground,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
