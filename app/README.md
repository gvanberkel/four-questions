# Four Questions

A Flutter web app that asks the family a few questions once a day, one at a
time, and keeps the answers in a Google Sheet. Hosted on Firebase Hosting.

**Live URL:** https://four.pragmatic-abstraction.co.za
**Fallback URLs:** https://four-questions-d1c19.web.app · https://four-questions-d1c19.firebaseapp.com

## Quick start

```bash
flutter pub get
flutter run -d chrome --wasm                    # local dev (Google sign-in)
flutter run -d chrome --dart-define=DEMO=true   # no Google: demo account, pretend sheet
flutter build web --release --wasm              # production build -> build/web
git push                                        # CI deploys main automatically (see ../docs/DEPLOYMENT.md)
```

Sign-in needs a one-off Google Cloud setup and the OAuth client ID in
`lib/config.dart` — see [../docs/GOOGLE-SIGN-IN.md](../docs/GOOGLE-SIGN-IN.md).

## What it does

1. **Sign in with Google.** The account must be able to edit the sheet;
   otherwise the app says so and stops there.
2. **First time only:** asks the name the person goes by and saves it on the
   *People* sheet. Others see it in "Answered by Hovi today".
3. **The questions**, one at a time: every *active* question on the
   *Questions* sheet, in sheet order. Yes / No (nothing chosen until you
   choose) when the question is a yes/no one, a notes box when it allows
   notes. Back, Skip / Next, and the step track at the top go anywhere in
   the set. A question someone else has answered today carries an
   "Answered by … today" tag.
4. **The summary**: each question and your answer, who else has answered
   today, and a way back into any question to change it. Opening the app
   when everything is answered goes straight here; otherwise it opens on the
   first unanswered question.

## The sheet

The spreadsheet ID is in [`lib/config.dart`](lib/config.dart). Columns are
found by their header, so they can be reordered (and a few renamed — see
`SheetColumn` in [`lib/data/sheet_table.dart`](lib/data/sheet_table.dart)).

| Sheet | Columns | Notes |
|---|---|---|
| **Questions** | Question ID · Question · Active · Yes/No · Allow notes | Flags are `Yes` / `No` (or checkboxes). A question that is neither yes/no nor allows notes gets a notes box, so it can be answered. |
| **Answers** | Date · Question ID · Answered By · Yes/No · Note | One row per person, question and day. Changing an answer rewrites that row; if there are two, the lower one wins. *Answered By* is the Google account email. |
| **People** | Email · Name | Created by the app on the first sign-in if missing. Edit a name here and the app picks it up. |

Notes starting with `=`, `+`, `-` or `@` are written with a leading `'` so
Sheets keeps them as text.

## The splash

`web/index.html` draws the question screen in grey — bar, mark, step track,
Yes / No, notes, footer — in plain HTML and CSS, so something is on screen
before the Flutter engine has downloaded. It follows the light / dark choice
(the OS, or the account menu's, read from localStorage before first paint).
`lib/splash/splash_handoff.dart` fades it out at the first real screen; a
token renewal and a first visit waiting on the sheet stay behind it, and an
8-second backstop takes it down regardless. `test/splash_handoff_test.dart`
pins which screens hand over. Its colours are copied from the brand: change
`themes/bron_hovi_theme` and change them too.

## Local first

Everything the screens need — questions, today's answers, names — is kept on
the device (localStorage). Each launch draws from it immediately, then
refreshes from the sheet and redraws if anything changed. An answer is kept
on the device the moment it is given and the app moves on; it is sent to the
sheet in the background (notes after a short pause in typing), retried with
backoff while the sheet can't be reached, and survives closing the tab. The
bar shows **Saving…** while anything is on its way and **Saved on device**
while it is waiting to retry.

## Code map

| | |
|---|---|
| `lib/app_controller.dart` | Which screen, and everything that moves it: sign-in, token renewal, access check, the walk through the questions. |
| `lib/check_in/check_in_store.dart` | Today's questions and answers: local first, background sync. |
| `lib/data/` | The sheet (`google_sheets_gateway.dart`, its pure parsing in `sheet_table.dart`, and the demo sheet) and the device store. |
| `lib/auth/` | Google sign-in by redirect, behind a small `Browser` seam so it is testable. |
| `lib/screens/` | Wiring only: every pixel comes from `action_design_system`. `test/component_discipline_test.dart` enforces it. |

## Docs

- [../docs/GOOGLE-SIGN-IN.md](../docs/GOOGLE-SIGN-IN.md) — sign-in, the Sheets API, one-off Google Cloud setup, troubleshooting
- [../docs/DEPLOYMENT.md](../docs/DEPLOYMENT.md) — Firebase project, CLI accounts, build & deploy steps
- [../docs/DOMAIN-DNS.md](../docs/DOMAIN-DNS.md) — custom domain, GoDaddy DNS records, troubleshooting
