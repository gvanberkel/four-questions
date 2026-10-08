## 0.0.2

* Components for asking questions one at a time: `ActionPrompt`,
  `ActionChoiceGroup` (a choice that starts empty), `ActionStepTrack` and
  `ActionStepSwitcher`.
* `ActionTextField`, a labelled single-line field.
* `ActionHeroPanel`, the front door: hero mark, title, message, controls.
* `ActionNoteField` keeps one controller for its lifetime, so typing in the
  middle of a note no longer throws the cursor to the end; it also takes an
  optional `label`.
* `ActionListRow(wrap: true)` lets title and subtitle run to several lines.
* `ActionPage`'s pinned footer is aligned to the page's content width instead
  of spanning the window.
* Icons: `saving`, `saved`, `selected`, `unanswered`, `skip`, `note`,
  `today`, `sheet`.

## 0.0.1

* Starter set, ported from `guidepost_design_system` 0.0.4 with the
  `Guidepost` prefix renamed `Action`: brand contract and theme builder,
  tokens, icons, tones; shell (scaffold, side nav, account menu, wordmark,
  identity header); page, section header, stack/inline, body text; button,
  icon button, link, row action, segmented toggle, menu entry; list row,
  list card, list divider; search, note, switch and value fields; card,
  avatar, pill, metric, trend line, banner and empty state.
* The calling components (`CallSurface`, `CallStatus`, `CallControls`,
  `CallAnswer`, `CallBar`, `CallSummary`) and their icons were not ported.
* `ActionRowAction` moved to `components/buttons/` — in Guidepost it sat in
  the call answer file.
* `people`, `goal` and `reminder` added to `ActionIcons`.
* `test/purity_test.dart` pins the dependency contract.
