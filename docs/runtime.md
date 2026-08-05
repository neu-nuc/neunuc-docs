# Runtime
The NeuNuc Runtime is a local-first Python inference engine with a Node.js surface bridge. The Python core handles models, memory, state, and orchestration. The Node.js bridge serves HTML surfaces and proxies API calls to the Python backend.

The Runtime sits between raw hardware and higher-level apps. It loads ONNX models via DirectML, CUDA, or CPU; exposes FastAPI endpoints for synchronous and streaming inference; and maintains a WebSocket pub/sub layer. The Node.js surface bridge translates between browser clients and the Python core.

**Location:** `apps/neunuc-runtime/`

Key subsystems:
- `main.py` — Entry point and boot sequence
- `runtime/` — Core Python modules (boot, core, surface, orchestrator, pipeline, store, broadcast, rules)
- `inference/` — Model loading and inference runner
- `surface/` — Node.js HTTP/WebSocket bridge (serves HTML, proxies to FastAPI)
- `gateway/` — Rate limiting and access gate
- `observe/` — Structured JSON logging
- `config/` — YAML-driven configuration
- `scripts/` — Bootstrap PowerShell scripts

Boot the runtime (Python + Node.js bridge):

```powershell
cd apps/neunuc-runtime
python main.py --mode=local --api-port=8400
```

Or start components separately:

```powershell
# Terminal 1 — Python core
python main.py --no-node --api-port=8400

# Terminal 2 — Node.js surface bridge
node surface/server.js
```

## Boot Phases

`runtime/boot.py` runs a 5-phase boot sequence. Each phase is a hard checkpoint: if any phase fails, the runtime exits cleanly. Boot order is hardcoded — no plugin system, no dynamic discovery.

```text
[1/5] Boot — hardware probe, dirs, env
[2/5] Core — identity, health, store, rules
[3/5] Orchestrate — register handlers, build pipeline
[4/5] Workloads — load inference model (background)
[5/5] Surfaces — start FastAPI + Node.js bridge
```

## Inference Backends

The runtime supports multiple inference backends depending on host hardware and OS. The default is DirectML on Windows with a compatible GPU. Selected via `NEUNUC_DEVICE` environment variable or `config/runtime.yaml`.

```python
import onnxruntime as ort
print(ort.get_device())  # DML, CUDA, or CPU
```

| Device | Env Var | Use Case |
|--------|---------|----------|
| `directml` | `NEUNUC_DEVICE=directml` | Windows with GPU (default) |
| `cpu` | `NEUNUC_DEVICE=cpu` | Any OS, no GPU |
| `cuda` | `NEUNUC_DEVICE=cuda` | Linux with NVIDIA GPU |

## Surface Bridge

`surface/server.js` is a Node.js HTTP server that serves static HTML and proxies `/api/*` to the Python FastAPI backend. It also forwards WebSocket messages between browsers and the FastAPI `/ws` endpoint using an RFC 6455 frame codec.

**Entry:** `apps/neunuc-runtime/surface/server.js`

Surfaces served:
- `http://127.0.0.1:3400/daily/` — Daily UI
- `http://127.0.0.1:3400/canvas/` — Canvas UI
- `http://127.0.0.1:3400/studio/` — Studio UI

Proxied routes:
- `/api/*` → `http://127.0.0.1:8400/*`
- WS upgrade → `ws://127.0.0.1:8400/ws`

```javascript
// surface/server.js — proxy to FastAPI
if (pth.startsWith("/api/")) {
  return proxyToApi(req, res, pth.slice(4)); // strip /api
}
```

## Gateway

`gateway/gate.py` controls who can talk to the runtime. It rate-limits by client IP and tracks every request with a unique `req_id`. Called by `runtime/surface.py` on every incoming request.

```python
# runtime/surface.py
allowed, reason, req_id = gate.check("POST", "/infer", client_ip)
if not allowed:
    return JSONResponse({"error": reason}, status_code=429)
```

## Telemetry

`observe/log.py` provides structured JSON logging. All runtime modules log through a single logger factory. Logs are written to `apps/neunuc-runtime/logs/` and to stdout.

Log levels: `debug`, `info`, `warning`, `error` — set via `--log-level` CLI flag or `NEUNUC_LOG_LEVEL` env var.

```python
from observe.log import get_logger
log = get_logger("inference")
log.info("Model loaded", model="phi-3-mini", device="directml")
```

## Safety Boundaries

The runtime is designed to be safe by default. It binds to loopback, stores no external credentials, and keeps configs portable. These boundaries are hardcoded, not configurable:

- **Loopback-only** — All listeners bind to `127.0.0.1` by default
- **No external credentials** — No cloud API keys, tokens, or secrets in committed files
- **No raw uploads** — User uploads are not stored here; `data/` contains runtime state only
- **No machine paths** — Configs use relative paths; no hard-coded `C:\` references

```powershell
# Verify loopback binding
python main.py --host 127.0.0.1 --port 8400
```
