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

## Setup timeline (2026-10-08)

- The domain was registered the same day. At first the `.co.za` registry (ZACR) hadn't published the delegation, so public resolvers returned `NXDOMAIN` for `pragmatic-abstraction.co.za` even though GoDaddy's nameservers already served the zone.
- About 30 minutes later the delegation was live, and 1.1.1.1, 8.8.8.8 and 9.9.9.9 all resolved `four` → `four-questions-d1c19.web.app` → `199.36.158.100`.
- Firebase's first **Verify** reported "Records not yet detected", most likely because it still had the earlier negative answer cached. It re-checks automatically, and once it verifies, the SSL cert is provisioned. If it's still stuck after a few hours: Firebase console → Hosting → domain row → **Needs setup** → **Verify**.

## Adding more apps later

For another subdomain on Firebase, add it in Firebase (Hosting → Add custom domain) and create the CNAME it asks for in GoDaddy. For the apex domain (`pragmatic-abstraction.co.za`) Firebase will ask for A records + a TXT record instead of a CNAME, and the GoDaddy "Parked" A record must be removed.
