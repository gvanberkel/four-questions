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
