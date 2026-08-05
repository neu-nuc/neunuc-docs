# Lens Versioning

Four ways to read the same system. Pick the lens that matches what you are trying to do.

---

## :systems: Systems Lens

**How do the pieces connect? What depends on what?**

Shows the system as connected components — runtime, bridge, workspace, CLI. Emphasizes data flow, boot order, and trust boundaries.

Use this when you are onboarding, debugging cross-component failures, or need the boot sequence.

**Tagged pages:** [Overview](overview.md) · [Architecture](architecture.md) · [Security](security.md) · [Core](core.md) · [Getting Started](getting-started.md) · [Deployment](deployment.md) · [Outreach](outreach.md) · [Control Stack](control-stack.md) · [Infrastructure](infra.md) · [CI/CD](ci-cd.md) · [Scripts](scripts.md)

---

## :ecosystem: Ecosystem Lens

**What lives in the monorepo? How do packages relate?**

Shows workspaces, packages, scripts, changesets, boundary checks, CI, and shared config. Emphasizes structural health and release hygiene.

Use this when you are adding a package, debugging imports, cutting a release, or reviewing config.

**Tagged pages:** [Monorepo](monorepo.md) · [Config System](config-system.md) · [Metasystem](metasystem.md) · [Public Release](public-release.md) · [Templates](templates.md)

---

## :apps: Apps Lens

**What does each app do? How do I boot it?**

Zooms into individual applications — runtime, workspace, CLI, dashboard. Each app has its own boot path, ports, and verification steps.

Use this when you are working on one app and do not care about the rest.

**Tagged pages:** [Ops Workspace](ops-workspace.md) · [nuc CLI](cli.md) · [Runtime](runtime.md) · [Dashboard](operator-dashboard.md) · [NucBot](nucbot.md) · [Customer VC](customer-vc.md) · [Customer VC Pilot](customer-vc-pilot.md) · [Discord Bot](discord-bot.md) · [API](api.md) · [Models](models.md) · [WebSocket](websocket.md) · [Examples](examples.md)

---

## :tech: Tech Lens

**What technologies are used? What are the APIs? What is the schema?**

Deep technical reference — protocols, schemas, endpoints, model formats, inference parameters, deployment configs. Assumes you know which component you are touching.

Use this when you are writing code against an API, configuring a model, or need exact schema details.

**Tagged pages:** [API](api.md) · [Models](models.md) · [WebSocket](websocket.md) · [Config System](config-system.md) · [Security](security.md) · [Core](core.md) · [Runtime](runtime.md) · [Metasystem](metasystem.md) · [NucBot](nucbot.md) · [Dashboard](operator-dashboard.md) · [Control Stack](control-stack.md) · [Customer VC](customer-vc.md) · [Templates](templates.md) · [Stripe Checkout](stripe-checkout.md) · [Infrastructure](infra.md) · [CI/CD](ci-cd.md) · [Scripts](scripts.md)

---

## Lens matrix

| Page | Systems | Ecosystem | Apps | Tech |
|---|---|---|---|---|
| Overview | :check: | :check: | | |
| Getting Started | :check: | | | |
| Monorepo | | :check: | | |
| Config System | | :check: | | :check: |
| Architecture | :check: | | | |
| Control Stack | :check: | | | :check: |
| Infrastructure | :check: | | | :check: |
| CI/CD | :check: | | | :check: |
| Scripts & Automation | :check: | :check: | | |
| Ops Workspace | | | :check: | |
| nuc CLI | | | :check: | |
| Runtime | | | :check: | :check: |
| Metasystem | | :check: | | :check: |
| NucBot | | | :check: | :check: |
| Operator Dashboard | | | :check: | :check: |
| Customer VC | | | :check: | :check: |
| Customer VC Pilot | | | :check: | :check: |
| Discord Bot Runtime | | | :check: | |
| Public Release | | :check: | | |
| Templates & Builders | | :check: | | :check: |
| Stripe Checkout Worker | | | | :check: |
| API Reference | | | :check: | :check: |
| Models | | | :check: | :check: |
| WebSocket | | | :check: | :check: |
| Examples | | | :check: | :check: |
| Security | :check: | | | :check: |
| Core | :check: | | | :check: |
| Deployment | :check: | | | |
| Outreach Surfaces | :check: | | :check: | |
| Site Map | :check: | :check: | :check: | :check: |
| Troubleshooting | :check: | | :check: | :check: |
| FAQ | :check: | :check: | :check: | :check: |
| Glossary | | | | :check: |

---

## Reading tagged pages

A lens badge at the top of a section tells you which perspective it is written from. No badge means general — readable from any lens.

If a page feels too high-level, switch to the **Tech** lens.  
If it feels too detailed, switch to the **Systems** lens.  
If you want boot commands, switch to the **Apps** lens.
