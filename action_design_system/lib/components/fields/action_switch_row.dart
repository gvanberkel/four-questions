import 'package:flutter/material.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';
import 'package:action_design_system/models/action_tone.dart';

class ActionSwitchRow extends StatelessWidget {
  const ActionSwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
    this.onTone = ActionTone.positive,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool value;

  final ValueChanged<bool>? onChanged;

  final ActionTone onTone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onChanged != null;
    final active = onTone.resolve(scheme).emphasis;

    return Semantics(
      toggled: value,
      enabled: enabled,
      label: title,
      child: InkWell(
        onTap: enabled ? () => onChanged!(!value) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: ActionSpacing.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: value && enabled ? active : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: ActionSpacing.sm + 4),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(fontSize: 15),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!, style: theme.textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: ActionSpacing.sm),
                ExcludeSemantics(
                  child: Switch(
                    value: value,
                    onChanged: onChanged,
                    activeTrackColor: active,
                    thumbColor: const WidgetStatePropertyAll(Colors.white),
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
