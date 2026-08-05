# Ops Workspace
The operator workspace (`apps/neunuc-ops-workspace/`) is a local-only surface bound to `127.0.0.1:5173`. It is the primary interface for drafting sites, validating domains, building Discord bots, and managing public surfaces before they are deployed.

## Architecture

The workspace is a Vite-based single-page application. It does not expose itself to the network by design. All data stays local unless explicitly exported via the builder pipeline.

## Operator lanes

The workspace is organized into five lanes. Each lane is isolated and operates only within the workspace unless the operator triggers a builder export.

### 1. Site Builders

Draft static outreach sites from templates. Templates are defined in `neunuc.config.json → builders` and stored under `templates/site-builder/`.

- Select template → edit content → preview → build to `dist/sites/<name>/`
- Built sites are static HTML/CSS/JS ready for Cloudflare Pages or Netlify.

### 2. Public Domains

Plan and validate domain configurations before DNS cutover.

- Enter domain → check A/AAAA/CNAME records → validate SSL readiness
- Outputs a deployment checklist and `CNAME` recommendation

### 3. Content Registry

Manage content snippets, copy blocks, and media assets used across outreach surfaces.

- Store reusable copy, images, and metadata
- Tag content by surface (founder, system, outreach, pricing, therapy)
- Export content bundles to builder pipelines

### 4. Lead Routing

Configure lead capture flows and validation rules.

- Define form fields, validation rules, and webhook endpoints
- Test submission locally before enabling `trustBoundary.leadCaptureEnabled`
- Integrates with CRM webhook defined in `neunuc.config.json`

### 5. Discord Control

Draft and test Discord bot manifests before deployment.

- Select bot template from `templates/discord-bot/`
- Edit intents, slash commands, and event handlers
- Test against a local mock gateway
- Export to `dist/bots/<name>/` for deployment

## Safety boundaries

The workspace enforces the following safety rules:

| Rule | Enforcement |
|------|-------------|
| Localhost only | Binds to `127.0.0.1`. No `--host` override in default scripts. |
| No external API calls without config | All integrations require explicit `neunuc.config.json` flags. |
| Builder output is local-first | Build artifacts go to `dist/`. Deployment is a separate manual step. |
| No secrets in workspace storage | Tokens and keys live in `neunuc.config.json` or env vars, never in workspace state. |

## Builder registry

Builders are registered in `neunuc.config.json`:

```json
{
  "builders": {
    "site": {
      "template": "templates/site-builder",
      "output": "dist/sites",
      "runtime": "static"
    },
    "discord": {
      "template": "templates/discord-bot",
      "output": "dist/bots",
      "runtime": "node"
    }
  }
}
```

To add a builder:

1. Create template directory under `templates/<name>/`
2. Add entry to `neunuc.config.json → builders`
3. Restart workspace

## Deployment separation

The workspace itself is never deployed. Its outputs are:

| Output | Destination | Method |
|--------|-------------|--------|
| Built sites | `dist/sites/` → Cloudflare Pages | Manual wrangler deploy or CI |
| Built bots | `dist/bots/` → Hosting VM | Manual rsync or CI |
| Domain plans | Exported as markdown checklist | Operator decision |
| Lead config | Merged into `neunuc.config.json` | Commit and push |

## Boot command

```powershell
pnpm ops:workspace
```

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Port 5173 in use | Another Vite instance running | `pnpm ops:workspace -- --port 5174` or kill existing process |
| Builder not appearing | Not registered in `neunuc.config.json` | Add entry and restart |
| Template not found | Path mismatch in builder config | Verify `templates/<name>/` exists relative to repo root |
| Workspace loads but lanes empty | Build cache stale | `rm -rf node_modules/.vite` and restart |
