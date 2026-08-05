# Public Release

The Public Release site is the outward-facing presence of NeuNuc. It hosts marketing pages, documentation for external users, download links, and the sovereign stack builder funnel.

Public Release is the boundary between internal systems and the outside world. It is a static site (no server-side logic) deployed to a CDN. All dynamic features (waitlists, downloads, analytics) are handled by edge functions or third-party services. This keeps the public surface minimal and fast.

**Location:** `apps/neunuc-public-release/`

Stack:
- Static site generator (11ty or Vite)
- Deployed to Netlify or Cloudflare Pages
- Edge functions for form handling
- Analytics via Plausible or GA4

```powershell
cd apps/neunuc-public-release
pnpm run build
pnpm run deploy
```

## Sovereign Stack Builder

The sovereign stack builder is a guided funnel that lets visitors configure their own NeuNuc instance. They select components (runtime, metasystem, bot), enter their infrastructure details, and receive a customized deployment script.

- **Source:** `apps/neunuc-public-release/src/builder/`
- **Output:** Terraform/Bicep scripts or Docker Compose files
- **Integration:** Stripe for paid tiers

```javascript
// Builder config flow
const stack = builder.createStack({
  components: ["runtime", "metasystem"],
  infra: "azure",
  tier: "pro"
});

const script = stack.generateScript("terraform");
download(script, "neunuc-stack.tf");
```

## Marketing Pages

Marketing pages are designed for conversion: landing, features, pricing, case studies. They are static HTML with minimal JavaScript. A/B tests run via Netlify split testing or edge function routing.

- **Pages:** `src/pages/` or `src/site/`
- **Assets:** `public/` (images, fonts, favicon)
- **SEO:** Meta tags, structured data, sitemap.xml

```html
<!-- Landing page hero -->
<section class="hero">
  <h1>NeuNuc: Local-First AI Infrastructure</h1>
  <p>Run models, manage knowledge, and automate ops — on your hardware.</p>
  <a href="/builder" class="cta">Build Your Stack</a>
</section>
```

## Analytics

Analytics track visitor behavior, conversion funnels, and builder completion rates. Data is anonymized and stored in the analytics provider. No PII is collected without explicit consent.

- **Provider:** Plausible (privacy-first) or GA4 (if configured)
- **Events:** Page views, CTA clicks, builder steps, download starts
- **Dashboard:** Accessed via marketing lens in operator dashboard

```javascript
// Event tracking
plausible("Builder Step Completed", {
  props: { step: 3, components: ["runtime", "metasystem"] }
});
```

## Deployment Pipeline

Public Release deploys automatically on push to the `release` branch. The pipeline builds the site, runs Lighthouse audits, and deploys to the CDN. Rollbacks are instant via CDN purge.

- **CI:** `.github/workflows/neunuc-public-release.yml`
- **Build:** `pnpm run build`
- **Test:** Lighthouse CI
- **Deploy:** Netlify CLI or Cloudflare Pages

```yaml
# .github/workflows/neunuc-public-release.yml
name: Deploy Public Release
on:
  push:
    branches: [release]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pnpm install
      - run: pnpm run build
      - run: pnpm run lighthouse
      - run: pnpm run deploy
```
