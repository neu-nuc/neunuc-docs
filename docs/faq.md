# Frequently Asked Questions
## General

### What is NeuNuc?

Our local-first operating layer. See [Overview](overview.md) for the full system description.

NeuNuc is a lightweight Python runtime for serving ONNX models over HTTP and WebSocket. It is designed to be class-free, dependency-light, and easy to embed or deploy.

### Do I need a GPU?

No. ONNX Runtime can use DirectML on Windows, CPU on all platforms, or CUDA if available. Set `DEVICE=cpu` for portable deployments.

### What Python version is required?

Python **3.11 or newer**. The health check will fail on older versions.

---

## Installation & Boot

### Why does boot fail with "missing directory"?

Boot checks for `data/state`, `data/memory`, `data/artifacts`, `logs`, and `models`. Create them manually or let boot auto-create them (most do):

```bash
mkdir -p data/{state,memory,artifacts} logs models
```

### Can I run multiple instances?

Yes, but each instance uses its own `data/` and `logs/` directories. Use separate working directories or mount volumes per instance.

### How do I change the port?

Use the `--port` flag:

```bash
python main.py --port 8080
```

---

## Inference

### Why is my first request slow?

ONNX models load **asynchronously** during Phase 4 of boot. The runtime accepts HTTP requests before the model is ready. Call `/status` and wait for `inference.ready == true`.

### How do I use a custom model?

Drop your `.onnx` file into `models/` and reference it by filename in the inference request:

```json
{"model": "my-model.onnx", "prompt": "hello"}
```

### What prompt length is supported?

The rules engine blocks prompts > **32,000 characters**. Empty prompts are also rejected.

### Can I stream tokens?

Yes. Use `POST /infer/stream` with `stream: true`. The response is Server-Sent Events (SSE).

---

## WebSocket

### Do I get a direct response on `/ws`?

No. `/ws` is a **broadcast listener**. After you POST to `/infer`, results are pushed to all connected WS clients via `broadcast.push()`.

### How many clients can connect?

There's no hard limit, but all clients are held in an in-memory `set()`. For production scale (>1,000 clients), consider an external pub/sub.

---

## State & Memory

### What's the difference between State and Memory?

| | State | Memory |
|---|---|---|
| **Scope** | Global key/value | Session-scoped |
| **Use case** | Feature flags, config | Conversation history, context |
| **Storage** | `data/state/state.json` | `data/memory/memory.json` |

### Is data persisted across restarts?

Yes. Both state and memory are flushed to JSON files on disk. Writes are atomic (temp-file-then-rename). A background flush runs every 15 seconds.

### Can I use a real database?

NeuNuc intentionally uses flat JSON files to avoid dependencies. If you need SQL, wire a custom handler into `runtime/surface.py` or use the orchestrator pipeline.

---

## Security

### Is there authentication?

Out of the box, no. The gate validates routes and rate-limits by IP. Add API-key middleware in `runtime/surface.py` or place NeuNuc behind a reverse proxy with auth.

### How do I rate-limit more aggressively?

Edit `gateway/gate.py`:

```python
RATE_PER_MIN = 30  # down from 60
BURST = 10         # down from 20
```

Or add per-client bucketing logic.

### Can I block specific prompts?

Yes. Add a custom rule:

```python
from runtime import rules

rules.add(
    name="block_profanity",
    match_fn=lambda p: "badword" in p.get("prompt", ""),
    allow=False,
    reason="profanity filter"
)
```

---

## Deployment

### How do I deploy to Cloudflare Pages?

Build the docs site:

```bash
mkdocs build
npx wrangler pages deploy site --project-name neunuc-docs --branch main
```

For the runtime itself, use Docker or run directly on a VM.

### Can I run in Docker?

Yes. See [Deployment](deployment.md) for a sample Dockerfile and `docker run` command.

### Does it work on macOS / Linux?

Yes. The runtime is pure Python + ONNX Runtime. DirectML is Windows-only; on macOS/Linux use `DEVICE=cpu` or `DEVICE=cuda`.

---

## Troubleshooting

### Where are the logs?

- **Console**: stderr (colored if `rich` is installed)
- **File**: `logs/neunuc.log`

### How do I enable debug logging?

```bash
python main.py --log-level debug
```

### Why is `/health` returning `degraded`?

Check the `checks` array in the response. Common causes:

- Missing required directories
- Python < 3.11
- `data/memory` not writable

### How do I report a bug?

Open an issue on GitHub with:

1. Runtime version (`/status` → `identity.version`)
2. Python version
3. OS / platform
4. Steps to reproduce
5. Relevant logs (`logs/neunuc.log`)
