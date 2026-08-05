# Site Map
Every page in this manual, organized by section, with lens tags and one-line purpose.

---

## Explainer

This is the master index. If you know what you are looking for but not where it lives, start here. Each entry shows the page name, its primary lens, and a single-line description of what you will find.

---

## Home

| Page | Lens | Purpose |
|------|------|---------|
| [Home](index.md) | — | Landing, boot commands, component grid |
| [Lenses](lenses.md) | — | Lens overview, page matrix, how to browse |
| [Site Map](sitemap.md) | All | This page — master index of every doc |

---

## Systems

| Page | Lens | Purpose |
|------|------|---------|
| [Overview](overview.md) | :systems: | Monorepo layout, trust boundary, file map |
| [Getting Started](getting-started.md) | :systems: | Install, first boot, verify |
| [Architecture](architecture.md) | :systems: | Runtime internals, boot sequence, data flow |
| [Deployment](deployment.md) | :systems: | Cloudflare, Netlify, Docker, `.exe` |
| [Outreach Surfaces](outreach.md) | :systems: :apps: | Public HTML pages, their purpose and config |
| [Security & Policy](security.md) | :systems: | Gate, rate limits, rules engine, CORS |
| [Core & Observability](core.md) | :systems: | Identity, health checks, logging, metrics |
| [Control Stack](control-stack.md) | :systems: | Decision gates, override surface, audit |
| [Infrastructure](infra.md) | :systems: | Terraform, Cloudflare, DNS, secrets |
| [CI/CD](ci-cd.md) | :systems: | GitHub Actions, staging gates, rollback |
| [Scripts & Automation](scripts.md) | :systems: | `pnpm` scripts, audit, build, verify |

---

## Ecosystem

| Page | Lens | Purpose |
|------|------|---------|
| [Monorepo](monorepo.md) | :ecosystem: | Workspace definition, changesets, CI |
| [Config System](config-system.md) | :ecosystem: :tech: | `neunuc.config.json` schema, resolver, overrides |
| [Metasystem](metasystem.md) | :ecosystem: | Meta rules, versioning, inter-op |
| [Public Release](public-release.md) | :ecosystem: | Release checklist, versioning, comms |

---

## Apps

| Page | Lens | Purpose |
|------|------|---------|
| [Ops Workspace](ops-workspace.md) | :apps: | Operator lanes, builder registry, safety rules |
| [nuc CLI](cli.md) | :apps: :tech: | Backends, model management, REPL, packaging |
| [Runtime](runtime.md) | :apps: :tech: | Inference engine, ONNX, model loading |
| [Operator Dashboard](operator-dashboard.md) | :apps: | Static MVP dashboard |
| [NucBot](nucbot.md) | :apps: | Bot behavior, commands, message flow |
| [Customer VC](customer-vc.md) | :apps: | Vertical context builder, value props |
| [Customer VC Pilot](customer-vc-pilot.md) | :apps: | Pilot recruitment, onboarding, feedback |
| [Discord Bot Runtime](discord-bot.md) | :apps: | Discord.js adapter, slash commands, gateway |
| [API Reference](api.md) | :apps: :tech: | Runtime endpoint specs |
| [Models](models.md) | :apps: :tech: | ONNX, llama.cpp, GGUF, DirectML |
| [WebSocket & Real-time](websocket.md) | :apps: :tech: | Broadcast protocol, frame codec |
| [Examples](examples.md) | :apps: :tech: | Snippets for inference, memory, WebSocket |

---

## Tech

| Page | Lens | Purpose |
|------|------|---------|
| [Configuration](configuration.md) | :tech: | `.env`, `config.mjs`, environment overrides |
| [Usage](usage.md) | :tech: | Boot modes, CLI options, flags, logs |
| [Templates & Builders](templates.md) | :ecosystem: :tech: | Sovereign stack builder, scaffolding |
| [Stripe Checkout Worker](stripe-checkout.md) | :tech: | Cloudflare Worker for Stripe Checkout |
| [Troubleshooting](troubleshooting.md) | :systems: :apps: :tech: | Diagnostic steps, known issues |
| [FAQ](faq.md) | :systems: :apps: :tech: | Common internal questions |
| [Glossary](glossary.md) | :systems: :apps: :tech: | Terms we use inside this repo |
| [Changelog](changelog.md) | :systems: :ecosystem: :apps: :tech: | Version history, breaking changes, fixes |

---

## Quick lookup

### By task

| I want to... | Go to |
|--------------|-------|
| Boot the workspace | [Getting Started](getting-started.md) |
| Deploy a site | [Deployment](deployment.md) |
| Fix a boot failure | [Troubleshooting](troubleshooting.md) |
| Understand the runtime | [Architecture](architecture.md) |
| Add a model | [Models](models.md) |
| Configure something | [Config System](config-system.md) |
| Use the CLI | [nuc CLI](cli.md) |
| Build a new vertical | [Templates & Builders](templates.md) |
| Check what changed | [Changelog](changelog.md) |
| Find a term | [Glossary](glossary.md) |
| Ask a question | [FAQ](faq.md) |

---

## Lens filter

Click a lens to see only pages tagged with it:

- [:systems: Systems](lenses.md#systems-lens)
- [:ecosystem: Ecosystem](lenses.md#ecosystem-lens)
- [:apps: Apps](lenses.md#apps-lens)
- [:tech: Tech](lenses.md#tech-lens)
