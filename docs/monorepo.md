# Monorepo
Structure

NeuNuc is a pnpm workspace monorepo. This page documents workspace boundaries, package layout, release management, and maintenance scripts.

## Workspace definition

`pnpm-workspace.yaml`:

```yaml
packages:
  - 'apps/*'
  - 'packages/*'
  - 'tools/*'
```

All packages under `apps/`, `packages/`, and `tools/` are managed as workspace members.

## Package inventory

### Applications (`apps/`)

| Package | Runtime | Purpose |
|---------|---------|---------|
| `neunuc-runtime` | Python 3.10+ / Node.js 20+ | Python FastAPI inference core with Node.js surface bridge. ONNX, state/memory, HTTP/WS |
| `neunuc-ops-workspace` | Node.js 20 | Local operator surface (`127.0.0.1:5173`). Builder registry, domain validation, Discord bot drafting, lead routing |
| `neunuc-operator-dashboard` | Static | Deploy-ready static MVP dashboard |
| `neunuc-public-release` | Static / Node.js | Release artifacts and distribution packaging |
| `nuc-cli` | Node.js 20 | Internal CLI for LLM inference across 7 backends. Packaged as single Windows `.exe` |
| `control-stack` | Node.js 20 | Control layer for coordination and orchestration |
| `customer-vc` | Node.js 20 | Customer-facing VC tools |
| `customer-vc-pilot` | Node.js 20 | Customer VC pilot environment |
| `nuc-metasystem` | Node.js 20 | Metasystem layer |
| `nucbot` | Node.js 20 | Bot runtime and automation |

### Supporting directories

| Directory | Contents |
|-----------|----------|
| `config/` | Config schemas, default values, and validation |
| `infra/` | Infrastructure definitions (Terraform, Bicep, or static deploy configs) |
| `scripts/` | Repo audit, branch cleanup, consolidation utilities |
| `tools/` | Boundary check scripts, build helpers, codegen |
| `templates/` | Builder templates referenced by ops workspace |
| `models/` | ONNX model files and manifests |
| `docs/` | This documentation |

## Root-level files

| File | Purpose |
|------|---------|
| `package.json` | Monorepo root: scripts, devDeps, changeset config |
| `pnpm-workspace.yaml` | Workspace glob patterns |
| `neunuc.config.json` | Org config, design tokens, deployment targets, integrations |
| `package-boundaries.json` | Layered dependency rules and allowed imports |
| `*.html` | Outreach surfaces (founder, system, outreach, pricing, therapy, research, operator, pilot, waitlist, workbench) |
| `sw.js` | Service worker for offline caching |
| `manifest.json` | PWA manifest |
| `_headers` | Cloudflare Pages custom headers |
| `netlify.toml` | Netlify deploy config |
| `wrangler.toml` | Cloudflare Workers deploy config |

## Scripts

Defined in root `package.json`:

| Script | Command | Purpose |
|--------|---------|---------|
| `ops:workspace` | `pnpm --filter neunuc-ops-workspace dev` | Start operator workspace |
| `check:boundaries` | `node tools/check-boundaries.js` | Validate cross-package imports |
| `repo:audit` | `node scripts/repo-audit.js` | Audit repo state, deps, drift |
| `repo:branch-cleanup` | `node scripts/branch-cleanup.js` | Clean stale branches |
| `repo:consolidate` | `node scripts/consolidate.js` | Consolidate and normalize structure |
| `ci` | `lint && typecheck && test && build && check:boundaries` | Full CI pipeline |

## Changesets

Version management via `@changesets/cli`.

```powershell
# Add a changeset
pnpm changeset

# Version packages
pnpm changeset version

# Publish
pnpm changeset publish
```

## Layered architecture

`package-boundaries.json` defines 8 layers and their import rules:

| Layer | Can import from |
|-------|-----------------|
| `foundation` | `foundation` |
| `engine` | `foundation`, `engine` |
| `sdk` | `foundation`, `engine`, `sdk` |
| `ui` | `foundation`, `sdk`, `ui` |
| `adapters` | `foundation`, `sdk`, `adapters` |
| `domain` | `foundation`, `engine`, `sdk`, `domain` |
| `apps` | `foundation`, `engine`, `sdk`, `ui`, `adapters`, `domain`, `apps` |
| `docs` | `foundation`, `sdk`, `docs` |

Each package declares its layer in `package.json` under `neunuc.layer`. The boundary checker validates that no package imports from a layer it is not allowed to depend on.

**Blocked patterns:**
- `apps/* -> apps/*` (no cross-app imports)
- `packages/public-* -> packages/private-*` (no public-to-private leakage)

## Boundary checks

`pnpm check:boundaries` enforces that:

- `apps/` packages may not import from sibling `apps/` unless explicitly declared in `package.json` dependencies.
- `packages/` are the only shared code allowed cross-app.
- `tools/` are build-time only and may not appear in runtime bundles.
- Layer rules from `package-boundaries.json` are respected.

Violations fail CI.

## CI pipeline

```
lint → typecheck → test → build → check:boundaries
```

All steps must pass before merge. The pipeline is defined in `.github/workflows/ci.yml`.
