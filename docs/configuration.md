# Configuration
Runtime configuration for `apps/neunuc-runtime/`. For org-level config, see [Config System](config-system.md).

The runtime loads configuration from environment variables and `.env` files.

## Environment variables

### Runtime

| Variable | Default | Description |
|----------|---------|-------------|
| `NEUNUC_HOST` | `127.0.0.1` | API bind address |
| `NEUNUC_PORT` | `8400` | API port |
| `NEUNUC_ENV` | `development` | Environment mode (`development`, `production`) |
| `NEUNUC_DEVICE` | `directml` | Inference device (`directml`, `cpu`, `cuda`) |
| `NEUNUC_SURFACE_PORT` | `3400` | Node.js surface bridge port |

### Inference

| Variable | Default | Description |
|----------|---------|-------------|
| `NEUNUC_MODEL_DIR` | `models/` | Directory containing model artifacts |
| `NEUNUC_MODEL_NAME` | `phi-3-mini` | Model to load on boot |

### Paths

| Variable | Default | Description |
|----------|---------|-------------|
| `NEUNUC_DATA_ROOT` | `data/` | Base directory for state, memory, artifacts |
| `NEUNUC_STATE_DIR` | `data/state/` | Runtime state storage |
| `NEUNUC_MEMORY_FILE` | `data/memory/memory.json` | Memory storage |

### Logging

| Variable | Default | Description |
|----------|---------|-------------|
| `NEUNUC_LOG_LEVEL` | `info` | Log level (`debug`, `info`, `warning`, `error`) |

## `.env` File

Create a `.env` file in the project root:

```bash
NEUNUC_HOST=0.0.0.0
NEUNUC_PORT=8400
NEUNUC_ENV=production
NEUNUC_DEVICE=directml
NEUNUC_LOG_LEVEL=warning
```

The boot sequence automatically loads `.env` on startup. Variables set in the environment take precedence over `.env`.

## Config Precedence

1. CLI flags (`--host`, `--port`, `--log-level`)
2. Environment variables
3. `.env` file
4. Built-in defaults

## Deployment Overrides

`deploy/mode.py` detects deployment mode based on environment. Override with:

```bash
NEUNUC_MODE=production
```

Detected modes:

| Mode | Detection |
|------|-----------|
| `production` | `NEUNUC_ENV=production` |
| `development` | Default |

## Example: Production `.env`

```bash
# Runtime
NEUNUC_HOST=0.0.0.0
NEUNUC_PORT=8400
NEUNUC_ENV=production
NEUNUC_LOG_LEVEL=warning

# Inference
NEUNUC_DEVICE=directml
NEUNUC_MODEL_DIR=/opt/neunuc/models

# Data
NEUNUC_DATA_ROOT=/opt/neunuc/data
```

## Docker / Container

Pass environment variables at runtime:

```bash
docker run -e NEUNUC_HOST=0.0.0.0 -e NEUNUC_PORT=8400 neunuc:latest
```

Or use a `.env` file mounted as a volume:

```bash
docker run --env-file .env neunuc:latest
```
