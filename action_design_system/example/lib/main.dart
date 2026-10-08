import 'package:bron_hovi_theme/bron_hovi_theme.dart';
import 'package:flutter/material.dart';
import 'package:action_design_system/action_design_system.dart';

void main() => runApp(const GalleryApp());

class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  ThemeMode _mode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    const brand = BronHoviBrand();
    return MaterialApp(
      title: 'Action components',
      debugShowCheckedModeBanner: false,
      theme: buildActionTheme(brand),
      darkTheme: buildActionTheme(brand, brightness: Brightness.dark),
      themeMode: _mode,
      home: GalleryShell(
        mode: _mode,
        onModeChanged: (m) => setState(() => _mode = m),
      ),
    );
  }
}

class GalleryShell extends StatefulWidget {
  const GalleryShell({
    super.key,
    required this.mode,
    required this.onModeChanged,
  });

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onModeChanged;

  @override
  State<GalleryShell> createState() => _GalleryShellState();
}

class _GalleryShellState extends State<GalleryShell> {
  String _selected = 'foundations';

  static const _sections = [
    ActionNavSection(items: [
      ActionNavItem(
          id: 'foundations', label: 'Foundations', icon: ActionIcons.info),
      ActionNavItem(
          id: 'page', label: 'Page and layout', icon: ActionIcons.home),
      ActionNavItem(
          id: 'actions', label: 'Actions', icon: ActionIcons.forward),
      ActionNavItem(
          id: 'surfaces', label: 'Surfaces', icon: ActionIcons.positive),
      ActionNavItem(
          id: 'lists', label: 'Lists and fields', icon: ActionIcons.person),
      ActionNavItem(
          id: 'questions', label: 'Questions', icon: ActionIcons.help),
      ActionNavItem(
          id: 'status', label: 'Status and identity', icon: ActionIcons.people),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return ActionScaffold(
      sections: _sections,
      selectedId: _selected,
      onSelect: (id) => setState(() => _selected = id),
      onHome: () => setState(() => _selected = 'foundations'),
      account: ActionAccountMenu(
        name: 'Greg van Berkel',
        email: 'gregvb@tfn.co.za',
        rolesLabel: 'Component gallery',
        versionLabel: 'action_design_system 0.0.2',
        settings: [
          ActionSwitchRow(
            icon: ActionIcons.reminder,
            title: 'Check-in reminders',
            subtitle: 'Reminding you weekly',
            value: true,
            onChanged: (_) {},
          ),
        ],
        themeMode: widget.mode,
        onThemeModeChanged: widget.onModeChanged,
        onSignOut: () {},
      ),
      child: switch (_selected) {
        'page' => const PageAndLayoutPage(),
        'actions' => const ActionsPage(),
        'surfaces' => const SurfacesPage(),
        'lists' => const ListsPage(),
        'questions' => const QuestionsPage(),
        'status' => const StatusPage(),
        _ => const FoundationsPage(),
      },
    );
  }
}

class Example extends StatelessWidget {
  const Example({
    super.key,
    required this.title,
    required this.boundary,
    required this.child,
  });

  final String title;
  final String boundary;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ActionSectionHeader(title: title, hint: boundary),
        const SizedBox(height: ActionSpacing.sm + 4),
        child,
        const SizedBox(height: ActionSpacing.xl),
      ],
    );
  }
}

Widget _row(List<Widget> children) => Wrap(
      spacing: ActionSpacing.sm + 4,
      runSpacing: ActionSpacing.sm + 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );

class FoundationsPage extends StatelessWidget {
  const FoundationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ActionPage(
      title: 'Foundations',
      subtitle: 'Tones, type, icons — what every component is made of.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Example(
            title: 'Brand',
            boundary:
                'The logo and wordmark come from the theme, never from an import.',
            child: _row([
              const ActionWordmark(),
              const ActionWordmark.hero(),
              const ActionWordmark(size: 40, logoOnly: true),
            ]),
          ),
          Example(
            title: 'ActionTone',
            boundary:
                'A meaning, resolved through the theme. Components take a tone, never a colour.',
            child: _row([
              for (final tone in ActionTone.values)
                _ToneSwatch(tone: tone, colors: tone.resolve(scheme)),
            ]),
          ),
          Example(
            title: 'Type scale',
            boundary:
                'Headings in the heading face, body in the body face; body starts at 16.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Headline medium 28',
                    style: theme.textTheme.headlineMedium),
                Text('Headline small 24', style: theme.textTheme.headlineSmall),
                Text('Title large 20', style: theme.textTheme.titleLarge),
                Text('Title medium 16', style: theme.textTheme.titleMedium),
                const SizedBox(height: ActionSpacing.sm),
                Text('Body large 16 — the sentence a surface leads with.',
                    style: theme.textTheme.bodyLarge),
                Text('Body medium 15 — the default for prose.',
                    style: theme.textTheme.bodyMedium),
                Text('Body small 13 — secondary detail.',
                    style: theme.textTheme.bodySmall),
                const SizedBox(height: ActionSpacing.sm),
                Text('Label large 14', style: theme.textTheme.labelLarge),
                Text('Label medium 13', style: theme.textTheme.labelMedium),
                Text('Label small 12', style: theme.textTheme.labelSmall),
              ],
            ),
          ),
          Example(
            title: 'ActionIcons',
            boundary: 'One name per meaning. A screen never writes Icons.x.',
            child: _row([
              for (final entry in ActionIcons.named.entries)
                Tooltip(
                  message: entry.key,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(entry.value, color: scheme.onSurfaceVariant),
                      const SizedBox(height: ActionSpacing.xs),
                      Text(entry.key, style: theme.textTheme.labelSmall),
                    ],
                  ),
                ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _ToneSwatch extends StatelessWidget {
  const _ToneSwatch({required this.tone, required this.colors});

  final ActionTone tone;
  final ActionToneColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ActionSpacing.md,
        vertical: ActionSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: ActionRadii.pillAll,
        border: Border.all(color: colors.emphasis),
      ),
      child: Text(
        tone.name,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: colors.foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class PageAndLayoutPage extends StatelessWidget {
  const PageAndLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionPage(
      title: 'Page and layout',
      subtitle: 'This page is an ActionPage; the header above is its header.',
      actions: [
        ActionIconButton(
          icon: ActionIcons.refresh,
          tooltip: 'A header action',
          onPressed: () {},
        ),
        ActionButton(
          label: 'Primary action',
          onPressed: () {},
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Example(
            title: 'ActionStack',
            boundary: 'A vertical stack whose gap is a rhythm, not a number.',
            child: ActionStack(
              rhythm: ActionRhythm.tight,
              children: [
                for (final rhythm in ActionRhythm.values)
                  ActionCard(
                    density: ActionCardDensity.compact,
                    child: ActionBodyText('ActionRhythm.${rhythm.name}'),
                  ),
              ],
            ),
          ),
          Example(
            title: 'ActionInline',
            boundary: 'The sideways stack. wrap: true folds on a phone.',
            child: ActionInline(
              wrap: true,
              children: [
                for (var i = 1; i <= 6; i++)
                  ActionCard(
                    density: ActionCardDensity.compact,
                    child: ActionBodyText('Item $i'),
                  ),
              ],
            ),
          ),
          const Example(
            title: 'ActionBodyText',
            boundary:
                'Body copy. The screen says what the text is, not how it looks.',
            child: ActionStack(
              rhythm: ActionRhythm.tight,
              children: [
                ActionBodyText('Large: the sentence a surface leads with.',
                    large: true),
                ActionBodyText('Default body copy, read at length.'),
                ActionBodyText('Muted: secondary detail.', muted: true),
              ],
            ),
          ),
          Example(
            title: 'ActionSectionHeader and ActionEyebrow',
            boundary:
                'Names what follows. Sections instead of cards inside cards.',
            child: ActionStack(
              children: [
                ActionSectionHeader(
                  title: 'A section',
                  hint: 'with a hint',
                  trailing: ActionLink(label: 'and a link', onTap: () {}),
                ),
                const ActionEyebrow('An eyebrow'),
                const ActionEyebrow('Step 2 of 4', accent: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActionsPage extends StatelessWidget {
  const ActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionPage(
      title: 'Actions',
      subtitle: 'One filled button per surface; everything else quieter.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Example(
            title: 'ActionButton',
            boundary:
                'Three weights, two sizes, a busy state. Shape and colour from the theme.',
            child: ActionStack(
              children: [
                _row([
                  ActionButton(label: 'Filled', onPressed: () {}),
                  ActionButton(
                    label: 'Outlined',
                    variant: ActionButtonVariant.outlined,
                    onPressed: () {},
                  ),
                  ActionButton(
                    label: 'Text',
                    variant: ActionButtonVariant.text,
                    onPressed: () {},
                  ),
                  const ActionButton(label: 'Disabled'),
                  ActionButton(
                    label: 'With icon',
                    icon: ActionIcons.add,
                    onPressed: () {},
                  ),
                  const ActionButton(label: 'Saving…', busy: true),
                ]),
                _row([
                  ActionButton(
                    label: 'Small filled',
                    size: ActionButtonSize.small,
                    onPressed: () {},
                  ),
                  ActionButton(
                    label: 'Small outlined',
                    size: ActionButtonSize.small,
                    variant: ActionButtonVariant.outlined,
                    onPressed: () {},
                  ),
                  ActionButton(
                    label: 'Small text',
                    size: ActionButtonSize.small,
                    variant: ActionButtonVariant.text,
                    onPressed: () {},
                  ),
                ]),
                ActionButton(
                  label: 'Expanded',
                  expand: true,
                  variant: ActionButtonVariant.outlined,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Example(
            title: 'ActionIconButton',
            boundary: 'Icon only; the tooltip is mandatory.',
            child: _row([
              ActionIconButton(
                icon: ActionIcons.refresh,
                tooltip: 'Refresh',
                onPressed: () {},
              ),
              ActionIconButton(
                icon: ActionIcons.edit,
                tooltip: 'Edit',
                onPressed: () {},
              ),
              const ActionIconButton(
                icon: ActionIcons.delete,
                tooltip: 'Delete (disabled)',
                onPressed: null,
              ),
            ]),
          ),
          const Example(
            title: 'ActionSegmentedToggle',
            boundary:
                'Two or three exclusive options, one always selected. Reports the value; never holds it.',
            child: _ToggleDemo(),
          ),
          Example(
            title: 'ActionLink and ActionBackLink',
            boundary:
                'Inline; quieter than a text button. Never navigates itself.',
            child: _row([
              ActionLink(label: 'A link', onTap: () {}),
              ActionLink(
                label: 'With trailing icon',
                trailingIcon: ActionIcons.open,
                onTap: () {},
              ),
              const ActionLink(label: 'Disabled', onTap: null),
              ActionBackLink(label: 'Home', onTap: () {}),
            ]),
          ),
        ],
      ),
    );
  }
}

class _ToggleDemo extends StatefulWidget {
  const _ToggleDemo();

  @override
  State<_ToggleDemo> createState() => _ToggleDemoState();
}

class _ToggleDemoState extends State<_ToggleDemo> {
  ThemeMode _value = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return _row([
      ActionSegmentedToggle<ThemeMode>(
        segments: const [
          ActionSegment(
              value: ThemeMode.light,
              label: 'Light',
              icon: ActionIcons.lightMode),
          ActionSegment(
              value: ThemeMode.dark,
              label: 'Dark',
              icon: ActionIcons.darkMode),
          ActionSegment(
              value: ThemeMode.system,
              label: 'System',
              icon: ActionIcons.systemMode),
        ],
        value: _value,
        onChanged: (v) => setState(() => _value = v),
      ),
      ActionBodyText('Selected: ${_value.name}', muted: true),
    ]);
  }
}

class SurfacesPage extends StatelessWidget {
  const SurfacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionPage(
      title: 'Surfaces and feedback',
      subtitle: 'Cards and the states a page can be in.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Example(
            title: 'ActionCard',
            boundary: 'Three densities. Tappable with a semantic label.',
            child: ActionStack(
              children: [
                const ActionCard(
                  density: ActionCardDensity.compact,
                  child: ActionBodyText('Compact'),
                ),
                const ActionCard(
                  child: ActionBodyText('Regular'),
                ),
                const ActionCard(
                  density: ActionCardDensity.roomy,
                  child: ActionBodyText('Roomy'),
                ),
                ActionCard(
                  onTap: () {},
                  semanticLabel: 'Open the tappable card',
                  child: const ActionInline(
                    justify: ActionInlineJustify.spaceBetween,
                    children: [
                      ActionBodyText('Tappable'),
                      ActionBodyText('→', muted: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Example(
            title: 'ActionAvatar',
            boundary: 'An initial on a disc, four sizes; pending for never-signed-in.',
            child: _row([
              for (final size in ActionAvatarSize.values)
                ActionAvatar(name: 'Thandi Nkosi', size: size),
              const ActionAvatar(
                  name: 'Pending Person',
                  size: ActionAvatarSize.large,
                  pending: true),
            ]),
          ),
          Example(
            title: 'ActionEmptyState',
            boundary:
                'Nothing here, working on it, could not load. The screen writes the sentence.',
            child: ActionStack(
              children: [
                const ActionCard(
                  child: ActionEmptyState(
                    message: 'Nothing here yet',
                    detail: 'When there is, it will appear here.',
                  ),
                ),
                const ActionCard(
                  child: ActionEmptyState(
                    message: 'Loading your plan…',
                    busy: true,
                  ),
                ),
                ActionCard(
                  child: ActionEmptyState(
                    icon: ActionIcons.offline,
                    message: 'Could not load this page.',
                    detail: 'Nothing has been lost.',
                    action: ActionButton(
                      label: 'Try again',
                      variant: ActionButtonVariant.outlined,
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListsPage extends StatelessWidget {
  const ListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionPage(
      title: 'Lists and fields',
      subtitle: 'The shapes a phone screen is mostly made of.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Example(
            title: 'ActionPill',
            boundary: 'A meaning in a tinted label. Takes a tone, never a colour.',
            child: _row([
              for (final tone in ActionTone.values)
                ActionPill(tone.name, tone: tone),
              const ActionPill('0.4',
                  icon: ActionIcons.rising, tone: ActionTone.attention),
            ]),
          ),
          Example(
            title: 'ActionListRow and ActionListCard',
            boundary:
                'The card owns the inset and the dividers; the screen states only its rows.',
            child: ActionListCard(
              children: [
                ActionListRow(
                  icon: ActionIcons.positive,
                  iconTone: ActionTone.positive,
                  title: 'Weekly check-in answered',
                  subtitle: 'Four of four questions / Monday 07:40',
                  onTap: () {},
                ),
                ActionListRow(
                  icon: ActionIcons.attention,
                  iconTone: ActionTone.attention,
                  emphasis: ActionTone.attention,
                  title: 'A row that must stand out',
                  subtitle: 'emphasis washes the whole row',
                  trailing: ActionRowAction(
                    label: 'Check in',
                    icon: ActionIcons.forward,
                    filled: true,
                    onPressed: () {},
                  ),
                ),
                const ActionListRow(
                  title: 'Plain information',
                  subtitle: 'no icon, no chevron, nothing to tap',
                ),
                const ActionListRow(
                  title: 'With a trailing value',
                  trailing: ActionBodyText('weekly', muted: true),
                ),
                ActionListRow(
                  icon: ActionIcons.positive,
                  iconTone: ActionTone.positive,
                  title: 'Have you taken a moment for yourself today? '
                      'A row that wraps reads in full.',
                  subtitle: 'wrap: true lets a long note run to as many '
                      'lines as it needs instead of ending in an ellipsis.',
                  trailing: const ActionPill('Yes', tone: ActionTone.accent),
                  onTap: () {},
                  wrap: true,
                ),
              ],
            ),
          ),
          const Example(
            title: 'Fields',
            boundary:
                'The text lives on the view model, which is what makes a screen reconstructible; the field keeps only the cursor.',
            child: _FieldsDemo(),
          ),
        ],
      ),
    );
  }
}

class _FieldsDemo extends StatefulWidget {
  const _FieldsDemo();

  @override
  State<_FieldsDemo> createState() => _FieldsDemoState();
}

class _FieldsDemoState extends State<_FieldsDemo> {
  String _query = '';
  String _name = '';
  String _note = '';
  bool _reminders = true;

  @override
  Widget build(BuildContext context) {
    return ActionStack(
      children: [
        ActionSearchField(
          hint: 'Search people or goals',
          value: _query,
          onChanged: (value) => setState(() => _query = value),
          onClear: () => setState(() => _query = ''),
        ),
        ActionListCard(
          children: [
            ActionSwitchRow(
              icon: ActionIcons.reminder,
              title: 'Check-in reminders',
              subtitle: _reminders
                  ? 'Reminding you weekly'
                  : 'You will not be reminded',
              value: _reminders,
              onChanged: (value) => setState(() => _reminders = value),
            ),
            ActionValueRow(
              icon: ActionIcons.people,
              label: 'Accountability partner',
              value: 'Thandi',
              onTap: () {},
            ),
          ],
        ),
        ActionTextField(
          label: 'Your name',
          value: _name,
          onChanged: (value) => setState(() => _name = value),
          hint: 'The name you go by',
          footnote: 'ActionTextField — one line, a label above it.',
        ),
        ActionNoteField(
          value: _note,
          onChanged: (value) => _note = value,
          hint: 'What moved this week, and what got in the way?',
          footnote: 'Shared with your partner when you check in.',
        ),
      ],
    );
  }
}

class QuestionsPage extends StatelessWidget {
  const QuestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionPage(
      title: 'Questions',
      subtitle: 'Asking one thing at a time, and showing where you are.',
      width: ActionPageWidth.reading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Example(
            title: 'ActionHeroPanel',
            boundary:
                'A front door: mark, title, message, then controls. Knows nothing of who is signing in.',
            child: ActionCard(
              density: ActionCardDensity.roomy,
              child: ActionHeroPanel(
                title: 'Welcome to Four Questions',
                message: 'A few questions, once a day.',
                footnote: 'You need edit access to the family sheet.',
                children: [
                  ActionButton(
                    label: 'Sign in with Google',
                    icon: ActionIcons.signIn,
                    expand: true,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const Example(
            title: 'ActionPrompt, ActionChoiceGroup and ActionStepTrack',
            boundary:
                'The prompt states the question; the choice starts empty; the track only reports taps.',
            child: _QuestionDemo(),
          ),
        ],
      ),
    );
  }
}

class _QuestionDemo extends StatefulWidget {
  const _QuestionDemo();

  @override
  State<_QuestionDemo> createState() => _QuestionDemoState();
}

class _QuestionDemoState extends State<_QuestionDemo> {
  static const _questions = [
    'Have you had fun today?',
    'Have you taken a moment for yourself today?',
    'Have you eaten 3 meals today?',
  ];

  final _answers = <int, bool>{};
  final _notes = <int, String>{};
  int _index = 0;
  bool _forward = true;

  void _go(int index) => setState(() {
        _forward = index >= _index;
        _index = index.clamp(0, _questions.length - 1);
      });

  @override
  Widget build(BuildContext context) {
    return ActionCard(
      density: ActionCardDensity.roomy,
      child: ActionStack(
        rhythm: ActionRhythm.section,
        children: [
          ActionStepTrack(
            stepLabel: 'Question',
            steps: [
              for (var i = 0; i < _questions.length; i++)
                _answers.containsKey(i)
                    ? ActionStepState.done
                    : i < _index
                        ? ActionStepState.skipped
                        : ActionStepState.upcoming,
            ],
            current: _index,
            onSelect: _go,
          ),
          ActionStepSwitcher(
            forward: _forward,
            child: ActionPrompt(
              key: ValueKey(_index),
              eyebrow: 'Question ${_index + 1} of ${_questions.length}',
              prompt: _questions[_index],
              pills: [
                if (_index == 0)
                  const ActionPill('Answered by Hovi today',
                      icon: ActionIcons.people),
              ],
              child: ActionStack(
                rhythm: ActionRhythm.section,
                children: [
                  ActionChoiceGroup<bool>(
                    semanticLabel: _questions[_index],
                    choices: const [
                      ActionChoice(value: true, label: 'Yes'),
                      ActionChoice(value: false, label: 'No'),
                    ],
                    value: _answers[_index],
                    onChanged: (v) => setState(() => _answers[_index] = v),
                  ),
                  ActionNoteField(
                    label: 'Notes',
                    minLines: 3,
                    value: _notes[_index] ?? '',
                    onChanged: (v) => _notes[_index] = v,
                    hint: 'Anything you want to add',
                  ),
                ],
              ),
            ),
          ),
          ActionInline(
            justify: ActionInlineJustify.spaceBetween,
            children: [
              ActionButton(
                label: 'Back',
                icon: ActionIcons.back,
                variant: ActionButtonVariant.text,
                onPressed: _index == 0 ? null : () => _go(_index - 1),
              ),
              ActionButton(
                label: _answers.containsKey(_index) ? 'Next' : 'Skip',
                icon: ActionIcons.forward,
                onPressed: _index == _questions.length - 1
                    ? null
                    : () => _go(_index + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ActionPage(
      title: 'Status and identity',
      subtitle: 'Who a screen is about, and how things are going.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Example(
            title: 'ActionIdentityHeader',
            boundary: 'Hero on its own, row beside a title.',
            child: ActionStack(
              rhythm: ActionRhythm.page,
              children: [
                ActionIdentityHeader(
                  size: ActionIdentitySize.hero,
                  name: 'Thandi Nkosi',
                  detail: 'Accountability partner since March',
                  pills: [
                    ActionPill('Partner', tone: ActionTone.accent),
                  ],
                ),
                ActionIdentityHeader(
                  size: ActionIdentitySize.hero,
                  name: 'Invite pending',
                  detail: 'Not joined yet',
                  unknown: true,
                ),
                ActionIdentityHeader(
                  name: 'Thandi Nkosi',
                  detail: 'Weekly check-ins / Mondays',
                  pills: [
                    ActionPill('Growth', tone: ActionTone.accent),
                    ActionPill('Habits'),
                    ActionPill('On track', tone: ActionTone.positive),
                  ],
                ),
              ],
            ),
          ),
          Example(
            title: 'ActionMetric and ActionTrendLine',
            boundary:
                'Direction of travel, not a chart: no scale, no gridlines, no tooltip.',
            child: ActionCard(
              child: ActionInline(
                justify: ActionInlineJustify.spaceBetween,
                align: ActionInlineAlign.end,
                children: [
                  ActionMetric(
                    label: 'Check-in streak',
                    value: '6',
                    unit: 'weeks',
                    caption: 'Since 31 August',
                    delta: ActionPill('2',
                        icon: ActionIcons.rising, tone: ActionTone.positive),
                  ),
                  ActionTrendLine(
                    values: [2, 3, 3, 4, 4],
                    startLabel: 'Sep',
                    endLabel: 'Oct',
                  ),
                ],
              ),
            ),
          ),
          Example(
            title: 'ActionBanner',
            boundary: 'outlined marks something provisional rather than current.',
            child: ActionStack(
              children: [
                ActionBanner(
                  icon: ActionIcons.history,
                  title: 'Last check-in 3 days ago',
                  message: 'Four of four questions answered',
                ),
                ActionBanner(
                  icon: ActionIcons.attention,
                  tone: ActionTone.attention,
                  outlined: true,
                  title: 'Draft, not shared yet',
                  message: 'Your partner sees this once you check in.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
