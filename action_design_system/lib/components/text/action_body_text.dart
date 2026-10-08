import 'package:flutter/material.dart';

class ActionBodyText extends StatelessWidget {
  const ActionBodyText(
    this.text, {
    super.key,
    this.center = false,
    this.large = false,
    this.muted = false,
  });

  final String text;

  final bool center;

  final bool large;

  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var style = large ? theme.textTheme.bodyLarge : theme.textTheme.bodyMedium;
    if (muted) {
      style = style?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    }
    return Text(
      text,
      style: style,
      textAlign: center ? TextAlign.center : TextAlign.start,
    );
  }
}
