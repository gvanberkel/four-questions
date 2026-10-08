import 'package:flutter/widgets.dart';

/// Moves between the steps of a flow: the new step slides in from the
/// direction of travel while the old one fades away. Key each child by its
/// step, so a new key is a new step.
class ActionStepSwitcher extends StatelessWidget {
  const ActionStepSwitcher({
    super.key,
    required this.child,
    this.forward = true,
  });

  final Widget child;

  final bool forward;

  static const Duration _duration = Duration(milliseconds: 240);
  static const double _travel = 0.06;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: _duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, ?current],
      ),
      transitionBuilder: (step, animation) {
        final incoming = step.key == child.key;
        final direction = forward ? 1.0 : -1.0;
        final offset = Tween<Offset>(
          begin: Offset((incoming ? _travel : -_travel) * direction, 0),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: step),
        );
      },
      child: child,
    );
  }
}
