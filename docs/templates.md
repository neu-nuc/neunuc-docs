# Templates & Builders

Static site templates and builder scaffolds for outreach, landing pages, and operational surfaces.

---

## What Lives Here

Builders are JSON-configured static HTML sites. No build step required — edit `site-config.json`, swap assets, and deploy.

**Location:** `apps/neunuc-ops-workspace/templates/builders/`

Current builders:
- `public-access/` — Multi-page outreach site (index, about, services, contact, etc.)

## Public Access Builder

The default outreach site template. A complete static site with product cards, pricing tables, lead capture, and privacy-first analytics.

- **Location:** `apps/neunuc-ops-workspace/templates/builders/public-access/`
- **Stack:** Pure HTML5, CSS3, vanilla JS
- **Config:** `site-config.json` drives all content
- **Deploy:** Direct upload to Cloudflare Pages

```powershell
cd apps/neunuc-ops-workspace/templates/builders/public-access
# Edit site-config.json, then deploy
wrangler pages deploy .
```

### Pages Included

| Page | File | Purpose |
|------|------|---------|
| Home | `index.html` | Landing with product cards + pricing |
| About | `about.html` | Company / founder narrative |
| Services | `services.html` | Service detail pages |
| Method | `method.html` | Process / approach explainer |
| Resources | `resources.html` | Downloads, docs, links |
| Contact | `contact.html` | Lead capture form + Turnstile |
| Accessibility | `accessibility.html` | WCAG statement |
| Privacy | `privacy.html` | Privacy policy |
| Terms | `terms.html` | Terms of service |
| 404 | `404.html` | Fallback page |

### Configuration

Edit `site-config.json`:

```json
{
  "site": {
    "name": "NeuNuc",
    "tagline": "Ship smarter. Scale faster.",
    "url": "https://neunuc.com"
  },
  "products": [
    {
      "id": "box-fulfillment",
      "name": "Box Fulfillment",
      "price": 29,
      "period": "month"
    }
  ],
  "integrations": {
    "turnstile": {
      "enabled": true,
      "siteKey": "0x4AAAA..."
    },
    "stripe": {
      "checkoutUrl": "https://neunuc-checkout.helkelx.workers.dev"
    },
    "analytics": {
      "provider": "plausible",
      "domain": "neunuc.com"
    }
  }
}
```

### File Structure

```
templates/builders/public-access/
├── index.html              # Landing page
├── about.html
├── services.html
├── method.html
├── resources.html
├── contact.html
├── accessibility.html
├── privacy.html
├── terms.html
├── 404.html
├── styles.css              # Single stylesheet
├── site-custom.css         # Override layer
├── app.js                  # Form handling + analytics init
├── site-config.json        # Content + integrations
├── site_manifest.json      # PWA manifest
├── _headers                # Cloudflare Pages headers
├── _redirects              # Redirect rules
└── favicon.svg
```

### Customization

**Change brand colors:**

Edit `site-custom.css`:

```css
:root {
  --accent: #4a7a9e;
  --text: #1a1a1a;
  --surface: #f7f8f9;
}
```

**Add a product:**

1. Add product object to `site-config.json → products`
2. Add product image to the directory
3. Reference image in config

**Swap analytics provider:**

```json
{
  "integrations": {
    "analytics": {
      "provider": "cloudflare",
      "token": "your-cf-token"
    }
  }
}
```

## Creating a New Builder

To scaffold a new builder, copy the public-access directory and replace the HTML files:

```powershell
# From repo root
Copy-Item -Recurse apps/neunuc-ops-workspace/templates/builders/public-access `
  apps/neunuc-ops-workspace/templates/builders/my-builder

cd apps/neunuc-ops-workspace/templates/builders/my-builder

# Edit config
notepad site-config.json

# Deploy
wrangler pages deploy .
```

A builder needs only:
- Static HTML files
- `site-config.json` for content
- Optional `site-custom.css` for theme overrides
- Optional JS for form handling

## Deploy Checklist

Before deploying any builder:

- [ ] `site-config.json` has correct site URL and name
- [ ] Product data and pricing are current
- [ ] Turnstile site key is set (if enabled)
- [ ] Stripe checkout URL points to active worker
- [ ] Analytics domain matches deploy target
- [ ] Privacy policy reflects actual data practices
- [ ] `_headers` and `_redirects` are configured
- [ ] `404.html` exists
