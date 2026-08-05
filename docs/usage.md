# Usage
Runtime CLI options and flags for `apps/neunuc-runtime/main.py`.

## CLI options

| Flag | Description | Default |
|------|-------------|---------|
| `--host` | API bind host | `NEUNUC_HOST` or `127.0.0.1` |
| `--port` | API port | `NEUNUC_PORT` or `8400` |
| `--health` | Health check and exit | — |
| `--status` | Status JSON and exit | — |
| `--no-node` | Skip Node.js surface bridge | — |
| `--log-level` | Log level | `info` |

Valid log levels: `debug`, `info`, `warning`, `error`.

## Commands

### Start the Runtime

```powershell
# Default (port 8400, info logging, with Node.js bridge)
python main.py

# Custom port with debug logs, no bridge
python main.py --port 8401 --log-level debug --no-node

# Bind to all interfaces (for Docker/network access)
$env:NEUNUC_HOST="0.0.0.0"; python main.py
```

### Health Check

```powershell
# Built-in CLI health check
python main.py --health

# Or via HTTP
curl http://127.0.0.1:8400/health
```

Returns JSON with check status and uptime.

### Status Dump

```powershell
# Built-in CLI status dump
python main.py --status

# Or via HTTP
curl http://127.0.0.1:8400/status
```

Returns full JSON with:

- `identity` — runtime ID, env, mode
- `inference` — model load status
- `ws_clients` — active WebSocket connections
- `sessions` — conversation sessions
- `memory_len` — memory entry count
- `state_keys` — runtime state keys
- `gate_log` — recent gate decisions
- `orch_traces` — recent orchestrator traces

## Runtime Lifecycle

```
main.py
  ├── parse_args()
  ├── boot()                    # 5-phase initialization (runtime/boot.py)
  │   ├── Phase 1: Boot        # hardware, dirs, env
  │   ├── Phase 2: Core        # identity, health, store
  │   ├── Phase 3: Orchestrate # handlers, pipeline
  │   ├── Phase 4: Workloads   # model load (async)
  │   └── Phase 5: Surfaces    # FastAPI + Node.js bridge
  ├── build_app()              # FastAPI routes (runtime/surface.py)
  ├── _start_node()            # Node.js bridge subprocess (surface/server.js)
  └── uvicorn.serve()          # ASGI HTTP server
```

## Log Output

Boot sequence produces structured logs:

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  NeuNuc v0.5 — booting
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[1/5] Boot — hardware probe, dirs, env
[2/5] Core — identity, health, store, rules
  id=abc123  env=development  mode=desktop
[3/5] Orchestrate — register handlers, build pipeline
[4/5] Workloads — loading inference model (background)
[5/5] Surfaces — starting FastAPI + Node.js bridge
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Boot complete in 245ms
  API  → http://127.0.0.1:8400
  UI   → http://127.0.0.1:3400/daily/
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Graceful Shutdown

Send `Ctrl+C` (SIGINT) or `SIGTERM`. The runtime:

1. Stops uvicorn server
2. Terminates Node.js bridge subprocess
3. Flushes state and memory to disk
4. Exits cleanly
