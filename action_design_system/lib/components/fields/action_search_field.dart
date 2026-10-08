import 'package:flutter/material.dart';
import 'package:action_design_system/foundations/icons/action_icons.dart';

class ActionSearchField extends StatelessWidget {
  const ActionSearchField({
    super.key,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.onClear,
  });

  final String hint;
  final String value;
  final ValueChanged<String> onChanged;

  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TextField(
      controller: TextEditingController.fromValue(
        TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        ),
      ),
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        prefixIcon: Icon(ActionIcons.search, size: 20, color: scheme.outline),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        suffixIcon: value.isEmpty || onClear == null
            ? null
            : IconButton(
                icon: const Icon(ActionIcons.close, size: 18),
                tooltip: 'Clear search',
                onPressed: onClear,
              ),
      ),
    );
  }
}
