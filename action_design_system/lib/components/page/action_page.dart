import 'package:flutter/material.dart';
import 'package:action_design_system/components/buttons/action_link.dart';
import 'package:action_design_system/foundations/tokens/action_breakpoints.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';

enum ActionPageHeaderAlignment { start, center }

enum ActionPageWidth {
  content(ActionSpacing.contentMaxWidth),

  reading(ActionSpacing.readingMaxWidth),

  focus(ActionSpacing.focusMaxWidth);

  const ActionPageWidth(this.maxWidth);
  final double maxWidth;
}

class ActionPage extends StatelessWidget {
  const ActionPage({
    super.key,
    this.title,
    required this.child,
    this.subtitle,
    this.actions = const [],
    this.leadingIcon,
    this.backLabel,
    this.onBack,
    this.headerAlignment = ActionPageHeaderAlignment.start,
    this.width = ActionPageWidth.content,
    this.centerVertically = false,
    this.scrollable = true,
    this.footer,
  });

  final String? title;
  final String? subtitle;
  final Widget child;

  final List<Widget> actions;

  final IconData? leadingIcon;

  final String? backLabel;
  final VoidCallback? onBack;

  final ActionPageHeaderAlignment headerAlignment;

  final ActionPageWidth width;

  final bool centerVertically;

  final bool scrollable;

  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final centred = headerAlignment == ActionPageHeaderAlignment.center;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final narrow = ActionBreakpoints.isNarrow(viewportWidth);

    final heading = Column(
      crossAxisAlignment:
          centred ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: 32, color: theme.colorScheme.primary),
          const SizedBox(height: ActionSpacing.sm),
        ],
        Text(
          title ?? '',
          style: narrow
              ? theme.textTheme.headlineSmall
              : theme.textTheme.headlineMedium,
          textAlign: centred ? TextAlign.center : TextAlign.start,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: ActionSpacing.xs),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: centred ? TextAlign.center : TextAlign.start,
          ),
        ],
      ],
    );

    final Widget header;
    if (centred || actions.isEmpty) {
      header = centred ? Center(child: heading) : heading;
    } else if (narrow) {
      header = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          heading,
          const SizedBox(height: ActionSpacing.md),
          Wrap(
            spacing: ActionSpacing.sm,
            runSpacing: ActionSpacing.sm,
            children: actions,
          ),
        ],
      );
    } else {
      header = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: heading),
          const SizedBox(width: ActionSpacing.md),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (i, action) in actions.indexed) ...[
                if (i > 0) const SizedBox(width: ActionSpacing.sm + 4),
                action,
              ],
            ],
          ),
        ],
      );
    }

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (backLabel != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: ActionBackLink(label: backLabel!, onTap: onBack),
          ),
          const SizedBox(height: ActionSpacing.md),
        ],
        if (title != null) ...[
          header,
          const SizedBox(height: ActionSpacing.lg),
        ],
        child,
      ],
    );

    final body = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: narrow ? ActionSpacing.md : ActionSpacing.lg,
        vertical: narrow ? ActionSpacing.lg : ActionSpacing.xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width.maxWidth),
          child: column,
        ),
      ),
    );

    final Widget content;
    if (!scrollable) {
      content = centerVertically ? Center(child: body) : body;
    } else if (centerVertically) {
      content = LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: body),
          ),
        ),
      );
    } else {
      content = SingleChildScrollView(child: body);
    }
    if (footer == null) return content;

    return Column(
      children: [
        Expanded(child: content),
        Padding(
          padding: EdgeInsets.fromLTRB(
            narrow ? ActionSpacing.md : ActionSpacing.lg,
            ActionSpacing.md,
            narrow ? ActionSpacing.md : ActionSpacing.lg,
            ActionSpacing.xl,
          ),
          child: footer!,
        ),
      ],
    );
  }
}
