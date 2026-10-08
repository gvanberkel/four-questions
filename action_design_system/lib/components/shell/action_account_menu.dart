import 'package:flutter/material.dart';
import 'package:action_design_system/components/buttons/action_menu_entry.dart';
import 'package:action_design_system/components/buttons/action_segmented_toggle.dart';
import 'package:action_design_system/components/page/action_section_header.dart';
import 'package:action_design_system/components/status/action_avatar.dart';
import 'package:action_design_system/foundations/icons/action_icons.dart';
import 'package:action_design_system/foundations/tokens/action_radii.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';
import 'package:action_design_system/models/action_menu_item.dart';

class ActionAccountMenu extends StatelessWidget {
  const ActionAccountMenu({
    super.key,
    required this.name,
    this.email,
    this.rolesLabel,
    this.onSignOut,
    this.showName = true,
    this.versionLabel,
    this.releaseLabel,
    this.settings = const [],
    this.extraItems = const [],
    this.themeMode,
    this.onThemeModeChanged,
    this.onVersionTap,
  });

  final String name;
  final String? email;

  final String? rolesLabel;

  final VoidCallback? onSignOut;
  final bool showName;

  final String? versionLabel;

  final String? releaseLabel;

  final List<Widget> settings;

  final List<ActionMenuItem> extraItems;

  final ThemeMode? themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  final VoidCallback? onVersionTap;

  static const _appearanceSegments = [
    ActionSegment(
        value: ThemeMode.light, label: 'Light', icon: ActionIcons.lightMode),
    ActionSegment(
        value: ThemeMode.dark, label: 'Dark', icon: ActionIcons.darkMode),
    ActionSegment(
        value: ThemeMode.system,
        label: 'System',
        icon: ActionIcons.systemMode),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final showAppearance = themeMode != null && onThemeModeChanged != null;

    return MenuAnchor(
      alignmentOffset: const Offset(0, ActionSpacing.xs),
      style: const MenuStyle(
        minimumSize: WidgetStatePropertyAll(Size(300, 0)),
      ),
      menuChildren: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            ActionSpacing.sm + 4,
            ActionSpacing.sm + 4,
            ActionSpacing.sm + 4,
            ActionSpacing.md - 2,
          ),
          child: Row(
            children: [
              ActionAvatar(name: name, size: ActionAvatarSize.large),
              const SizedBox(width: ActionSpacing.sm + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontSize: 15)),
                    if (email != null)
                      Text(
                        email!,
                        style:
                            theme.textTheme.bodySmall?.copyWith(fontSize: 12.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (rolesLabel != null) ...[
                      const SizedBox(height: 2),
                      Text(rolesLabel!, style: theme.textTheme.labelSmall),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (settings.isNotEmpty) ...[
          const _MenuDivider(),
          ...settings,
        ],
        if (showAppearance) ...[
          const _MenuDivider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ActionSpacing.sm + 4,
              ActionSpacing.sm + 2,
              ActionSpacing.sm + 4,
              ActionSpacing.sm + 4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const ActionEyebrow('Appearance'),
                const SizedBox(height: ActionSpacing.sm),
                ActionSegmentedToggle<ThemeMode>(
                  segments: _appearanceSegments,
                  value: themeMode!,
                  onChanged: onThemeModeChanged!,
                ),
              ],
            ),
          ),
        ],
        if (extraItems.isNotEmpty || onSignOut != null) const _MenuDivider(),
        for (final item in extraItems) ActionMenuEntry(item: item),
        if (onSignOut != null)
          ActionMenuEntry(
            item: ActionMenuItem(
              label: 'Sign out',
              icon: ActionIcons.signOut,
              onSelected: onSignOut,
            ),
          ),
        if (versionLabel != null || releaseLabel != null) ...[
          const _MenuDivider(),
          _VersionStamp(
            onTap: onVersionTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (versionLabel != null)
                  Text(versionLabel!, style: theme.textTheme.labelSmall),
                if (releaseLabel != null)
                  Text(
                    releaseLabel!,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: scheme.outline),
                  ),
              ],
            ),
          ),
        ],
      ],
      builder: (context, controller, _) => Semantics(
        button: true,
        label: 'Account menu for $name',
        child: InkWell(
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
          borderRadius: ActionRadii.pillAll,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              ActionSpacing.xs,
              ActionSpacing.xs,
              ActionSpacing.sm,
              ActionSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ActionAvatar(name: name),
                if (showName) ...[
                  const SizedBox(width: ActionSpacing.sm),
                  Text(
                    name,
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: scheme.onSurface),
                  ),
                  const SizedBox(width: ActionSpacing.xs),
                  Icon(ActionIcons.expandMore,
                      size: 18, color: scheme.onSurfaceVariant),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VersionStamp extends StatelessWidget {
  const _VersionStamp({required this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final padded = Padding(
      padding: const EdgeInsets.fromLTRB(
        ActionSpacing.sm + 4,
        ActionSpacing.sm + 2,
        ActionSpacing.sm + 4,
        ActionSpacing.sm,
      ),
      child: child,
    );
    if (onTap == null) return padded;
    return MenuItemButton(
      onPressed: onTap,
      style: MenuItemButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: ActionRadii.mdAll),
      ),
      child: padded,
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: ActionSpacing.sm - 2),
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
