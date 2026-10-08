import 'package:flutter/material.dart';
import 'package:action_design_system/components/page/action_section_header.dart';
import 'package:action_design_system/foundations/tokens/action_breakpoints.dart';
import 'package:action_design_system/foundations/tokens/action_radii.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';
import 'package:action_design_system/models/action_nav.dart';

class ActionSideNav extends StatelessWidget {
  const ActionSideNav({
    super.key,
    required this.sections,
    required this.selectedId,
    required this.onSelect,
    this.inDrawer = false,
  });

  final List<ActionNavSection> sections;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  final bool inDrawer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: ActionBreakpoints.navWidth,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: inDrawer
            ? null
            : Border(right: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Semantics(
        container: true,
        label: 'Navigation',
        child: ListView(
          padding: const EdgeInsets.symmetric(
            vertical: ActionSpacing.md,
            horizontal: ActionSpacing.sm + 4,
          ),
          children: [
            for (final (index, section) in sections.indexed) ...[
              if (section.title != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    ActionSpacing.sm + 4,
                    index == 0 ? ActionSpacing.xs : ActionSpacing.md,
                    ActionSpacing.sm + 4,
                    ActionSpacing.sm - 2,
                  ),
                  child: ActionEyebrow(section.title!),
                ),
              for (final item in section.items)
                _NavEntry(
                  item: item,
                  selected: item.id == selectedId,
                  onTap: () => onSelect(item.id),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavEntry extends StatelessWidget {
  const _NavEntry({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final ActionNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground =
        selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? scheme.primaryContainer : Colors.transparent,
        borderRadius: ActionRadii.mdAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: ActionRadii.mdAll,
          child: Semantics(
            selected: selected,
            button: true,
            label: item.label,
            child: SizedBox(
              height: 40,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ActionSpacing.sm + 4,
                ),
                child: Row(
                  children: [
                    Icon(item.icon, size: 20, color: foreground),
                    const SizedBox(width: ActionSpacing.sm + 4),
                    Expanded(
                      child: Text(
                        item.label,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: foreground,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
