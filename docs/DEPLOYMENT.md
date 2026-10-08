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

- `firebase.json` — Hosting config: serves `build/web`, rewrites all paths to `/index.html` (SPA), `no-cache` on `index.html` / `flutter_bootstrap.js` / `flutter_service_worker.js` / `version.json` so new releases are picked up immediately, 1-hour cache on other assets.
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
| Push to `main` | analyze + test all three packages → `flutter build web` → deploy to the **live** site |
| Pull request (same repo) | analyze + test → build → deploy to preview channel `pr-<number>` (expires after 7 days) → URL commented on the PR |
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
flutter build web --release
firebase deploy --only hosting --account gvanberkel@gmail.com
```

Preview channel (temporary URL, does not touch live):

```bash
firebase hosting:channel:deploy preview --account gvanberkel@gmail.com
```

Rollback: Firebase console → Hosting → Release history → ⋮ → Roll back.

## Notes

- Since October 2026 Firebase no longer auto-provisions the default Hosting site for new projects; it was provisioned via the console "Get started" flow on 2026-10-08.
- Tooling at setup time: Flutter 3.47.2 (Dart 3.13.2), firebase-tools 15.28.1, Node 22.18.0.
