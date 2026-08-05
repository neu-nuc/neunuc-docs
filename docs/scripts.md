# Scripts & Automation
The `scripts/` directory contains operator-level automation for deployment, repository hygiene, and repo consolidation. These are not app-level scripts. They are cross-cutting tools that operate on the monorepo and its external surfaces.

These scripts are the glue between the monorepo and the outside world. They deploy sites, audit repos, clean branches, and migrate micro-repos into the monorepo. Run them from the repo root.

- **Location:** `scripts/`
- **Stack:** PowerShell, Node.js
- **Prerequisites:** `npx wrangler` (deploy), `gh` CLI (audit, cleanup, consolidation)
- **Invocation:** `node scripts/<script>.mjs [args]` or `scripts/deploy.ps1`

```bash
# Deploy both sites to Cloudflare Pages
.\scripts\deploy.ps1

# Audit all repos in the neu-nuc org
node scripts/repo-audit.mjs

# Clean stale branches in neunuc (dry run first)
node scripts/branch-cleanup.mjs --repo=neunuc --dry-run

# Migrate a micro-repo into the monorepo
node scripts/consolidation-helper.mjs --source=neunuc-cli --target=apps/neunuc-cli
```

---

## deploy.ps1

Deploys both public surfaces to Cloudflare Pages:

| Site | Source | Project name | URL |
|---|---|---|---|
| neunuc-site | Repo root (`C:\Users\mysti\neunuc`) | `neunuc-site` | `https://main.neunuc-site.pages.dev` |
| neunuc-io | `myprice/apps/web/dist` | `neunuc-io` | `https://neunuc-io.pages.dev` |

**Requires:**
- `npx wrangler` authenticated via OAuth
- `CLOUDFLARE_ACCOUNT_ID` set (hardcoded in script)
- Both source directories built and ready

**Behavior:**
- Fails fast on any deploy error (`$ErrorActionPreference = "Stop"`)
- Prints final URLs on success

---

## repo-audit.mjs

Inventories all repos in the `neu-nuc` GitHub org and classifies them by health.

**Usage:**
```bash
node scripts/repo-audit.mjs
node scripts/repo-audit.mjs --org=neu-nuc --output=.repo-audit --stale=90
```

**What it checks:**
- Last push date, branch count, open PRs, stale PRs
- README, package.json, CI workflows, test files
- Local clone presence (checks `../<repo>/.git`)

**Classifications:**

| Class | Criteria |
|---|---|
| `core` | Has tests, CI, and recent activity (or is `neunuc`) |
| `candidate` | ≤2 branches, no tests, not stale |
| `archive` | Stale (>90d) or archived |
| `delete` | Very stale (>180d), no tests, no CI |
| `unknown` | Everything else |

**Outputs:**
- `.repo-audit/audit-report.json` — machine-readable
- `.repo-audit/audit-report.md` — human-readable with per-repo detail

---

## branch-cleanup.mjs

Lists and optionally deletes stale or merged branches in a single repo.

**Usage:**
```bash
# Dry run (recommended first)
node scripts/branch-cleanup.mjs --repo=neunuc --dry-run

# Execute
node scripts/branch-cleanup.mjs --repo=neunuc
```

**Branch statuses:**

| Status | Definition | Action |
|---|---|---|
| `merged` | Branch was merged via PR | Safe to delete |
| `stale` | Last commit >90 days old | Safe to delete if no open PR |
| `empty` | Zero commits ahead of default | Safe to delete |
| `active` | Recent commits, ahead of default | Keep |

**Behavior:**
- Protected branches and the default branch are never touched
- Branches with open PRs are locked until the PR is closed
- Stale branches with unmerged commits are flagged for manual review
- Closes stale PRs automatically before deleting their branches
- Writes cleanup log to `.repo-audit/cleanup-<repo>.json`

---

## consolidation-helper.mjs

Migrates a standalone micro-repo into the neunuc monorepo using git subtree merge.

**Usage:**
```bash
node scripts/consolidation-helper.mjs --source=<repo-name> [--target=apps/<name>]
```

**What it does:**
1. Verifies you are inside the neunuc monorepo
2. Creates a feature branch: `consolidate/<source>`
3. Adds the source repo as a temp remote
4. Subtree-merges the source into the target path
5. Writes `.MIGRATED.json` marker with provenance
6. Renames package to `@neunuc/<target>` if needed
7. Adds a README from template if missing
8. Commits and removes the temp remote

**Post-migration checklist:**
- Review imported files for secrets or hardcoded paths
- Update root `pnpm-workspace.yaml` if needed
- Run `pnpm check:public-stack` for validation
- Push branch, open PR, merge, then archive the original repo

---

## screenshot-demo.js

Generates PNG screenshots of all outreach surfaces using Puppeteer.

**Usage:**
```bash
cd scripts
node screenshot-demo.js
```

**What it captures:**

| Page | Output | Size |
|------|--------|------|
| `index.html` | `demo-screenshots/home.png` | 1440×900 |
| `workbench.html` | `demo-screenshots/workbench.png` | 1440×900 |
| `therapy.html` | `demo-screenshots/therapy.png` | 1440×900 |
| `research.html` | `demo-screenshots/research.png` | 1440×900 |
| `operator.html` | `demo-screenshots/operator.png` | 1440×900 |
| `system.html` | `demo-screenshots/system.png` | 1440×900 |
| `founder.html` | `demo-screenshots/founder.png` | 1440×900 |
| `pricing.html` | `demo-screenshots/pricing.png` | 1440×900 |
| `pilot.html` | `demo-screenshots/pilot.png` | 1440×900 |
| `outreach.html` | `demo-screenshots/outreach.png` | 1440×900 |

Each page produces two variants:
- **Viewport** — 1440×900 cropped
- **Full page** — complete scroll height

**Requires:** `puppeteer` installed in the repo (`npm install puppeteer` or `pnpm install`)

---

## Script safety

All scripts share the same safety model:

- **Dry-run first** — audit and cleanup both support `--dry-run`
- **Fail fast** — deploy.ps1 uses `Stop` error action
- **Log everything** — audit and cleanup write timestamped JSON logs
- **No destructive defaults** — cleanup will not delete without explicit `--dry-run` absence
- **Monorepo-aware** — consolidation-helper verifies git root before operating
