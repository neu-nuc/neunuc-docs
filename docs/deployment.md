# Deployment
## Static outreach surfaces

Root-level HTML pages (index, workbench, pricing, etc.) deploy to Cloudflare Pages.

### Manual deploy

```powershell title="PowerShell"
cd C:\Users\mysti\neunuc
$env:CLOUDFLARE_ACCOUNT_ID="209a42bba413983b57fde823455772f3"
npx wrangler pages deploy . --project-name neunuc-site --branch main
```

Or use the script:

```powershell title="PowerShell"
cd C:\Users\mysti\neunuc
.\scripts\deploy.ps1
```

### Verified pages

| Path | Description |
|------|-------------|
| `/` | Home |
| `/workbench.html` | Workbench hub |
| `/therapy.html` | Therapy vertical |
| `/research.html` | Research vertical |
| `/operator.html` | Operator vertical |
| `/system.html` | System dashboard |
| `/founder.html` | Founder brief |
| `/pricing.html` | Pricing tiers |
| `/pilot.html` | Pilot recruitment |
| `/outreach.html` | Cold email templates |
| `/waitlist.html` | Waitlist signup |
| `/workbench-repos.html` | Repo status |
| `/workbench-gaps.html` | Completion gaps |
| `/workbench-memory.html` | Memory substrate |
| `/workbench-files.html` | Key files |

### Redirects

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

### Security headers

All responses include:

```
X-Frame-Options: SAMEORIGIN
X-Content-Type-Options: nosniff
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
```

Headers are declared in `neunuc.config.json → deployment.securityHeaders`.

## Documentation site

```bash
cd C:\Users\mysti\Desktop\neunuc-docs
mkdocs build
npx wrangler pages deploy site --project-name neunuc-docs --branch main
```

## CI / GitHub Actions

Auto-deploy on push:

| Repo | Branch | Target |
|------|--------|--------|
| neunuc | `main` | `neunuc-site` |
| myprice | `master` | `neunuc-io` |

Required secrets in GitHub:

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`

## Custom domains

DNS records:

```bash
CNAME neunuc.io     main.neunuc-site.pages.dev
CNAME app.neunuc.io neunuc-io.pages.dev
```

Wrangler:

```bash
npx wrangler pages domain add neunuc-site neunuc.io
npx wrangler pages domain add neunuc-io app.neunuc.io
```

## Runtime deployment (Docker)

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Python dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Install Node.js (needed for surface bridge)
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY . .

EXPOSE 8400
EXPOSE 3400
CMD ["python", "main.py", "--host", "0.0.0.0", "--port", "8400"]
```

```bash
docker build -t neunuc .
docker run -p 8400:8400 -p 3400:3400 -e NEUNUC_DEVICE=cpu neunuc
```

## nuc CLI packaging

Build single Windows executable:

```powershell
cd apps/nuc-cli
npm run package
# Output: dist/nuc.exe
```

## Deployment checklist

- [ ] `CLOUDFLARE_API_TOKEN` set in GitHub secrets
- [ ] `CLOUDFLARE_ACCOUNT_ID` set in GitHub secrets
- [ ] `wrangler.toml` configured
- [ ] Security headers verified against `neunuc.config.json`
- [ ] Redirects tested
- [ ] Custom domains configured (if applicable)
- [ ] `trustBoundary` flags verified `false` before public deploy
- [ ] Ops workspace is not deployed (local-only by design)
