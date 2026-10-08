# action_design_system

Pure-UI design system for four-questions. Brand-agnostic, backend-agnostic,
routing-agnostic.

**The catalogue — every component, what it owns, what it takes and what it
never does — is [COMPONENTS.md](COMPONENTS.md).** Browse it running:
`example/` is a gallery app (`.claude/launch.json` → `action-gallery`, or
`cd example && flutter run -d web-server --web-port 5312`).

## The contract

`test/purity_test.dart` fails the build if `lib/` imports Firebase, `get_it`,
`provider`, `go_router`, storage, the host app, or the brand package. It also
rejects `flutter_slick`'s `navigation/` and `services/` layers — only the pure
parts (layout widgets, utils) are allowed.

Taking content as a value and behaviour as a callback is what keeps a
component honest: it can only ever render what the screen handed it.

## Every component lives here. The app builds from them exclusively.

**No widget is defined in the app (`app/`, package `four_questions`).** Atomic or composite, if it renders
something it belongs in this package, and screens compose it from here. When a
screen needs a control that does not exist yet, the component is added to this
package *first* and then used — never built inline "for now".

This is enforced: `app/test/component_discipline_test.dart` fails
the build when a screen constructs a raw Material widget that has — or should
have — an `Action*` equivalent. Its denylist grows every time a component is
added here: adding `ActionButton` means adding `FilledButton` to the
denylist in the same commit, so the raw one can never come back.

## Three rules every component obeys

1. **Content is a value, behaviour is a callback.** A component takes strings,
   enums and models in and reports taps out. It never fetches, navigates,
   formats a date, counts, sorts or decides.
2. **Colour is a tone, resolved through the theme.** `ActionTone` is the
   only colour vocabulary a component accepts. No component imports a brand.
3. **Layout is the screen's, rhythm is ours.** Screens keep `Column`, `Row`,
   `Expanded` and the wiring between components; they stack with
   `ActionStack` and `ActionInline`, whose gaps are names. They never
   define widgets and never write a size.

## Brands

The brand contract is `ActionBrand` (`lib/foundations/brands/`). Concrete
brands live in `../themes/` — `bron_hovi_theme` today — and the host app
composes the two in `main.dart`. `buildActionTheme(brand)` is the only
place a brand becomes a `ThemeData`.

## Adding a component

One commit, four things: the component under `lib/components/<group>/`, its
export in `lib/action_design_system.dart`, its row in `COMPONENTS.md`, and
its gallery entry in `example/lib/main.dart`. If it replaces a raw Material
widget, that widget goes on the app's denylist in the same commit.
