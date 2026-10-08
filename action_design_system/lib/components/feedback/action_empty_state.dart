import 'package:flutter/material.dart';
import 'package:action_design_system/foundations/icons/action_icons.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';

class ActionEmptyState extends StatelessWidget {
  const ActionEmptyState({
    super.key,
    required this.message,
    this.icon = ActionIcons.positive,
    this.detail,
    this.busy = false,
    this.child,
    this.action,
  });

  final String message;
  final String? detail;
  final IconData icon;
  final bool busy;
  final Widget? child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ActionSpacing.xxl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (busy)
                const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              else
                Icon(icon, size: 40, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: ActionSpacing.md),
              Text(
                message,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              if (detail != null) ...[
                const SizedBox(height: ActionSpacing.xs),
                Text(
                  detail!,
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
              if (child != null) ...[
                const SizedBox(height: ActionSpacing.lg),
                child!,
              ],
              if (action != null) ...[
                const SizedBox(height: ActionSpacing.lg),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
