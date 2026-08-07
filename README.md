# NeuNuc Documentation

NeuNuc system docs — local-first operating layer, monorepo, and deployment guides.

Built with [MkDocs Material](https://squidfunk.github.io/mkdocs-material/). Served with basic auth. Deployed by you, not by a bot.

## Local development

```powershell
cd C:\Users\mysti\Desktop\neunuc-docs
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
$env:PYTHONPATH = (Get-Location).Path; mkdocs serve
```

Open http://127.0.0.1:8000.

## Build

```powershell
$env:PYTHONPATH = (Get-Location).Path; mkdocs build --strict
```

Output is written to `site/`.

## Deploy

### Option 1: Docker (local or private host)

```powershell
# One command: build + run with basic auth
.\infra\docs-host\scripts\deploy-local.ps1

# Or manually:
docker build -t neunuc-docs .
docker run -d --name neunuc-docs -p 127.0.0.1:8080:80 neunuc-docs
```

Access at http://127.0.0.1:8080. Default credentials: `admin` / `docs-local-2026`.

Generate new credentials:
```powershell
.\infra\docs-host\scripts\generate-auth.ps1 -Username admin -Password "your-password-here"
```

### Option 2: GitHub Pages

Push to `main`. The [GitHub Actions workflow](.github/workflows/docs.yml) builds and deploys automatically.

```powershell
git add .
git commit -m "docs: update"
git push origin main
```

### Option 3: Cloudflare Pages

```powershell
mkdocs build
npx wrangler pages deploy site --project-name neunuc-docs --branch main
```

### Option 4: Existing nginx host

Copy `infra/docs-host/nginx/docs.conf` to your host, point it at the built `site/` directory, and reload nginx.

## Project structure

```text
.
├── docs/                      # Markdown source (38 pages)
│   ├── overrides/             # Theme overrides + custom icons
│   ├── stylesheets/           # Sleek monochrome CSS
│   ├── javascripts/           # Custom JS
│   └── assets/                # Logo / favicon
├── infra/docs-host/           # Nginx config + deploy scripts + auth
├── .github/workflows/         # CI/CD for GitHub Pages
├── Dockerfile                 # Container image
├── docker-compose.yml         # One-command local deploy
├── mkdocs.yml                 # Site configuration
├── neunuc_icons.py            # Custom :icon-name: extension
└── requirements.txt           # Python dependencies
```
