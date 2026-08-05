# Changelog
All notable changes to the NeuNuc documentation.

## 2.1.0 — 2026-08-04

### Added
- **Outreach Surfaces** — Dedicated page documenting all root-level HTML pages, their purpose, redirects, and security headers
- **Site Map** — Master index of all 37+ pages with lens tags, one-line descriptions, and quick lookup by task
- **Build strict mode** — `build.ps1` now runs `mkdocs build --strict` for zero-warning builds

### Updated
- **Deployment** — Added verified pages table: founder.html, outreach.html, workbench-repos/gaps/memory/files.html
- **Lenses** — Added Outreach Surfaces and Site Map to page lists and matrix
- **Navigation** — Added Outreach Surfaces and Site Map to top-level nav

## 2.0.0 — 2026-08-04

### Added
- **Lens versioning** — Four lenses (Systems, Ecosystem, Apps, Tech) with badge system and matrix table
- **Custom geometric icons** — 26+ minimal SVG icons, no emojis, inline `:icon-name:` syntax via custom Markdown extension
- **Architecture diagrams** — Tabbed Mermaid diagrams per lens with "You are here" indicator
- **App-specific docs** — Dedicated pages for every app: Runtime, Metasystem, NucBot, Operator Dashboard, Control Stack, Customer VC, Customer VC Pilot, Public Release, nuc CLI
- **Adapter docs** — Discord Bot Runtime and Stripe Checkout Worker
- **System docs** — Infrastructure, CI/CD, Scripts & Automation, Config System, Monorepo
- **Neurodivergent-friendly styling** — Calmed palette, increased whitespace, consistent 3-part nesting (Explainer/System/Code)

### Fixed
- **Architecture rewrite** — Corrected runtime docs to reflect the actual hybrid stack: Python FastAPI core (`runtime/`, `gateway/`, `inference/`, `observe/`) with Node.js surface bridge (`surface/server.js`)
- **Overview accuracy** — Updated runtime description to "Python inference engine with Node.js surface bridge", corrected boot commands to `python main.py`
- **Glossary accuracy** — Updated all runtime file references from incorrect `.mjs` paths to actual `.py` paths (`runtime/core.py`, `gateway/gate.py`, `runtime/surface.py`, etc.)
- **Troubleshooting accuracy** — Replaced incorrect `pnpm runtime:dev` commands with `python main.py` and added Python-specific debugging steps
- **Usage accuracy** — Replaced incorrect Node.js lifecycle with actual Python boot sequence (`main.py` → `runtime/boot.py` → `uvicorn`)
- **Security accuracy** — Documented actual FastAPI CORS middleware in `runtime/surface.py`
- **Deployment accuracy** — Replaced incorrect Node.js Dockerfile with Python-based Dockerfile including Node.js for surface bridge
- **Models accuracy** — Documented actual Python model loading via `inference/run.py`

## 1.1.0 — 2025-08-04

### Added
- **API Reference** — Complete endpoint documentation with request/response schemas and curl examples
- **Configuration** — Environment variables guide with `.env` examples and precedence rules
- **Troubleshooting** — Common issues: boot failures, inference errors, memory persistence, WebSocket problems
- **Examples** — Working code snippets for health checks, inference, streaming, memory, WebSocket, and custom pipeline steps
- **Architecture** — Detailed module breakdown with Mermaid diagrams, data flow sequences, and file layout

### Updated
- **Getting Started** — Added boot sequence explanation, verified pages table, and next steps
- **Usage** — Added lifecycle diagram, log output examples, and graceful shutdown notes
- **Models** — Added inference engine details, device options, loading API, performance tips
- **Deployment** — Added redirect rules, security headers, Docker example, and deployment checklist
- **Overview** — Added technology stack table, quick facts, and component descriptions

## 1.0.0 — 2025-08-03

### Added
- MkDocs Material documentation site with search, dark/light mode, and responsive layout
- Landing page with quick-start card grid
- Documentation sections for Overview, Getting Started, Usage, Deployment, Architecture, and Models
- Cloudflare Pages deploy instructions
