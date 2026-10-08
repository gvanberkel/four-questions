import 'package:flutter/material.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';

enum ActionButtonVariant {
  filled,

  outlined,

  text,
}

enum ActionButtonSize {
  regular,

  small,
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ActionButtonVariant.filled,
    this.size = ActionButtonSize.regular,
    this.icon,
    this.expand = false,
    this.busy = false,
  });

  final String label;

  final VoidCallback? onPressed;

  final ActionButtonVariant variant;
  final ActionButtonSize size;

  final IconData? icon;

  final bool expand;

  final bool busy;

  @override
  Widget build(BuildContext context) {
    final small = size == ActionButtonSize.small;
    final iconSize = small ? 16.0 : 18.0;

    final Widget? leading = busy
        ? SizedBox(
            width: iconSize,
            height: iconSize,
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
        : (icon == null ? null : Icon(icon, size: iconSize));

    final child = leading == null
        ? Text(label)
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              leading,
              const SizedBox(width: ActionSpacing.sm),
              Text(label),
            ],
          );

    final style = small
        ? ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(
                horizontal: variant == ActionButtonVariant.text
                    ? ActionSpacing.md
                    : ActionSpacing.lg,
                vertical: ActionSpacing.xs,
              ),
            ),
            textStyle: WidgetStatePropertyAll(
              Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          )
        : null;

    final pressed = busy ? null : onPressed;
    final button = switch (variant) {
      ActionButtonVariant.filled =>
        FilledButton(onPressed: pressed, style: style, child: child),
      ActionButtonVariant.outlined =>
        OutlinedButton(onPressed: pressed, style: style, child: child),
      ActionButtonVariant.text =>
        TextButton(onPressed: pressed, style: style, child: child),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
