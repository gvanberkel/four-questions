# Google sign-in and the Sheets API

Four Questions signs people in with Google and reads and writes the
[Four Questions sheet](https://docs.google.com/spreadsheets/d/196o_v9iuMYy5h91ovrL0kaGdz444bMcTfesXMf_gpaM/edit)
directly from the browser, with the person's own access token. There is no
backend: whoever signs in can use the app only if their Google account can
**edit** the sheet.

## How it works

- **Redirect, not popup.** The app uses Google's OAuth 2.0 token flow for
  browser apps (`response_type=token id_token`). The page goes to
  `accounts.google.com` and comes back to `https://<site>/` with an access
  token in the URL fragment, which the app reads and removes before anything
  else runs ([`google_auth.dart`](../app/lib/auth/google_auth.dart)). A popup
  would not work here: `firebase.json` sends
  `Cross-Origin-Opener-Policy: same-origin` (for multi-threaded Wasm), which
  cuts a popup off from the page that opened it.
- **Scopes.** `openid email profile` (who you are) and
  `https://www.googleapis.com/auth/spreadsheets` (read and write sheets you
  can access). If the person unticks the Sheets box on Google's consent
  screen, the app explains why it needs it and does not continue.
- **Renewal without a tap.** Access tokens last an hour. When the app opens,
  or the tab comes back into view, with a token that has expired (or has less
  than 5 minutes left), it does a `prompt=none` round trip with
  `login_hint=<email>`: Google sends it straight back with a new token, no
  screen shown, in about a second. Everything the person was doing is kept on
  the device, including which question they were on, so the round trip loses
  nothing. If Google needs to ask something (signed out of Google, consent
  withdrawn), the sign-in screen offers **Continue as <name>** instead. A
  silent attempt is made at most once a minute, so it cannot loop.
- **Edit access.** After sign-in the app sends an empty `batchUpdate` to the
  spreadsheet: it changes nothing but is refused (403) for anyone who cannot
  edit. Such accounts get the "You need edit access" screen. The result is
  remembered per account, so later launches don't wait for the check.
- **Signing out** forgets the account, token and cached data on the device.

## One-off setup (Google Cloud project `four-questions-d1c19`)

The Firebase project is also a Google Cloud project; sign-in uses the same
one. All steps as **gvanberkel@gmail.com**.

1. **Enable the Google Sheets API**

   ```bash
   gcloud services enable sheets.googleapis.com --account=gvanberkel@gmail.com --project=four-questions-d1c19
   ```

   or console → APIs & Services → Library → Google Sheets API → Enable.

2. **Configure the consent screen**: console → Google Auth Platform.
   - *Branding*: app name **Four Questions**, your support email, home page
     `https://four.pragmatic-abstraction.co.za`, privacy policy
     `https://four.pragmatic-abstraction.co.za/privacy/` (served from
     [`app/web/privacy/index.html`](../app/web/privacy/index.html); keep it
     true to what the app reads, keeps and sends), authorised domain
     `pragmatic-abstraction.co.za`. Publishing needs the privacy link.
   - *Audience*: **External**, **In production** (published 8 October 2026),
     so any Google account can sign in; the sheet's sharing decides who gets
     past sign-in. The app is not verified by Google, so with the sensitive
     Sheets scope each person sees "Google hasn't verified this app" once and
     goes through **Advanced → Go to Four Questions (unsafe)**, and the app
     is capped at 100 users over its lifetime. *Back to testing* would limit
     sign-in to the accounts under *Test users* again.
   - *Data access*: `openid`, `.../auth/userinfo.email`,
     `.../auth/userinfo.profile` and `.../auth/spreadsheets`.

3. **Create the OAuth client**: Google Auth Platform → Clients → Create
   client → **Web application**, name `Four Questions web`.
   - *Authorised redirect URIs* (exact, including the trailing slash):
     - `https://four.pragmatic-abstraction.co.za/`
     - `https://four-questions-d1c19.web.app/`
     - `https://four-questions-d1c19.firebaseapp.com/`
     - `http://localhost:5310/` (local dev, `.claude/launch.json` →
       `four-questions`)
   - *Authorised JavaScript origins* are not needed for the redirect flow.

4. **Put the client ID in the app.** Copy the client ID
   (`…apps.googleusercontent.com`) into `googleClientId` in
   [`app/lib/config.dart`](../app/lib/config.dart). A web client ID is
   public by design (it is visible in every sign-in URL), so it is committed;
   there is no client secret in this flow. A build can override it with
   `--dart-define=GOOGLE_CLIENT_ID=…`.

5. **Share the sheet** with each person's Google account as an **Editor**.

## Limits

- **Preview channels can't sign in.** Their URLs
  (`four-questions-d1c19--pr-12-….web.app`) change per PR, and redirect URIs
  can't be wildcards. Use local dev, or the demo build, to try changes.
- **Home-screen installs on iOS.** A redirect out of a standalone (home
  screen) web app on iOS can come back in an in-app browser sheet rather
  than the app itself. Opening the site in Safari always works.

## Trying the app without Google

```bash
cd app
flutter run -d chrome --dart-define=DEMO=true
```

The demo build signs in as `demo@example.com` without going to Google and
uses a pretend sheet kept in the browser's localStorage: the real questions,
and "Hovi" has already answered the first one today. `.claude/launch.json` →
`four-questions-demo` runs it on port 5311.

## Troubleshooting

| What you see | Why |
|---|---|
| Google: `Error 400: redirect_uri_mismatch` | The site's address, with a trailing `/`, is not in the client's *Authorised redirect URIs*. |
| Google: "Google hasn't verified this app" | Expected: the app is unverified. **Advanced → Go to Four Questions (unsafe)**. |
| Google: `Error 403: access_denied` | The app was put back in Testing and the account is not a *Test user*. |
| App: "You need edit access" — *Google said: Google Sheets API has not been used in project …* | Step 1: the Sheets API is not enabled. |
| App: "You need edit access" — *The caller does not have permission* | The sheet is not shared with that account as an editor. |
| App: "Sign-in is not set up yet" | `googleClientId` is empty (step 4). |
