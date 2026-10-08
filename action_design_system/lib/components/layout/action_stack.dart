import 'package:flutter/widgets.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';

enum ActionRhythm {
  tight(ActionSpacing.sm),

  group(ActionSpacing.md),

  section(ActionSpacing.lg),

  page(ActionSpacing.xl);

  const ActionRhythm(this.gap);

  final double gap;
}

enum ActionStackAlign {
  stretch(CrossAxisAlignment.stretch),
  start(CrossAxisAlignment.start),
  center(CrossAxisAlignment.center),
  end(CrossAxisAlignment.end);

  const ActionStackAlign(this.crossAxisAlignment);
  final CrossAxisAlignment crossAxisAlignment;
}

class ActionStack extends StatelessWidget {
  const ActionStack({
    super.key,
    required this.children,
    this.rhythm = ActionRhythm.group,
    this.align = ActionStackAlign.stretch,
    this.expand = false,
  });

  final List<Widget> children;
  final ActionRhythm rhythm;
  final ActionStackAlign align;

  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: align.crossAxisAlignment,
      children: [
        for (final (i, child) in children.indexed) ...[
          if (i > 0) SizedBox(height: rhythm.gap),
          child,
        ],
      ],
    );
  }
}
