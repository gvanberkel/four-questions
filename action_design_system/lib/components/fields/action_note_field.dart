import 'package:flutter/material.dart';
import 'package:action_design_system/foundations/tokens/action_radii.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';

class ActionNoteField extends StatelessWidget {
  const ActionNoteField({
    super.key,
    required this.value,
    required this.onChanged,
    this.hint,
    this.footnote,
    this.minLines = 4,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;

  final String? footnote;

  final int minLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: TextEditingController.fromValue(
            TextEditingValue(
              text: value,
              selection: TextSelection.collapsed(offset: value.length),
            ),
          ),
          onChanged: onChanged,
          minLines: minLines,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            alignLabelWithHint: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: ActionRadii.lgAll,
              borderSide: BorderSide(color: scheme.primary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: ActionRadii.lgAll,
              borderSide: BorderSide(color: scheme.primary, width: 2),
            ),
          ),
        ),
        if (footnote != null) ...[
          const SizedBox(height: ActionSpacing.sm - 2),
          Text(footnote!, style: theme.textTheme.labelSmall),
        ],
      ],
    );
  }
}
