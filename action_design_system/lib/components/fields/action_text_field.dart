import 'package:flutter/material.dart';
import 'package:action_design_system/components/page/action_section_header.dart';
import 'package:action_design_system/foundations/tokens/action_radii.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';

/// A single line the person types — a name, a title — under a small label.
class ActionTextField extends StatefulWidget {
  const ActionTextField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint,
    this.footnote,
    this.onSubmitted,
    this.autofocus = false,
  });

  final String value;
  final ValueChanged<String> onChanged;

  final String? label;
  final String? hint;

  final String? footnote;

  final VoidCallback? onSubmitted;

  final bool autofocus;

  @override
  State<ActionTextField> createState() => _ActionTextFieldState();
}

class _ActionTextFieldState extends State<ActionTextField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(ActionTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          ActionEyebrow(widget.label!),
          const SizedBox(height: ActionSpacing.sm),
        ],
        TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          onSubmitted:
              widget.onSubmitted == null ? null : (_) => widget.onSubmitted!(),
          autofocus: widget.autofocus,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hint,
            enabledBorder: OutlineInputBorder(
              borderRadius: ActionRadii.lgAll,
              borderSide: BorderSide(color: scheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: ActionRadii.lgAll,
              borderSide: BorderSide(color: scheme.primary, width: 2),
            ),
          ),
        ),
        if (widget.footnote != null) ...[
          const SizedBox(height: ActionSpacing.sm - 2),
          Text(widget.footnote!, style: theme.textTheme.labelSmall),
        ],
      ],
    );
  }
}
