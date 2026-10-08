# Domain & DNS

## Domain

| Item | Value |
|---|---|
| Registered domain | `pragmatic-abstraction.co.za` |
| Registrar / DNS host | GoDaddy (account used: gvanberkel@gmail.com Chrome profile) |
| Registered | 2026-10-08 (expires 2027-10-08) |
| Nameservers | `ns37.domaincontrol.com`, `ns38.domaincontrol.com` (GoDaddy default) |
| App hostname | `four.pragmatic-abstraction.co.za` |
| DNS management | https://dcc.godaddy.com/control/portfolio/pragmatic-abstraction.co.za/settings?tab=dns |

## Records added for this app

| Type | Name | Value | TTL | Purpose |
|---|---|---|---|---|
| CNAME | `four` | `four-questions-d1c19.web.app` | 1 hour | Points the subdomain at Firebase Hosting; also proves ownership to Firebase ("Quick set-up" mode) |

Firebase issues the SSL certificate automatically once it sees the CNAME (usually minutes, can take up to 24h).

Firebase custom-domain status: console → Hosting → Domains → `four.pragmatic-abstraction.co.za`.

## Pre-existing GoDaddy records (left untouched)

| Type | Name | Value |
|---|---|---|
| A | `@` | Parked (GoDaddy parking page) |
| CNAME | `www` | `pragmatic-abstraction.co.za.` |
| CNAME | `_domainconnect` | `_domainconnect.gd.domaincontrol.com.` |
| TXT | `_dmarc` | `v=DMARC1; p=quarantine; ...` |
| NS / SOA | `@` | GoDaddy defaults |

## Checking DNS

```powershell
# Ask GoDaddy's nameserver directly (works before public propagation)
Resolve-DnsName four.pragmatic-abstraction.co.za -Type CNAME -Server ns37.domaincontrol.com
# Public resolvers
Resolve-DnsName four.pragmatic-abstraction.co.za -Server 8.8.8.8
```

## Known issue at setup time (2026-10-08)

The domain was registered the same day. The `.co.za` registry (ZACR) had not yet published the delegation, so public resolvers returned `NXDOMAIN` for `pragmatic-abstraction.co.za` even though GoDaddy's nameservers already served the zone. Until the registry delegation appears, the custom domain won't resolve and Firebase can't verify it or issue SSL. Nothing needs changing — once delegation is live, open the Firebase domain entry and click **Verify** (it also re-checks automatically).

## Adding more apps later

For another subdomain on Firebase, add it in Firebase (Hosting → Add custom domain) and create the CNAME it asks for in GoDaddy. For the apex domain (`pragmatic-abstraction.co.za`) Firebase will ask for A records + a TXT record instead of a CNAME, and the GoDaddy "Parked" A record must be removed.
