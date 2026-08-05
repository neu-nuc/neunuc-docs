# NucBot
NucBot is the unified Discord runtime for the NeuNuc ecosystem. It captures OSINT evidence, manages AI personalities, persists memory, and exposes a dashboard for operators.

NucBot is not a simple chatbot. It is an append-only evidence capture system disguised as a Discord bot. Every message, reaction, and voice event is hashed and stored as tamper-evident evidence. AI features (chat, memory, personality) run on top of this foundation, not instead of it.

**Location:** `apps/nucbot/`

Key subsystems:
- `src/osint/` — Evidence capture and hashing
- `src/ai/` — Personality engine and chat
- `src/memory/` — Long-term memory storage
- `src/dashboard/` — Operator web dashboard
- `deploy/` — Cloud Run and Docker deployment configs

```powershell
cd apps/nucbot
pnpm run start
pnpm run validate-config
```

## OSINT Evidence Capture

The OSINT subsystem listens to Discord events (messages, reactions, voice state changes, member joins/leaves) and writes them to an append-only log. Each entry is hashed with SHA-256 and linked to the previous entry, forming a chain.

- **Entry:** `src/osintRuntime.js`
- **Storage:** Local SQLite or Cloud SQL (configurable)
- **Hashing:** SHA-256 chain with timestamp anchoring

```javascript
// Evidence entry structure
{
  id: "uuid",
  type: "message|reaction|voice|member",
  guild_id: "...",
  channel_id: "...",
  user_id: "...",
  payload: { /* event data */ },
  hash: "sha256_of_payload",
  prev_hash: "sha256_of_previous_entry",
  timestamp: "2025-01-01T00:00:00Z"
}
```

## AI Personality Engine

The AI subsystem loads personality templates from `config/personalities/` and applies them to chat responses. Personalities are JSON files that define tone, vocabulary, response style, and system prompt context.

- **Config:** `apps/nucbot/config/personalities/`
- **Models:** Azure OpenAI or local runtime bridge
- **Memory:** Contextual recall from `src/memory/`

```json
{
  "name": "operator-assistant",
  "tone": "direct",
  "vocabulary": "technical",
  "system_prompt": "You are a NeuNuc operations assistant. Be concise. Use system terminology."
}
```

## Memory System

Memory stores conversation context, user preferences, and learned facts. It is queryable by the AI subsystem to maintain continuity across sessions.

- **Storage:** SQLite table `memories`
- **Schema:** `user_id`, `key`, `value`, `importance`, `last_accessed`
- **Pruning:** Low-importance entries older than 90 days are archived

```javascript
// Store a memory
await memory.set({
  user_id: "123456789",
  key: "preferred_runtime",
  value: "directml",
  importance: 0.8
});
```

## Operator Dashboard

The dashboard is a web interface for operators to view evidence logs, manage bot configuration, and monitor health. It runs as a Vite-built SPA served from the bot process.

- **Source:** `src/dashboard/`
- **Build:** `pnpm run build:client`
- **Dev:** `pnpm run dev:client`

```powershell
# Build dashboard
pnpm run build:client

# Start bot with dashboard
pnpm run start
```

## Deployment

NucBot deploys to Google Cloud Run via Docker. The deployment pipeline includes secret fetching, container building, and staged rollouts.

- **Scripts:** `apps/nucbot/scripts/`
- **Configs:** `deploy/cloud-run/`, `docker-compose.yml`
- **Secrets:** 1Password CLI (`op run`)

```powershell
# Fetch secrets and deploy
pnpm run deploy

# Or manually
op run --env-file=.env.op -- gcloud run deploy nucbot ...
```
