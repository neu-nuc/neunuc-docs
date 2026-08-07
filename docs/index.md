# :docs: NeuNuc Documentation

Welcome to the NeuNuc docs. This covers the local-first operating layer: how it boots, how the pieces connect, and where to look when something breaks.

---

## What lives here

NeuNuc is a **pnpm monorepo**. These are the pieces you will actually touch:

| Component | Path | What it does |
|---|---|---|
| **NeuNuc Runtime** | `apps/neunuc-runtime/` | Python inference engine with Node.js surface bridge. |
| **Ops Workspace** | `apps/neunuc-ops-workspace/` | Local operator surface at `127.0.0.1:5173`. |
| **nuc CLI** | `apps/nuc-cli/` | Internal CLI for LLM inference. Packaged as `.exe`. |
| **Dashboard** | `apps/neunuc-operator-dashboard/` | Static MVP dashboard. |
| **Outreach** | Root HTML pages | Config-driven deploy targets. |
| **Config** | `neunuc.config.json` | Single source of truth for identity, tokens, trust. |

Cloud stuff (analytics, payments, Discord) is **opt-in**. It stays off unless you flip it in `neunuc.config.json`.

---

## Boot Commands

**Ops Workspace**
```powershell
pnpm install
pnpm ops:workspace
# http://127.0.0.1:5173
```

**Runtime**
```powershell
cd apps/neunuc-runtime
pip install -r requirements.txt
python main.py
# http://127.0.0.1:8400
# UI  → http://127.0.0.1:3400/daily/
```

**nuc CLI**
```powershell
cd apps/nuc-cli
npm install
npm run build
npm install -g .
nuc "what is 2+2"
```

---

## Find what you need

| | |
|---|---|
| [Lenses](lenses.md) | Browse by Systems, Ecosystem, Apps, or Tech lens. |
| [Overview](overview.md) | Monorepo layout, trust boundary, what lives where. |
| [Getting Started](getting-started.md) | Install dependencies, verify first boot. |
| [Monorepo](monorepo.md) | Workspace definition, changesets, CI. |
| [Config System](config-system.md) | `neunuc.config.json` schema, tokens, flags. |
| [Ops Workspace](ops-workspace.md) | Operator lanes, builder registry, safety rules. |
| [nuc CLI](cli.md) | Backends, model management, REPL, packaging. |
| [Architecture](architecture.md) | Runtime internals, boot sequence, data flow. |
| [API Reference](api.md) | Runtime endpoint specs. |
| [Models](models.md) | ONNX, llama.cpp, GGUF, DirectML. |
| [Examples](examples.md) | Snippets for inference, memory, WebSocket. |
| [WebSocket](websocket.md) | Broadcast protocol, frame codec. |
| [Security](security.md) | Gate, rate limits, rules engine, CORS. |
| [Core & Observability](core.md) | Identity, health checks, logging, metrics. |
| [Deployment](deployment.md) | Cloudflare, Netlify, Docker, `.exe`. |
| [Troubleshooting](troubleshooting.md) | Diagnostic steps, known issues. |
| [FAQ](faq.md) | Common internal questions. |
| [Glossary](glossary.md) | Terms we use inside this repo. |
