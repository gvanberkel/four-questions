# Four Questions

A single-page Flutter web app (will use the [`flutter_slick`](https://pub.dev/packages/flutter_slick) package), hosted on Firebase Hosting.

**Live URL:** https://four.pragmatic-abstraction.co.za
**Fallback URLs:** https://four-questions-d1c19.web.app · https://four-questions-d1c19.firebaseapp.com

## Quick start

```bash
flutter pub get
flutter run -d chrome          # local dev
flutter build web --release    # production build -> build/web
firebase deploy --only hosting # publish (see ../docs/DEPLOYMENT.md)
```

## Docs

- [../docs/DEPLOYMENT.md](../docs/DEPLOYMENT.md) — Firebase project, CLI accounts, build & deploy steps
- [../docs/DOMAIN-DNS.md](../docs/DOMAIN-DNS.md) — custom domain, GoDaddy DNS records, troubleshooting
