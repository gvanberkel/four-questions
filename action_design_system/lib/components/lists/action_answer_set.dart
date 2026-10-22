import 'package:flutter/material.dart';
import 'package:action_design_system/components/cards/action_card.dart';
import 'package:action_design_system/components/lists/action_list_row.dart';
import 'package:action_design_system/components/status/action_avatar.dart';
import 'package:action_design_system/components/status/action_pill.dart';
import 'package:action_design_system/foundations/icons/action_icons.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';
import 'package:action_design_system/models/action_tone.dart';

/// One person's answer, as an [ActionAnswerSet] shows it.
@immutable
class ActionAnswer {
  const ActionAnswer({
    required this.name,
    this.choice,
    this.note = '',
    this.placeholder,
  });

  /// Who answered; the avatar takes its initial.
  final String name;

  /// The option they chose — "Yes", "No" — drawn as a pill.
  final String? choice;

  final String note;

  /// Said, muted, when there is neither a choice nor a note.
  final String? placeholder;
}

enum ActionAnswerLayout {
  /// One answer under another.
  stacked,

  /// Two answers in equal columns, to be compared at a glance. Falls back to
  /// [stacked] when the columns would be too narrow to read, or when there
  /// are not exactly two.
  sideBySide,
}

/// Several people's answers to one question: the question as a title when
/// the set stands on its own, then each person with their choice and note.
/// Tapping the set reports it, so the screen can open the question.
class ActionAnswerSet extends StatelessWidget {
  const ActionAnswerSet({
    super.key,
    required this.answers,
    this.title,
    this.layout = ActionAnswerLayout.stacked,
    this.onTap,
  });

  final List<ActionAnswer> answers;

  final String? title;

  final ActionAnswerLayout layout;

  final VoidCallback? onTap;

  static const double _minColumnWidth = 150;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final body = LayoutBuilder(
      builder: (context, constraints) {
        final columns = layout == ActionAnswerLayout.sideBySide &&
            answers.length == 2 &&
            constraints.maxWidth >= _minColumnWidth * 2;
        if (!columns) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, answer) in answers.indexed) ...[
                if (index > 0) const ActionListDivider(),
                _AnswerCell(answer: answer, column: false),
              ],
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _AnswerCell(answer: answers[0], column: true)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: ActionSpacing.md),
                child: Container(width: 1, color: scheme.outlineVariant),
              ),
              Expanded(child: _AnswerCell(answer: answers[1], column: true)),
            ],
          ),
        );
      },
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ActionSpacing.md,
              ActionSpacing.md,
              ActionSpacing.md,
              ActionSpacing.sm + 4,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(title!, style: theme.textTheme.titleMedium),
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: ActionSpacing.sm),
                  Icon(ActionIcons.open, size: 20, color: scheme.outline),
                ],
              ],
            ),
          ),
          const ActionListDivider(),
        ],
        body,
      ],
    );

    return ActionCard.inset(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: content,
    );
  }
}

class _AnswerCell extends StatelessWidget {
  const _AnswerCell({required this.answer, required this.column});

  final ActionAnswer answer;

  /// Drawn as a narrow column: the choice and note go under the name rather
  /// than beside it, so they keep the column's whole width.
  final bool column;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final note = answer.note.trim();
    final choice = answer.choice;
    final placeholder = choice == null && note.isEmpty
        ? answer.placeholder
        : null;

    final name = Text(
      answer.name,
      style: theme.textTheme.titleSmall,
      overflow: TextOverflow.ellipsis,
    );
    final pill = choice == null
        ? null
        : ActionPill(choice, tone: ActionTone.accent);
    final words = [
      if (note.isNotEmpty) Text(note, style: theme.textTheme.bodyMedium),
      if (placeholder != null)
        Text(
          placeholder,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
    ];

    final Widget cell;
    if (column) {
      cell = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ActionAvatar(name: answer.name),
              const SizedBox(width: ActionSpacing.sm),
              Expanded(child: name),
            ],
          ),
          if (pill != null) ...[
            const SizedBox(height: ActionSpacing.sm + 4),
            pill,
          ],
          for (final text in words) ...[
            const SizedBox(height: ActionSpacing.sm),
            text,
          ],
        ],
      );
    } else {
      cell = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ActionAvatar(name: answer.name),
          const SizedBox(width: ActionSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 32,
                  child: Align(alignment: Alignment.centerLeft, child: name),
                ),
                for (final text in words) ...[
                  const SizedBox(height: ActionSpacing.xs),
                  text,
                ],
              ],
            ),
          ),
          if (pill != null) ...[
            const SizedBox(width: ActionSpacing.sm + 4),
            SizedBox(height: 32, child: Center(child: pill)),
          ],
        ],
      );
    }

    return MergeSemantics(
      child: Semantics(
        label: [
          answer.name,
          ?choice,
          if (note.isNotEmpty) note,
          ?placeholder,
        ].join(', '),
        excludeSemantics: true,
        child: Padding(
          padding: const EdgeInsets.all(ActionSpacing.md),
          child: cell,
        ),
      ),
    );
  }
}
