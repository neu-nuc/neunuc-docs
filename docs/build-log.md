# Build Log: NeuNuc Docs Site

Chronological record of how the NeuNuc Internal Operating Manual was built. Captures decisions, pivots, and technical milestones for reference.

---

## Phase 0: Initial Request (2026-08-03)

**User ask:** "go through and create neunuc native docs"

**First attempt:** Generated basic Markdown docs from `C:\Users\mysti\neunuc` README and source files. Created 7 pages: index, overview, getting-started, usage, deployment, architecture, models.

**User reaction:** "so utilize this shit and styling for this" — referenced design system from `NeuNuc_Meat` project.

---

## Phase 1: Design System Pivot (2026-08-04)

**Attempt 1:** Built custom HTML docs site using NeuNuc Meat design system (dark green accent, dark panels).

**User rejection:** "no no no i want the mkdocs style not the neunuc meat shit"

**Decision:** Switch to MkDocs Material, pure Markdown, no custom HTML. This became the foundational constraint for everything that followed.

---

## Phase 2: MkDocs Foundation (2026-08-04)

- Found existing MkDocs setup at `C:\Users\mysti\Desktop\neunuc-docs`
- Fixed config (removed problematic `mkdocs-monorepo-plugin` that wasn't installed)
- Built successfully with Material theme
- Served locally for preview

---

## Phase 3: Expansion & Iteration (2026-08-04)

**User prompts:** "keep going" / "keep going" / "do better"

**Actions taken:**
- Expanded from 7 pages to 38 pages
- Added lens versioning concept (Systems, Ecosystem, Apps, Tech)
- Built toggle-able architecture Mermaid diagrams that correlate where someone is at within the system
- Created `sitemap.md` for cognitive navigation

---

## Phase 4: Proprietary Voice (2026-08-04)

**User prompt:** "people aren't using it — this is for me and the outward language should be reflective of proprietary"

**Rewrite scope:**
- Site title: "NeuNuc Internal Operating Manual"
- Tagline: "Proprietary system documentation. Not for public distribution."
- No generic "Quick Start" for external users
- Language framed as internal system docs with "Boot Commands" and "Sections"
- Added `noindex, nofollow` meta tags
- Added `robots.txt` blocking all crawlers
- Rewrote 13+ pages for internal voice

---

## Phase 5: Neurodivergent Accessibility (2026-08-04)

**User prompt:** "more neuro div friendly"

**Changes:**
- Flattened information hierarchy (clear nesting: systems → explainers → code)
- Reduced cognitive load per page
- Tables for structured data instead of dense paragraphs
- Consistent heading patterns
- Removed decorative noise

---

## Phase 6: Sleek Monochrome Overhaul (2026-08-04)

**User prompts:** "SLEEKER" / "no color - just simplistic or minimalistic with an accent color maybe" / "none of that animated emoji shit"

**Changes:**
- Complete CSS rewrite: monochrome base (`#1a1a1a` text, `#f7f8f9` surface)
- Single accent: `#4a7a9e` (steel blue)
- Removed all emojis (replaced with `| text |` markers)
- Removed all admonitions (flattened 47 to 0)
- Removed custom HTML divs
- Purged unused CSS classes
- Cards, tables, tabs have no borders
- Typography tightened: Inter + JetBrains Mono

---

## Phase 7: Geometric Icon System (2026-08-04)

**User prompt:** "do a minimal outlined modern geometric no emojis style icons" / "all of the shit for the : :" / "AND NOT IN THE ACTUAL CODE"

**Solution:**
- Created `neunuc_icons.py` — custom MkDocs Markdown extension
- Syntax: `:icon-name:` renders inline SVG
- Built 26+ custom SVG icons in `docs/overrides/.icons/`
- Icons: sun, moon, search, code, table, check, xmark, bolt, brain, server, cube, gear, terminal, link, book, compass, star, circle-info, triangle-exclamation, circle-check, circle-xmark, square-plus, square-minus, arrows-rotate, diagram-project, users, box
- All icons: 24x24 viewBox, stroke-only, no fill, monochrome
- Requires `PYTHONPATH` set to project root for MkDocs to import extension

---

## Phase 8: Hybrid Stack Discovery (2026-08-04)

**Critical discovery:** `apps/neunuc-runtime/` contains hybrid Python + Node.js stack
- `main.py` + `runtime/` = Python FastAPI core (port 8400)
- `surface/server.js` = Node.js bridge (port 3400)

**Impact:** Previous docs had incorrectly removed all Python references. Required rewriting:
- `architecture.md` — added dual-port diagram, Python boot commands
- `runtime.md` — full hybrid stack documentation
- `getting-started.md` — updated boot sequence
- 13 other files — corrected language about "Node.js runtime" to "hybrid runtime"

**Decision:** Document the truth. Do not sanitize. The docs are internal and proprietary.

---

## Phase 9: Real Site Deployment (2026-08-04)

**User prompt:** "we can do 100x better and make it a real site"

**Infrastructure built:**
- `Dockerfile` — nginx:alpine serving built `site/`
- `docker-compose.yml` — local orchestration
- `infra/docs-host/nginx/docs.conf` — nginx config with basic auth
- `infra/docs-host/.htpasswd` — default basic auth credentials
- `infra/docs-host/scripts/deploy-local.ps1` — one-command build + deploy
- `infra/docs-host/scripts/generate-auth.ps1` — htpasswd generator
- `.github/workflows/docs.yml` — GitHub Actions CI/CD
- `docs/robots.txt` — block all crawlers
- `docs/CNAME` — `docs.neunuc.com`
- `docs/404.md` — branded 404 page
- `mkdocs.yml` — updated `site_url`, `repo_url`, `extra.generator: false`

**Repo setup:**
- Initialized git repo in `C:\Users\mysti\Desktop\neunuc-docs`
- Committed 102 files
- Pushed to `github.com/neu-nuc/neunuc-docs`

**GitHub Actions status:** Build succeeds. Deploy blocked because `neu-nuc` org has Pages disabled at org level. User must enable in repo settings.

---

## Phase 10: Box Fulfillment Integration (2026-08-05)

**User context:** Tagged `neunuc-box-fulfillment` monorepo for integration.

**Content audited:**
- `CONSOLIDATED_STRATEGY.md` — 80/20 Box approach, unit economics
- `NEUNUC_SYSTEM_ARCHITECTURE.md` — 3-layer cognitive architecture
- `NEUNUC_SOFTWARE_ARCHITECTURE.md` — pnpm workspace, Mermaid diagrams
- `DEPLOYMENT_MANIFEST.md` — live endpoints, D1 schema, pricing
- `DEPLOY_GUIDE.md` — step-by-step deploy instructions
- `STRIPE_SETUP.md` — Payment Links, shipping, webhooks
- `sop-pack-station.md` — physical pack station procedure
- `docs/BOX_BUILDER.md` — print asset generation system

**New pages created (7):**

| Page | Source | Contents |
|------|--------|----------|
| `box-strategy.md` | `CONSOLIDATED_STRATEGY.md` | 80/20 Box, hero SKUs, unit economics, revenue model |
| `box-system-architecture.md` | `NEUNUC_SYSTEM_ARCHITECTURE.md` | 3-layer architecture with Mermaid diagrams |
| `box-software-architecture.md` | `NEUNUC_SOFTWARE_ARCHITECTURE.md` | Monorepo structure, tiers, data flows, agents |
| `box-deployment.md` | `DEPLOYMENT_MANIFEST.md` + `DEPLOY_GUIDE.md` | Endpoints, schema, deploy steps, health checks |
| `box-stripe-setup.md` | `STRIPE_SETUP.md` | Payment Links, shipping config, test purchase flow |
| `box-pack-station.md` | `sop-pack-station.md` | Station layout, bin map, SOP, quality gates |
| `box-builder.md` | `docs/BOX_BUILDER.md` | Print assets, label specs, registry |

**Nav updated:** `mkdocs.yml` — added "Box Fulfillment" section between Apps and Tech.

**Icon added:** `:box:` geometric SVG.

**Verification:** `mkdocs build --strict` passes. Committed and pushed.

---

## Key Technical Decisions

| Decision | Rationale | Date |
|----------|-----------|------|
| MkDocs Material over custom HTML | User explicitly rejected HTML; wanted Markdown-native | 2026-08-04 |
| Monochrome + single accent | User demanded "sleeker" and "no animated emoji shit" | 2026-08-04 |
| Custom `:icon-name:` extension | User wanted geometric icons "NOT IN THE ACTUAL CODE" | 2026-08-04 |
| `PYTHONPATH` required for builds | MkDocs must find `neunuc_icons.py` at project root | 2026-08-04 |
| No admonitions anywhere | User rejected visual noise; flattened all 47 | 2026-08-04 |
| Hybrid stack documented truthfully | Discovered Python + Node.js; corrected all docs | 2026-08-04 |
| GitHub Pages CI/CD | User wanted "real site"; zero-cost hosting | 2026-08-04 |
| Basic auth on nginx container | Proprietary docs need access control | 2026-08-04 |
| Separate repo (`neunuc-docs`) | Docs outside main monorepo; independent lifecycle | 2026-08-04 |
| Box fulfillment as separate section | Product has its own stack and deployment model | 2026-08-05 |

## File Inventory

**Docs pages:** 45 Markdown files (38 original + 7 box fulfillment)

**Icons:** 27 custom SVGs in `docs/overrides/.icons/`

**Styles:** `docs/stylesheets/extra.css` (complete monochrome stylesheet)

**Extensions:** `neunuc_icons.py` (custom Markdown extension)

**Infrastructure:** Dockerfile, docker-compose.yml, nginx config, deploy scripts, GitHub Actions workflow

**Config:** `mkdocs.yml` (Material theme, custom extension, 45-page nav)

## Current State (2026-08-05)

- **Repo:** `github.com/neu-nuc/neunuc-docs`
- **Branch:** `main`
- **Commits:** 3 (initial + hybrid fix + box fulfillment)
- **Build:** Passes `mkdocs build --strict`
- **Deploy:** GitHub Actions builds; deploy blocked by org-level Pages disablement
- **Local serve:** `mkdocs serve` at `http://127.0.0.1:8000`
- **Docker:** `docker-compose up` serves nginx with basic auth at `http://localhost:8080`

## Known Blockers

| Blocker | Status | Resolution |
|---------|--------|------------|
| GitHub Pages disabled at org level | Blocked | User must enable in `neu-nuc/neunuc-docs` repo settings |
| Custom domain (`docs.neunuc.com`) | Configured but not live | Requires Pages enabled + DNS CNAME |

## Next Possible Work (If User Requests)

- Enable GitHub Pages + verify deploy
- Add versioning with mike plugin
- Add search indexing for offline use
- Expand box fulfillment with seasonal SKU guides
- Add operator training checklist
- Build PDF export pipeline
- Add analytics / access logging to nginx config
