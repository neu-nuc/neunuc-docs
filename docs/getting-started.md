# Getting Started
Install the monorepo and verify each component boots cleanly.

Prerequisites, install, boot verification for each component. Follow in order.

---

## Prerequisites

- [ ] **pnpm** 9.15.4+
- [ ] **Node.js** 20+
- [ ] **Python** 3.10+ with pip
- [ ] **Windows** (DirectML and `.exe` packaging are Windows-only)
- [ ] **Git**

---

## Step 1: Install monorepo dependencies

`pnpm install` installs all workspace packages and dev tooling from the root. Run from repo root. ~2 minutes.

```powershell title="Terminal"
cd C:\Users\mysti\neunuc
pnpm install
```

---

## Step 2: Install Python runtime dependencies

The runtime core is Python. Install its dependencies separately via pip.

```powershell title="Terminal"
cd apps/neunuc-runtime
pip install -r requirements.txt
```

---

## Step 3: Verify workspace integrity

Boundary checks prevent cross-package leaks. CI runs the full pipeline before anything merges.

```powershell title="Terminal"
pnpm check:boundaries
pnpm ci
```

---

## Step 4: Boot the Runtime

The Python inference engine boots in 5 phases. It automatically starts the Node.js surface bridge as a subprocess (unless `--no-node`).

**Path:** `apps/neunuc-runtime/`  
**API Port:** `8400` (FastAPI)  
**Surface Port:** `3400` (Node.js bridge)  
**Entry:** `main.py`

```powershell title="Terminal"
cd apps/neunuc-runtime
python main.py --mode=local --api-port=8400
# API  → http://127.0.0.1:8400
# UI   → http://127.0.0.1:3400/daily/
```

Expected boot log:

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  NeuNuc v0.5 — booting
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[1/5] Boot — hardware probe, dirs, env
[2/5] Core — identity, health, store, rules
[3/5] Orchestrate — register handlers, build pipeline
[4/5] Workloads — loading inference model (background)
[5/5] Surfaces — starting FastAPI + Node.js bridge
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Boot complete in 850ms
  API  → http://127.0.0.1:8400
  UI   → http://127.0.0.1:3400/daily/
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Verify:

```powershell title="Health check"
python main.py --health
# or
curl http://127.0.0.1:8400/health
```

Expected response:

```json
{
  "status": "ok",
  "id": "neunuc-alpha",
  "version": "0.5.0",
  "checks": [
    {"name": "store", "ok": true},
    {"name": "inference", "ok": true}
  ]
}
```

---

## Step 5: Boot the Ops Workspace

The operator surface runs locally at `127.0.0.1:5173`. It never binds to external interfaces by default.

```powershell title="Terminal"
pnpm ops:workspace
```

Expected output:

```text
> neunuc-ops-workspace@0.1.0 dev
> vite --host 127.0.0.1
VITE v5.x  ready in xxx ms
> Local:   http://127.0.0.1:5173/
> Network: use --host to expose
```

Open http://127.0.0.1:5173 to verify.

---

## Step 6: Install the nuc CLI

The CLI is a Node.js tool that talks to local and remote LLM backends.

**Path:** `apps/nuc-cli/`  
**Output:** Single Windows `.exe`  
**Backends:** Ollama, llama.cpp, ONNX, OpenAI, Moonshot, Perplexity, Azure Foundry

```powershell title="Terminal"
cd apps/nuc-cli
npm install
npm run build
npm install -g .
```

Verify:

```powershell title="Terminal"
nuc --version
nuc "what is the capital of France"
```

---

## Next steps

- [Monorepo](monorepo.md) — workspace structure and scripts.
- [Config System](config-system.md) — edit `neunuc.config.json` before enabling integrations.
- [Architecture](architecture.md) — component relationships.
