import 'package:flutter/material.dart';
import 'package:action_design_system/components/status/action_avatar.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';

enum ActionIdentitySize {
  row,

  hero,
}

class ActionIdentityHeader extends StatelessWidget {
  const ActionIdentityHeader({
    super.key,
    required this.name,
    this.detail,
    this.pills = const [],
    this.size = ActionIdentitySize.row,
    this.unknown = false,
  });

  final String name;

  final String? detail;

  final List<Widget> pills;

  final ActionIdentitySize size;

  final bool unknown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hero = size == ActionIdentitySize.hero;

    final avatar = unknown
        ? _UnknownMark(hero: hero)
        : ActionAvatar(
            name: name,
            size: hero ? ActionAvatarSize.hero : ActionAvatarSize.large,
          );

    final nameText = Text(
      name,
      style: hero ? theme.textTheme.headlineMedium : theme.textTheme.headlineSmall,
      textAlign: hero ? TextAlign.center : TextAlign.start,
    );

    final detailText = detail == null
        ? null
        : Text(
            detail!,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: hero ? TextAlign.center : TextAlign.start,
          );

    final pillRow = pills.isEmpty
        ? null
        : Wrap(
            spacing: ActionSpacing.sm,
            runSpacing: ActionSpacing.sm,
            alignment: hero ? WrapAlignment.center : WrapAlignment.start,
            children: pills,
          );

    if (hero) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          avatar,
          const SizedBox(height: ActionSpacing.md - 2),
          nameText,
          if (detailText != null) ...[
            const SizedBox(height: ActionSpacing.sm),
            detailText,
          ],
          if (pillRow != null) ...[
            const SizedBox(height: ActionSpacing.md - 2),
            pillRow,
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            avatar,
            const SizedBox(width: ActionSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  nameText,
                  if (detailText != null) ...[
                    const SizedBox(height: ActionSpacing.xs),
                    detailText,
                  ],
                ],
              ),
            ),
          ],
        ),
        if (pillRow != null) ...[
          const SizedBox(height: ActionSpacing.md - 2),
          pillRow,
        ],
      ],
    );
  }
}

class _UnknownMark extends StatelessWidget {
  const _UnknownMark({required this.hero});

  final bool hero;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final edge = hero ? 88.0 : 40.0;
    return ExcludeSemantics(
      child: Container(
        width: edge,
        height: edge,
        decoration: BoxDecoration(
          color: scheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: scheme.outline, width: 2),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.person_outline, size: edge * 0.45, color: scheme.outline),
      ),
    );
  }
}
