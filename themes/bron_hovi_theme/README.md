# bron_hovi_theme

The Bron Hovi brand for the Action design system: `BronHoviBrand`
(colour schemes, typeface, surface styles, name) and `BronHoviMark` (the
mark, painted as a vector).

The brand lives in its own package so `action_design_system` stays
brand-agnostic. Colour decisions change here, never in component code; the
design system's purity test fails if it ever imports this package.

## Status: provisional

There is no published Bron Hovi identity yet. Everything below is a
placeholder chosen for the brand's angle — psychology, personal growth and
shared accountability — and is meant to be replaced wholesale once a real
identity exists. Swapping it is a change to this package only.

| | Value | Why |
|---|---|---|
| Plum | `#553C6E` | Primary. Reflective and calm without being clinical — the psychology. |
| Sage | `#3E7A5A` (tertiary), `#5E9474` (mark) | Growth. Also the positive tone, so "on track" reads green. |
| Clay | `#7A6A62` | Secondary. Warm and human; the neutral tone. |
| Terracotta | `#B0503A` | Attention. Warm rather than alarming. |
| Surfaces | `#FAF7F4` and warm neutrals | Paper rather than screen. |
| Body face | Inter | Copied from `clarifai_theme`; a heading face can be added later. |

## The mark

`BronHoviMark` paints two overlapping rings — you and the person holding you
to it — in plum and sage. The overlap is the point: shared accountability.
There is no raster lockup yet; when there is one, add it under
`assets/logo/` and register the folder in `pubspec.yaml`.

## Fonts

`assets/fonts/` carries Inter (variable cut, SIL OFL 1.1) with its licence
alongside, registered in `pubspec.yaml` under the family name the brand
returns. `headingFontFamily` is not overridden, so headings use Inter too;
to give headings their own face, add the font files here, register the
family, and override `headingFontFamily` in `BronHoviBrand`.

## Using it

```dart
bootstrapApplication(brand: const BronHoviBrand());
```

is the whole integration; see `app/lib/main.dart`. The app's display name —
"Bron Hovi" in the bar — is `BronHoviBrand.name`, so it changes here. The
static manifests (`app/web/manifest.json`, `index.html`) cannot read Dart and
repeat the name by hand; keep them in step.
