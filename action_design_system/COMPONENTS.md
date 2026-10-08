# Action components — the catalogue and the boundaries

**Status:** Ported 2026-10-08 from `guidepost_design_system` 0.0.4 (the
Clarifai nurse app) as the starting set for four-questions. The calling
components (call surface, status, controls, answer, bar and summary) stayed
behind — they belong to a phone app, not this one. Add components here as
four-questions' screens need them.

Every component here obeys the same three rules (README.md), so a screen can
be composed from them without wondering where a responsibility sits. The
tables say, per component: what it **owns** (draws and decides), what it
**takes** (the values and callbacks that are its whole contract), and what it
**never does** (the boundary).

## Foundations

| | Owns | Takes | Never |
|---|---|---|---|
| `ActionBrand` / `ActionBrandAssets` / `ActionSurfaceStyles` | The contract a brand satisfies: colour schemes, body and heading font, surface styles, name, logo builder. `buildActionTheme` turns it into `ThemeData` plus two theme extensions. | A brand implementation from `themes/`. | Names a concrete brand. |
| `ActionSpacing`, `ActionRadii`, `ActionBreakpoints` | The rhythm: 4/8/16/24/32/48, radii 4/8/12/pill, breakpoints 720 (narrow) and 1024 (compact), bar 56, nav 240. | — | Vary by brand. |
| `ActionTone` | The four meanings (neutral, accent, positive, attention) and their resolution to foreground / background / emphasis colours. | A `ColorScheme`. | Carry a literal colour. |
| `ActionIcons` | The whole icon vocabulary, one name per meaning. `named` lists them for the gallery. | — | Be bypassed: no `Icons.…` in a screen. |

## Shell and navigation

| | Owns | Takes | Never |
|---|---|---|---|
| `ActionScaffold` | **The one Scaffold.** 56px bar (wordmark, account slot), 240px side nav that becomes a drawer below 1024px, content area. Modes: `navigation`, `.blank`. | `sections`, `selectedId`, `onSelect(id)`, `onHome`, `account`, `barTrailing`. | Know a route; hold navigation state; decide which sections a role sees. |
| `ActionSideNav` | The nav column: eyebrow section titles, 40px entries, selected state. Same widget in the drawer. | `sections`, `selectedId`, `onSelect`. | Filter by role. |
| `ActionAccountMenu` | Avatar + name + chevron in the bar; the menu: identity (name, email, roles), settings rows (a consequential switch that belongs two taps away), the appearance toggle (Light / Dark / System, stays open while choosing), extra items, Sign out, build stamp. | `name`, `email`, `rolesLabel`, `settings`, `themeMode` + `onThemeModeChanged`, `extraItems`, `onSignOut`, `versionLabel`, `releaseLabel`, `onVersionTap`. | Know who is signed in; hold the theme mode; sign anyone out itself. |
| `ActionWordmark` | Logo (from the brand's builder) + wordmark in primary. `.hero()` is the sign-in mark. | `size`, `onTap`, `logoOnly`. | Import the brand. |
| `ActionIdentityHeader` | Who a screen is about: avatar, name, a detail line and the pills that qualify them. `row` beside a title, `hero` centred on its own; `unknown` draws the placeholder mark. | `name`, `detail`, `pills`, `size`, `unknown`. | Decide what the pills say. |

## Page structure and layout

| | Owns | Takes | Never |
|---|---|---|---|
| `ActionPage` | Header (title, subtitle, actions, optional leading icon), centred content column of a named width (`content` / `reading` / `focus`), optional back link, optional pinned footer, scrolling. | `title`, `subtitle`, `actions`, `child`, `width`, `backLabel`/`onBack`, `footer`. | Own chrome; know the router. |
| `ActionSectionHeader`, `ActionEyebrow` | A section title with a hint and trailing control; the small uppercase label. | `title`, `hint`, `trailing` / `text`, `accent`. | Decide what a section contains. |
| `ActionBodyText` | Body copy at the right size and colour. | `text`, `large`, `muted`, `center`. | Format anything. |
| `ActionStack` | Vertical rhythm as a name (`tight` / `group` / `section` / `page`). | `children`, `rhythm`, `align`, `expand`. | Take a number. |
| `ActionInline` | Horizontal rhythm, optionally wrapping. | `children`, `rhythm`, `align`, `justify`, `wrap`. | Take a number. |

## Actions

| | Owns | Takes | Never |
|---|---|---|---|
| `ActionButton` | The pill button in three weights (`filled` / `outlined` / `text`) and two sizes; busy state. | `label`, `onPressed`, `variant`, `size`, `icon`, `expand`, `busy`. | Restyle beyond the theme. |
| `ActionIconButton` | An icon-only action with a mandatory tooltip. | `icon`, `tooltip`, `onPressed`. | Exist without a label. |
| `ActionLink`, `ActionBackLink` | An inline link; the fixed-chevron back link. | `label`, `onTap`, `icon`. | Navigate itself. |
| `ActionRowAction` | The 44px pill action inside a card or row — "Check in", "Open", "View history". | `label`, `onPressed`, `icon`, `filled`, `expand`. | Be smaller than a thumb. |
| `ActionSegmentedToggle` | A pill of 2–3 mutually exclusive options with exactly one selected. | `segments` (`ActionSegment(value, label, icon)`), `value`, `onChanged`. | Navigate between things; hold its own selection. |
| `ActionMenuEntry` | One row in any menu: 44px, icon, destructive tint. | A `ActionMenuItem`. | Open a menu. |

## Lists

| | Owns | Takes | Never |
|---|---|---|---|
| `ActionListRow` | A row: tinted icon disc, title, subtitle, trailing control. A tappable row shows a chevron unless given its own trailing. `emphasis` washes the row in a tone, for an entry that must stand out among its siblings. | `title`, `subtitle`, `icon` + `iconTone`, `trailing`, `onTap`, `emphasis`. | Decide what its subtitle says. |
| `ActionListCard` | A card whose content is a list of rows, hairlined between them — it owns the inset and the dividers so a screen writes neither. | `children`. | Care what the rows are. |
| `ActionListDivider` | The inset hairline, for a card composing its own rows. | — | Appear at the ends of a list. |

## Fields

| | Owns | Takes | Never |
|---|---|---|---|
| `ActionSearchField` | The search box above a list, with a clear button once there is something to clear. | `hint`, `value`, `onChanged`, `onClear`. | Hold the text — the view model does. |
| `ActionNoteField` | A multi-line note — a reflection, an answer — with a footnote saying where it goes. | `value`, `onChanged`, `hint`, `footnote`, `minLines`. | Save anything. |
| `ActionSwitchRow` | A labelled switch whose whole row is the target, not just the 26px control. | `title`, `subtitle`, `icon`, `value`, `onChanged`, `onTone`. | Know what the switch means. |
| `ActionValueRow` | A setting and its current value, opening a chooser — "Remind me · Weekly ›". | `label`, `value`, `icon`, `onTap`. | Present the chooser. |


## Surfaces, status and feedback

| | Owns | Takes | Never |
|---|---|---|---|
| `ActionCard` | The grouped surface with a named density; tappable with a semantic label. | `child`, `density`, `onTap`, `semanticLabel`. | Take an `EdgeInsets` from a screen. |
| `ActionAvatar` | An initial on a neutral disc in four named sizes; `pending` for never-signed-in. | `name`, `size`, `pending`. | Fetch a photo. |
| `ActionPill` | A small tinted label carrying a meaning — a theme, a streak, a delta, a status. | `label`, `tone`, `icon`. | Take a colour. |
| `ActionMetric` | One reading: label, value, optional unit, delta and caption. `compact` is the small form used three-up. | `label`, `value`, `unit`, `caption`, `delta`, `compact`. | Decide whether a value is good. |
| `ActionTrendLine` | Direction of travel over the last few values, deliberately unlabelled and unscaled — it answers "is this going the right way", not "what exactly was it in March". | `values`, `startLabel`, `endLabel`, `highlightLast`. | Be read as a chart. |
| `ActionBanner` | A tinted note beside content; `outlined` marks something provisional rather than current. | `message`, `title`, `icon`, `tone`, `outlined`, `trailing`. | Decide its own tone. |
| `ActionEmptyState` | Nothing-here, working-on-it (`busy`) and could-not-load states with an optional action. | `message`, `detail`, `icon`, `busy`, `child`, `action`. | Decide the sentence. |
