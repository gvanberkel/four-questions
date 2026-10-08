import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const denied = <String, String>{
    'SizedBox': 'ActionStack (the gap is a rhythm, not a number)',
    'SpacedColumn': 'ActionStack',
    'SpacedRow': 'ActionInline',
    'Wrap': 'ActionInline(wrap: true)',
    'Padding': 'the component on either side of it, or ActionStack',
    'Container': 'ActionCard or another Action surface',
    'DecoratedBox': 'ActionCard or another Action surface',
    'ConstrainedBox': 'ActionPage(width:)',
    'IntrinsicHeight': 'a design system layout component — add one first',
    'GridView': 'a design system layout component — add one first',
    'SingleChildScrollView': 'ActionPage',
    'Text': 'ActionBodyText, or a text slot on the component',
    'Divider': 'ActionListDivider, or ActionListCard which owns them',
    'CustomPaint': 'a design system component — a screen never paints',
    'Icon': 'pass the IconData to the component instead',
    'FutureBuilder': 'load in state, not in build',
    'StreamBuilder': 'load in state, not in build',
    'showActionDialog': 'an Action dialog component — add one first',
    'showDiscardDialog': 'an Action dialog component — add one first',
    'showMessage': 'an Action snackbar component — add one first',
    'showErrorSnackBar': 'an Action snackbar component — add one first',
    'showInfoMessage': 'an Action snackbar or banner — add one first',
    'showWarningMessage': 'an Action snackbar or banner — add one first',
    'showErrorMessage': 'ActionEmptyState, or a banner — add one first',
    'Scaffold': 'ActionScaffold',
    'AppBar': 'ActionScaffold',
    'Drawer': 'ActionScaffold',
    'NavigationRail': 'ActionScaffold',
    'NavigationDrawer': 'ActionScaffold',
    'NavigationBar': 'ActionScaffold',
    'TabBar': 'a design system component — add one first',
    'Tab': 'a design system component — add one first',
    'TabBarView': 'a design system component — add one first',
    'Card': 'ActionCard',
    'ListTile': 'ActionListRow',
    'CircleAvatar': 'ActionAvatar',
    'Chip': 'ActionPill',
    'ActionChip': 'ActionPill or ActionRowAction',
    'InputChip': 'a design system component — add one first',
    'FilterChip': 'a design system component — add one first',
    'Badge': 'ActionPill',
    'Table': 'a design system component — add one first',
    'DataTable': 'a design system component — add one first',
    'ReorderableListView': 'a design system component — add one first',
    'ExpansionTile': 'a design system component — add one first',
    'IconButton': 'ActionIconButton',
    'ElevatedButton': 'ActionButton',
    'FilledButton': 'ActionButton',
    'OutlinedButton': 'ActionButton',
    'TextButton': 'ActionButton',
    'FloatingActionButton': 'ActionButton',
    'SegmentedButton': 'ActionSegmentedToggle or ActionChoiceGroup',
    'ToggleButtons': 'ActionSegmentedToggle or ActionChoiceGroup',
    'PopupMenuButton': 'ActionAccountMenu, or an overflow menu — add one first',
    'MenuAnchor': 'ActionAccountMenu, or an overflow menu — add one first',
    'MenuBar': 'a design system component — add one first',
    'MenuItemButton': 'ActionMenuEntry',
    'TextField': 'ActionTextField, ActionNoteField or ActionSearchField',
    'TextFormField': 'ActionTextField, ActionNoteField or ActionSearchField',
    'SearchBar': 'ActionSearchField',
    'Autocomplete': 'a design system component — add one first',
    'RawAutocomplete': 'a design system component — add one first',
    'Checkbox': 'a design system component — add one first',
    'CheckboxListTile': 'a design system component — add one first',
    'Radio': 'a design system component — add one first',
    'RadioListTile': 'a design system component — add one first',
    'RadioGroup': 'a design system component — add one first',
    'Switch': 'ActionSwitchRow',
    'SwitchListTile': 'ActionSwitchRow',
    'DropdownButton': 'a design system component — add one first',
    'DropdownButtonFormField': 'a design system component — add one first',
    'DropdownMenu': 'a design system component — add one first',
    'showDatePicker': 'a design system component — add one first',
    'LinearProgressIndicator': 'ActionStepTrack, or a progress component — '
        'add one first',
    'AnimatedSwitcher': 'ActionStepSwitcher',
    'CircularProgressIndicator':
        'ActionEmptyState(busy: true) or ActionButton(busy: true)',
    'AlertDialog': 'a design system component — add one first',
    'Dialog': 'a design system component — add one first',
    'SimpleDialog': 'a design system component — add one first',
    'showDialog': 'a design system component — add one first',
    'showModalBottomSheet': 'a design system component — add one first',
    'SnackBar': 'a design system component — add one first',
    'MaterialBanner': 'a design system component — add one first',
    'Tooltip': 'an Action component that carries its own tooltip',
  };

  bool isExempt(String path) {
    final normalised = path.replaceAll(r'\', '/');
    return normalised.endsWith('lib/application.dart') ||
        normalised.contains('lib/generated/');
  }

  List<File> appDartFiles() => Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.endsWith('.g.dart'))
      .where((f) => !isExempt(f.path))
      .toList();

  test('screens use design system components, not raw Material widgets', () {
    final violations = <String>[];

    for (final file in appDartFiles()) {
      final lines = file.readAsLinesSync();

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final trimmed = line.trimLeft();
        if (trimmed.startsWith('//') || trimmed.startsWith('*')) continue;

        for (final entry in denied.entries) {
          final pattern = RegExp('(?<![A-Za-z0-9_])${entry.key}\\s*\\(');
          if (pattern.hasMatch(line)) {
            violations.add(
              '${file.path}:${i + 1}  ${entry.key} → use ${entry.value}',
            );
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'The app is built exclusively of Action design system '
          'components.\nAdd the component to action_design_system first, '
          'then use it here.\n\n${violations.join('\n')}',
    );
  });

  const screenVocabulary = <String, String>{
    r'EdgeInsets': 'spacing belongs to the component, or to ActionStack',
    r'BorderRadius': 'radii belong to the component',
    r'BoxDecoration': 'a surface without a component — add one',
    r'Colors\.': 'colour is an ActionTone, resolved inside the component',
    r'(?<![A-Za-z0-9_])Color\(':
        'colour is an ActionTone, resolved inside the component',
    r'colorScheme': 'colour is an ActionTone, resolved inside the component',
    r'TextStyle': 'typography belongs to the component (ActionBodyText)',
    r'textTheme': 'typography belongs to the component (ActionBodyText)',
    r'fontSize': 'typography belongs to the component',
    r'fontWeight': 'typography belongs to the component',
    r'Theme\.of\(': 'a screen never reads the theme',
    r'MediaQuery': 'responsiveness belongs to the component',
    r'LayoutBuilder': 'responsiveness belongs to the component',
    r'ActionSpacing\.': 'a token in a screen is a design decision in a screen',
    r'ActionRadii\.': 'a token in a screen is a design decision in a screen',
    r'ActionBreakpoints\.':
        'a token in a screen is a design decision in a screen',
    r'\b(width|height|maxWidth|minWidth|maxHeight|minHeight|size|elevation|radius):\s*\d':
        'widths and sizes are named in the design system, not measured here',
  };

  List<File> screenDartFiles() => Directory('lib/screens')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  List<String> scan(List<File> files, Map<String, String> vocabulary) {
    final violations = <String>[];
    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final trimmed = lines[i].trimLeft();
        if (trimmed.startsWith('//') || trimmed.startsWith('*')) continue;
        for (final entry in vocabulary.entries) {
          if (RegExp(entry.key).hasMatch(lines[i])) {
            violations.add(
              '${file.path}:${i + 1}  ${entry.key} → ${entry.value}',
            );
          }
        }
      }
    }
    return violations;
  }

  test('screens contain no visual vocabulary', () {
    final violations = scan(screenDartFiles(), screenVocabulary);

    expect(
      violations,
      isEmpty,
      reason: 'A screen is wiring. Every gap, size, radius, colour and type '
          'decision belongs in action_design_system — move it there, name '
          'it, and pass the name.\n\n${violations.join('\n')}',
    );
  });

  test('icons are named once, in ActionIcons', () {
    final violations = scan(appDartFiles(), {
      r'(?<![A-Za-z0-9_])Icons\.': 'ActionIcons.<meaning> — add the name '
          'to the design system if the meaning is new',
    });

    expect(
      violations,
      isEmpty,
      reason: 'Icons are meanings, named once in ActionIcons.\n\n'
          '${violations.join('\n')}',
    );
  });
}
