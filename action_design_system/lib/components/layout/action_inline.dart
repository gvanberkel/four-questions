import 'package:flutter/widgets.dart';
import 'package:action_design_system/components/layout/action_stack.dart';

enum ActionInlineJustify {
  start(MainAxisAlignment.start, WrapAlignment.start),
  center(MainAxisAlignment.center, WrapAlignment.center),
  end(MainAxisAlignment.end, WrapAlignment.end),

  spaceBetween(MainAxisAlignment.spaceBetween, WrapAlignment.spaceBetween);

  const ActionInlineJustify(this.mainAxisAlignment, this.wrapAlignment);
  final MainAxisAlignment mainAxisAlignment;
  final WrapAlignment wrapAlignment;
}

enum ActionInlineAlign {
  center(CrossAxisAlignment.center, WrapCrossAlignment.center),
  start(CrossAxisAlignment.start, WrapCrossAlignment.start),
  end(CrossAxisAlignment.end, WrapCrossAlignment.end);

  const ActionInlineAlign(this.crossAxisAlignment, this.wrapCrossAlignment);
  final CrossAxisAlignment crossAxisAlignment;
  final WrapCrossAlignment wrapCrossAlignment;
}

class ActionInline extends StatelessWidget {
  const ActionInline({
    super.key,
    required this.children,
    this.rhythm = ActionRhythm.tight,
    this.align = ActionInlineAlign.center,
    this.justify = ActionInlineJustify.start,
    this.wrap = false,
  });

  final List<Widget> children;
  final ActionRhythm rhythm;
  final ActionInlineAlign align;
  final ActionInlineJustify justify;

  final bool wrap;

  @override
  Widget build(BuildContext context) {
    if (wrap) {
      return Wrap(
        spacing: rhythm.gap,
        runSpacing: rhythm.gap,
        alignment: justify.wrapAlignment,
        crossAxisAlignment: align.wrapCrossAlignment,
        children: children,
      );
    }

    return Row(
      mainAxisSize: justify == ActionInlineJustify.start
          ? MainAxisSize.min
          : MainAxisSize.max,
      mainAxisAlignment: justify.mainAxisAlignment,
      crossAxisAlignment: align.crossAxisAlignment,
      children: [
        for (final (i, child) in children.indexed) ...[
          if (i > 0) SizedBox(width: rhythm.gap),
          child,
        ],
      ],
    );
  }
}
