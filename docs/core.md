# Core & Observability
Runtime identity, health checking, and logging are deliberately flat. No managers, no registries — just functions that return plain dicts.

---

## Identity (`runtime/core.py`)

Each runtime instance gets a unique identity at startup:

```python
from runtime import core

print(core.identity())
```

Response:

```json
{
    "id": "a1b2c3d4",
    "version": "0.5.0",
    "build": "v5-cracker",
    "mode": "api",
    "env": "development",
    "started_at": 1716123000.0,
    "uptime_s": 3600.5,
    "platform": "Windows",
    "python": "3.11.9",
    "pid": 12345
}
```

| Field | Description |
|-------|-------------|
| `id` | 8-char hex instance ID (random at boot) |
| `version` | Runtime version string |
| `build` | Build tag / codename |
| `mode` | Boot mode (`api`, `cli`, etc.) |
| `env` | Environment (`development`, `production`) |
| `started_at` | Unix timestamp of boot |
| `uptime_s` | Seconds since boot |
| `platform` | OS name |
| `python` | Python version (short) |
| `pid` | Operating-system process ID |

---

## Health Checks

### `/health` Endpoint

```bash
curl http://localhost:8000/health
```

Response:

```json
{
    "status": "ok",
    "checks": [
        {"name": "required_dirs", "ok": true, "detail": "all present"},
        {"name": "python_version", "ok": true, "detail": "3.11 (ok)"},
        {"name": "memory_writable", "ok": true, "detail": "writable"}
    ],
    "uptime_s": 3600.5
}
```

If any check fails, `status` becomes `degraded`.

### Programmatic Check

```python
from runtime import core

if core.is_healthy():
    print("All systems green")
else:
    print(core.health())  # inspect failures
```

### Check Details

| Check | What it validates | Failure mode |
|-------|-------------------|--------------|
| `required_dirs` | `data/state`, `data/memory`, `data/artifacts`, `logs`, `models` exist | Missing directory |
| `python_version` | Python >= 3.11 | Running on 3.10 or older |
| `memory_writable` | `data/memory` is writable | Permission denied / missing path |

---

## Logging (`observe/log.py`)

### Setup

Called once during boot:

```python
from observe.log import setup, get_logger

setup(level="info", log_file="logs/neunuc.log")
```

### Usage

```python
log = get_logger("surface")
log.info("Boot complete")
log.debug("WS client joined: %s", ws_id)
```

Logger names are prefixed with `neunuc.`:

```
neunuc.surface
neunuc.boot
neunuc.pipeline
neunuc.broadcast
```

### Output Destinations

| Destination | Format | Condition |
|-------------|--------|-----------|
| **Console** | Rich colored output (with tracebacks) | If `rich` is installed |
| **Console fallback** | Plain `%(asctime)s %(levelname)-8s %(name)s %(message)s` | If `rich` missing |
| **File** | `logs/neunuc.log` | Always, plain text |

### Log Level

Set via `LOG_LEVEL` env var (`debug`, `info`, `warning`, `error`). Default is `info`.

### Noisy Libraries

These are automatically silenced to `WARNING`:

- `http`
- `httpx`
- `ws`
- `asyncio`

---

## Observability Patterns

### Structured Logging in Handlers

```python
log.info("infer_request", extra={
    "session_id": session_id,
    "model": model,
    "elapsed_ms": elapsed,
})
```

### Metrics from Gate Logs

Export gate request traces for latency/error-rate dashboards:

```python
from gateway import gate

traces = gate.recent(n=500)
# Parse ts, allowed, path for metrics
```

### Health Probe for Load Balancers

Configure your load balancer or container orchestrator to hit `/health`:

```
HTTP GET /health → expect 200 + {"status": "ok"}
```

Use `/status` for richer runtime metadata (model load state, WS client count, sessions).

---

## Boot Sequence Integration

`core.init(mode, env)` is called during **Phase 2 (Core)** of boot:

```
Phase 1 Boot   → Phase 2 Core   → Phase 3 Orchestrate → ...
                 core.init()      register handlers
```

Health checks auto-run on every `/health` call, so they reflect current disk/python state.
