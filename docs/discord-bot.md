# Discord Bot Runtime
Discord bot deployment, safety model, manifest validation, and command registration.

---

## Explainer

A separately bounded `discord.js` runtime for a validated NeuNuc Discord bot manifest. It is not the operator app, does not expose the operator UI, and does not replace Discord permissions or moderation tools.

The runtime accepts only allowlisted guild IDs from `bot-manifest.json`, uses the minimal `Guilds` intent, and supports only approved slash commands.

- **Path**: `apps/neunuc-ops-workspace/adapters/discord-bot-runtime/`
- **Stack**: Node.js, discord.js
- **Port**: `8788` (health endpoint)
- **Intent**: Minimal `Guilds`

```powershell
cd apps/neunuc-ops-workspace/adapters/discord-bot-runtime
pnpm install --ignore-workspace
pnpm --ignore-workspace validate
pnpm --ignore-workspace register:commands
pnpm --ignore-workspace start
```

---

## Safety Model

| Guard | Behavior |
|-------|----------|
| Guild allowlist | Only guilds in `bot-manifest.json` are accepted |
| Minimal intent | `Guilds` only — no message content, no member lists |
| Approved commands | `/help`, `/status`, `/workspace-status` (role-gated) |
| Idempotent registration | `PUT` replaces full command set; defaults to dry-run |
| No destructive actions | No shell execution, self-bot, mass messaging, auto-invites, bulk moderation |

---

## Setup Flow

1. Generate a validated manifest in the NeuNuc Operator's **Discord & Bots** lane.
2. Copy it to this directory as `bot-manifest.json`.
3. Install runtime dependencies:
   ```powershell
   pnpm install --ignore-workspace
   ```
4. Copy `.env.example` to `.env` and set secrets via process manager or CI/CD secret store.
5. Validate the manifest:
   ```powershell
   pnpm --ignore-workspace validate
   ```
6. Review command registration dry-run:
   ```powershell
   pnpm --ignore-workspace register:commands
   ```
7. After explicit operator approval, set `DISCORD_DRY_RUN=false` and apply:
   ```powershell
   node src/register-commands.mjs --apply
   ```
8. Start the bot:
   ```powershell
   pnpm --ignore-workspace start
   ```

---

## Required Secrets

| Variable | Purpose |
|----------|---------|
| `DISCORD_BOT_TOKEN` | Bot token used only by this runtime |
| `DISCORD_APPLICATION_ID` | Application ID for command registration |
| `DISCORD_GUILD_ID` | One allowlisted guild for registration |

Non-secret config: `BOT_MANIFEST_PATH`, `DISCORD_DRY_RUN`, `HEALTH_HOST`, `HEALTH_PORT`.

---

## Deployment

Deploy only after explicit operator review. Put secrets in the platform secret store, expose no public management endpoint, and configure a private `/healthz` check.

GitHub Actions validates schema and syntax but intentionally does not deploy to Discord, Cloudflare, or any host.
