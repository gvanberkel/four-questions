import 'package:flutter/material.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';

class ActionEyebrow extends StatelessWidget {
  const ActionEyebrow(
    this.text, {
    super.key,
    this.accent = false,
    this.uppercase = true,
  });

  final String text;
  final bool accent;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      uppercase ? text.toUpperCase() : text,
      style: theme.textTheme.labelSmall?.copyWith(
        fontSize: uppercase ? 11 : 13,
        fontWeight: uppercase ? FontWeight.w700 : FontWeight.w500,
        letterSpacing: uppercase ? 1 : 0,
        color: accent ? theme.colorScheme.primary : theme.colorScheme.outline,
      ),
    );
  }
}

class ActionSectionHeader extends StatelessWidget {
  const ActionSectionHeader({
    super.key,
    required this.title,
    this.hint,
    this.trailing,
  });

  final String title;
  final String? hint;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        if (hint != null) ...[
          const SizedBox(width: ActionSpacing.sm + 4),
          Expanded(
            child: Text(
              hint!,
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ] else
          const Spacer(),
        if (trailing != null) ...[
          const SizedBox(width: ActionSpacing.sm + 4),
          trailing!,
        ],
      ],
    );
  }
}
