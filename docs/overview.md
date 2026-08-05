# Overview
NeuNuc is our local-first operating layer. It lives as a **pnpm monorepo** with multiple apps under `apps/`.


---

## Repository layout

```text
neunuc/
├── apps/
│   ├── neunuc-runtime/          # Python ONNX runtime + Node bridge
│   ├── neunuc-ops-workspace/    # Local operator workspace
│   ├── neunuc-operator-dashboard/ # Static dashboard MVP
│   ├── neunuc-public-release/   # Release artifacts
│   ├── nuc-cli/                 # Local LLM CLI
│   ├── nuc-metasystem/          # Metasystem
│   ├── control-stack/           # Control layer
│   ├── customer-vc/             # Customer VC tools
│   ├── customer-vc-pilot/       # Customer VC pilot
│   └── nucbot/                  # Bot runtime
├── config/                      # Config schemas and defaults
├── infra/                       # Infrastructure definitions
├── scripts/                     # Repo audit, branch cleanup
├── tools/                       # Boundary checks, build helpers
├── templates/                   # Builder templates
├── models/                      # ONNX model files
├── docs/                        # This documentation
├── *.html                       # Outreach surfaces (root)
├── neunuc.config.json           # Org config, tokens, trust
├── package.json                 # pnpm monorepo root
└── pnpm-workspace.yaml          # Workspace definition
```

---

## Components

Each component below follows the same pattern:

- **Explainer** — what it is
- **System** — where it lives
- **Code** — how to boot it

### NeuNuc Runtime

Python inference engine with Node.js surface bridge. Runs ONNX models via FastAPI, stores state in flat JSON, and exposes HTTP/WebSocket endpoints. The Python core handles inference, memory, state, and orchestration. The Node.js bridge serves HTML surfaces and proxies API calls.

- **Path**: `apps/neunuc-runtime/`
- **Stack**: Python 3.10+ (FastAPI + uvicorn), Node.js 18+ (surface bridge), ONNX Runtime
- **Ports**: `8400` (FastAPI API), `3400` (Node.js surface)
- **Entry**: `main.py`

```powershell title="Boot the runtime"
cd apps/neunuc-runtime
pip install -r requirements.txt
python main.py --mode=local --api-port=8400
# http://127.0.0.1:3400/daily/
# API → http://127.0.0.1:8400
```

### Ops Workspace

Local-only operator surface. Site builders, domain validation, Discord bot drafting, lead routing. Runs in the browser at `127.0.0.1:5173`. Nothing here is exposed to the internet by default.

- **Path**: `apps/neunuc-ops-workspace/`
- **Stack**: Vite, vanilla JS/HTML
- **Port**: `5173` (localhost only)

```powershell title="Boot the workspace"
pnpm ops:workspace
# http://127.0.0.1:5173
```

### nuc CLI

Internal CLI for LLM inference. Talks to local backends (Ollama, llama.cpp, ONNX) and remote APIs (OpenAI, Moonshot, Perplexity, Azure Foundry). Packaged as a single Windows `.exe`.

- **Path**: `apps/nuc-cli/`
- **Stack**: Node.js, TypeScript
- **Install**: `npm install -g .` after build

```powershell title="Install and run"
cd apps/nuc-cli
npm install
npm run build
npm install -g .
nuc "what is 2+2"
```

### Operator Dashboard

Static MVP dashboard. Deploy-ready as a static site.

- **Path**: `apps/neunuc-operator-dashboard/`
- **Stack**: Static HTML
- **Deploy**: Cloudflare Pages, Netlify, or any static host

### Outreach Surfaces

Root-level HTML pages that deploy as static sites. Configured via `neunuc.config.json`.

- **Path**: Root `*.html` files
- **Deploy target**: Cloudflare Pages (default)
- **Config**: `neunuc.config.json → deployment`

```powershell title="Deploy to Cloudflare"
cd C:\Users\mysti\neunuc
npx wrangler pages deploy . --project-name=neunuc --branch=main
```

### Config System

`neunuc.config.json` is the single source of truth. It holds org identity, design tokens, deployment targets, trust boundaries, and integration flags.

- **Path**: Root `neunuc.config.json`
- **Schema**: `config/` directory
- **Scope**: All apps read from it

---

## Monorepo conventions

- **Package manager:** pnpm 9.15.4. Do not use npm or yarn.
- **Changesets:** `@changesets/cli` handles versioned releases. Run `pnpm changeset` before merging anything that bumps a version.
- **Boundary checks:** `pnpm check:boundaries` validates that no package imports outside its declared scope. Run this before pushing.
- **CI script:** `pnpm ci` runs the full pipeline: lint → typecheck → test → build → boundaries.

---

## Trust boundary

Everything is **opt-in and disabled by default**.

- No sensitive user data is collected, stored, or transmitted.
- The ops workspace binds to `127.0.0.1` only.
- Lead capture, analytics, Turnstile, payments, and Discord are all gated by `neunuc.config.json → trustBoundary`.

See `neunuc.config.json → trustBoundary` for the explicit declaration.

---

## Next steps

- [Getting Started](getting-started.md) — install and boot each component.
- [Monorepo](monorepo.md) — workspace structure and CI.
- [Architecture](architecture.md) — how components connect.
- [Config System](config-system.md) — `neunuc.config.json` reference.
