import 'package:flutter/material.dart';
import 'package:action_design_system/foundations/tokens/action_radii.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';

enum ActionStepState {
  upcoming,

  done,

  skipped,
}

/// Where the person is in a short flow: one segment per step, the current one
/// raised. Tapping a segment reports its index; the screen decides whether to
/// go there.
class ActionStepTrack extends StatelessWidget {
  const ActionStepTrack({
    super.key,
    required this.steps,
    required this.current,
    this.onSelect,
    this.stepLabel = 'Step',
  });

  final List<ActionStepState> steps;

  final int? current;

  final ValueChanged<int>? onSelect;

  final String stepLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, state) in steps.indexed) ...[
          if (i > 0) const SizedBox(width: ActionSpacing.xs + 2),
          Expanded(
            child: _Segment(
              state: state,
              current: i == current,
              label: '$stepLabel ${i + 1} of ${steps.length}, '
                  '${_describe(state)}',
              onTap: onSelect == null ? null : () => onSelect!(i),
            ),
          ),
        ],
      ],
    );
  }

  static String _describe(ActionStepState state) => switch (state) {
        ActionStepState.done => 'answered',
        ActionStepState.skipped => 'skipped',
        ActionStepState.upcoming => 'not answered yet',
      };
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.state,
    required this.current,
    required this.label,
    required this.onTap,
  });

  static const double _target = 24;

  final ActionStepState state;
  final bool current;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (state) {
      ActionStepState.done => scheme.primary,
      ActionStepState.skipped => scheme.outline,
      ActionStepState.upcoming =>
        current ? scheme.primary.withValues(alpha: 0.35) : scheme.outlineVariant,
    };

    return Semantics(
      button: onTap != null,
      selected: current,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: ActionRadii.pillAll,
        child: SizedBox(
          height: _target,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              height: current ? 8 : 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: ActionRadii.pillAll,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
