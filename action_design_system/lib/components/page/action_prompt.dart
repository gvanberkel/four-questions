import 'package:flutter/material.dart';
import 'package:action_design_system/components/page/action_section_header.dart';
import 'package:action_design_system/foundations/tokens/action_breakpoints.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';

/// One question put to the person: where they are in the set, the question in
/// display type, the pills that qualify it, and the answer controls beneath.
class ActionPrompt extends StatelessWidget {
  const ActionPrompt({
    super.key,
    required this.prompt,
    this.eyebrow,
    this.pills = const [],
    this.child,
  });

  final String prompt;

  final String? eyebrow;

  final List<Widget> pills;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final narrow = ActionBreakpoints.isNarrow(MediaQuery.sizeOf(context).width);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (eyebrow != null) ...[
          ActionEyebrow(eyebrow!, accent: true),
          const SizedBox(height: ActionSpacing.sm),
        ],
        Semantics(
          header: true,
          child: Text(
            prompt,
            style: narrow
                ? theme.textTheme.headlineSmall
                : theme.textTheme.headlineMedium,
          ),
        ),
        if (pills.isNotEmpty) ...[
          const SizedBox(height: ActionSpacing.sm + 4),
          Wrap(
            spacing: ActionSpacing.sm,
            runSpacing: ActionSpacing.sm,
            children: pills,
          ),
        ],
        if (child != null) ...[
          const SizedBox(height: ActionSpacing.xl),
          child!,
        ],
      ],
    );
  }
}
