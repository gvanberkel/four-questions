# Deployment

## Overview

| Item | Value |
|---|---|
| App type | Flutter web (single page) in `app/`, built to static files in `app/build/web` |
| Host | Firebase Hosting |
| Google / Firebase account | gvanberkel@gmail.com |
| Firebase project name | `four-questions` |
| Firebase project ID | `four-questions-d1c19` |
| Hosting site ID | `four-questions-d1c19` (default site) |
| Plan | Spark (free) |
| Google Analytics / Gemini | Disabled |
| Console | https://console.firebase.google.com/project/four-questions-d1c19/hosting |
| Default URLs | https://four-questions-d1c19.web.app, https://four-questions-d1c19.firebaseapp.com |
| Custom domain | https://four.pragmatic-abstraction.co.za (see [DOMAIN-DNS.md](DOMAIN-DNS.md)) |
| Source repo | https://github.com/gvanberkel/four-questions |

## Config files

Both live in `app/` — run all `firebase` commands from there.

- `firebase.json` — Hosting config: serves `build/web`, rewrites all paths to `/index.html` (SPA), `no-cache` on `index.html` / `flutter_bootstrap.js` / `flutter_service_worker.js` / `version.json` and on every extensionless path (`/` and the app's routes, which are served `index.html` by the rewrite — header rules match the requested path, not the rewritten one) so new releases are picked up immediately, 1-hour cache on other assets. Every response carries `Cross-Origin-Opener-Policy: same-origin` and `Cross-Origin-Embedder-Policy: credentialless` (see [WebAssembly](#webassembly)).
- `.firebaserc` — maps the `default` alias to `four-questions-d1c19`.

## Firebase CLI accounts

This machine's Firebase CLI is also logged in to a work account (gregvb@tfn.co.za). The project lives under **gvanberkel@gmail.com**, so always deploy with that account:

```bash
firebase login:list                                   # see accounts
firebase deploy --only hosting --account gvanberkel@gmail.com
```

Or make it the default for this folder (stored per-directory in the CLI config, not in the repo):

```bash
firebase login:use gvanberkel@gmail.com
```

Adding the account (one-off) — must be run from a normal terminal. If run from a shell spawned by Claude Code, the CLI sees `CLAUDECODE=1` and refuses interactive login; clear it first:

```powershell
Remove-Item Env:CLAUDECODE -ErrorAction SilentlyContinue; firebase login:add
```

## Continuous deployment (GitHub Actions)

Workflow: [`.github/workflows/deploy.yml`](../.github/workflows/deploy.yml)

| Trigger | What happens |
|---|---|
| Push to `main` | analyze + test all three packages → `flutter build web --wasm` → deploy to the **live** site |
| Pull request (same repo) | analyze + test → build → deploy to preview channel `pr-<number>` (expires after 7 days) → URL commented on the PR. Google sign-in does not work on preview URLs (see [GOOGLE-SIGN-IN.md](GOOGLE-SIGN-IN.md#limits)). |
| Pull request from a fork | analyze + test + build only (forks get no deploy credentials) |
| Manual (Actions tab → Deploy → Run workflow) | same as push to `main` |

Analyze or test failures stop the run before anything is deployed. Flutter is pinned to `FLUTTER_VERSION` in the workflow; bump it there when you upgrade locally.

### Keyless auth (Workload Identity Federation)

GitHub has **no stored Google key or secret**. Each run swaps GitHub's short-lived OIDC token for short-lived Google credentials.

| GCP resource | Value |
|---|---|
| Project number | `639658462449` |
| Workload identity pool | `github` (global) |
| OIDC provider | `github` — issuer `https://token.actions.githubusercontent.com`, condition `assertion.repository == 'gvanberkel/four-questions'` |
| Service account | `github-deployer@four-questions-d1c19.iam.gserviceaccount.com` |
| SA project roles | `roles/firebasehosting.admin`, `roles/serviceusage.serviceUsageConsumer` |
| Who may impersonate the SA | `principalSet://iam.googleapis.com/projects/639658462449/locations/global/workloadIdentityPools/github/attribute.repository/gvanberkel/four-questions` (`roles/iam.workloadIdentityUser`) |

Only workflows in `gvanberkel/four-questions` can use it. If the repo is renamed or moved, update the provider condition and the principalSet binding.

The resources were created with gcloud as gvanberkel@gmail.com. gcloud's default account on this machine is still the work account, so pass `--account=gvanberkel@gmail.com --project=four-questions-d1c19` to gcloud commands for this project.

## Manual build & deploy

Normally not needed (see above), but useful for hotfixes or when Actions is down:

```bash
cd app
flutter pub get
flutter build web --release --wasm
firebase deploy --only hosting --account gvanberkel@gmail.com
```

Always build with `--wasm`, as CI does; a plain `flutter build web` deploys a JS-only app.

Preview channel (temporary URL, does not touch live):

```bash
firebase hosting:channel:deploy preview --account gvanberkel@gmail.com
```

Rollback: Firebase console → Hosting → Release history → ⋮ → Roll back.

## WebAssembly

The app ships as a WebAssembly build (`flutter build web --wasm`). The output contains both `main.dart.wasm` and the JavaScript build; `flutter_bootstrap.js` loads Wasm in browsers with WasmGC (Chrome / Edge 119+) and falls back to JavaScript elsewhere (Safari, Firefox, every iOS browser).

- **Headers.** The Wasm renderer runs multi-threaded only when the page is cross-origin isolated, hence the COOP / COEP headers in `firebase.json`. `credentialless` (rather than `require-corp`) still lets the page load cross-origin resources without CORP headers, such as Flutter's fallback fonts from `fonts.gstatic.com`; such requests go without cookies. Without the headers the app still runs, single-threaded. `same-origin` would cut a sign-in popup off from the page, which is why Google sign-in goes by redirect instead (see [GOOGLE-SIGN-IN.md](GOOGLE-SIGN-IN.md)).
- **Packages.** Code that imports `dart:html`, `dart:js` or `package:js` does not compile to Wasm — use `package:web` and `dart:js_interop`. A dependency that breaks this fails the CI build, with the import chain at the top of the error.
- **Checking.** In Chrome DevTools → Network, the page loads `main.dart.wasm` (and `main.dart.mjs`) instead of `main.dart.js`. In code, `const bool.fromEnvironment('dart.tool.dart2wasm')` is true under Wasm.
- **Local dev.** `flutter run -d chrome --wasm`.

## Notes

- Since October 2026 Firebase no longer auto-provisions the default Hosting site for new projects; it was provisioned via the console "Get started" flow on 2026-10-08.
- Tooling at setup time: Flutter 3.47.2 (Dart 3.13.2), firebase-tools 15.28.1, Node 22.18.0.
