# Outreach Surfaces
Root-level HTML pages, their purpose, configuration, and deployment.

---

## Explainer

Outreach surfaces are static HTML pages that live at the repository root. They deploy as a single static site to Cloudflare Pages (default) or any static host. Each page is configured via `neunuc.config.json`.

These are not part of the operator workspace or runtime. They are public-facing surfaces for recruitment, pricing, therapy verticals, and system dashboards.

- **Path**: Root `*.html` files
- **Deploy target**: Cloudflare Pages (`neunuc-site`)
- **Config**: `neunuc.config.json → deployment`
- **Headers**: `neunuc.config.json → deployment.securityHeaders`

```powershell
cd C:\Users\mysti\neunuc
npx wrangler pages deploy . --project-name=neunuc --branch=main
```

---

## Page inventory

### Core pages

| Page | Path | Purpose |
|------|------|---------|
| **Home** | `/` | Primary landing — `index.html` |
| **Workbench** | `/workbench.html` | Operator workbench hub |
| **System** | `/system.html` | System dashboard preview |
| **Founder** | `/founder.html` | Founder brief |
| **Pricing** | `/pricing.html` | Pricing tiers and offers |

### Vertical pages

| Page | Path | Purpose |
|------|------|---------|
| **Therapy** | `/therapy.html` | Therapy vertical landing |
| **Research** | `/research.html` | Research vertical landing |
| **Operator** | `/operator.html` | Operator vertical landing |

### Conversion pages

| Page | Path | Purpose |
|------|------|---------|
| **Pilot** | `/pilot.html` | Pilot recruitment form |
| **Waitlist** | `/waitlist.html` | Waitlist signup |
| **Outreach** | `/outreach.html` | Cold email templates |

### Workbench detail pages

| Page | Path | Purpose |
|------|------|---------|
| **Repos** | `/workbench-repos.html` | Repository status overview |
| **Gaps** | `/workbench-gaps.html` | Completion gaps tracker |
| **Memory** | `/workbench-memory.html` | Memory substrate view |
| **Files** | `/workbench-files.html` | Key files index |

---

## Configuration

Each page reads from `neunuc.config.json`:

- **Design tokens**: `design.tokens` — colors, spacing, typography
- **Trust boundary**: `trustBoundary` — privacy notice, data collection flags
- **Integrations**: `integrations.analytics`, `integrations.leadCapture`, `integrations.payments`
- **Deployment**: `deployment.securityHeaders`, `deployment.cachePolicy`

These pages are static and public. There is no authentication layer. Sensitive data must not be embedded in HTML.

---

## Redirects

```
/home      → /              (301)
/workbench  → /workbench.html (200)
/therapy    → /therapy.html   (200)
/research   → /research.html  (200)
/operator   → /operator.html  (200)
/repos      → /workbench-repos.html (200)
/gaps       → /workbench-gaps.html  (200)
/memory     → /workbench-memory.html (200)
/files      → /workbench-files.html  (200)
```

Redirects are declared in `_headers` or `netlify.toml` depending on deploy target.

---

## PWA support

The outreach surfaces include a minimal service worker and web app manifest:

| File | Purpose |
|------|---------|
| `sw.js` | Caches `/`, `/index.html`, `/styles.css`, `/manifest.json` for offline access |
| `manifest.json` | PWA manifest — name, icons, theme colors, display mode |

**Cache behavior:**
- Install: Pre-caches core assets
- Fetch: Cache-first with network fallback
- Activate: Claims all clients immediately

**Manifest values:**
- `name`: "NeuNuc / The Exocortex"
- `short_name`: "NeuNuc"
- `display`: `standalone`
- `theme_color`: `#0a0a0a`

Icons are expected at `/icon-192.png` and `/icon-512.png`.

---

## Security headers

All responses include:

```
X-Frame-Options: SAMEORIGIN
X-Content-Type-Options: nosniff
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
```

Override in `neunuc.config.json → deployment.securityHeaders`.
