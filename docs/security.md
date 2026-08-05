# Security & Policy
Our two-layer defense: **Gate** (network/rate-limit layer) and **Rules** (payload/policy layer). Both are flat-function modules with zero class overhead.

---

## Gate (`gateway/gate.py`)

The gate is the first check on every request. It validates the route and enforces rate limits before the request ever reaches a handler.

### Route table

Only exact `(method, path)` pairs in `ROUTES` are allowed. Static assets under `/static/` and `/assets/` pass via prefix match.

```python
ROUTES = {
    ("POST", "/infer"),
    ("POST", "/infer/stream"),
    ("GET",  "/health"),
    ("GET",  "/status"),
    ("GET",  "/ws"),
    ("GET",  "/surfaces/daily"),
    ("GET",  "/surfaces/canvas"),
    ("GET",  "/surfaces/studio"),
    ("POST", "/memory/store"),
    ("POST", "/memory/search"),
    ("GET",  "/memory/context"),
    ("POST", "/state/set"),
    ("GET",  "/state/get"),
    ("POST", "/orchestrator/run"),
}
```

Any method/path not in this set returns `403` with reason `route_not_found`.

### Rate limiting

Token-bucket per client IP:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `RATE_PER_MIN` | 60 | Sustained requests per minute |
| `BURST` | 20 | Maximum burst capacity |

```python
# Check if a request passes the gate
allowed, reason, req_id = gate.check(
    method="POST",
    path="/infer",
    client_ip="192.168.1.42"
)
```

If `allowed` is `False`:

- `reason == "rate_limited"` → return `429 Too Many Requests`
- `reason == "route_not_found"` → return `403 Forbidden`

### Request tracing

Every gate check generates a 12-char `req_id` (SHA-1 of IP + path + nanosecond timestamp). The last 500 entries are kept in memory:

```python
# Inspect recent gate decisions
for entry in gate.recent(n=10):
    print(entry["id"], entry["method"], entry["path"], entry["allowed"], entry["reason"])
```

Entry schema:

| Field | Type | Description |
|-------|------|-------------|
| `id` | `str` | 12-char request ID |
| `ts` | `float` | Unix timestamp |
| `method` | `str` | HTTP method |
| `path` | `str` | Request path |
| `ip` | `str` | Client IP |
| `allowed` | `bool` | Passed gate? |
| `reason` | `str` | Decision reason |

### Bucket state

Peek at a client's remaining tokens:

```python
state = gate.bucket_state("192.168.1.42")
# {"tokens": 17.35, "rate": 60}
```

---

## Rules (`runtime/rules.py`)

After the gate, write operations hit the rules engine. Rules are evaluated **in order**; first match wins.

### Built-in rules

| # | Name | Match | Action |
|---|------|-------|--------|
| 1 | `block_empty_prompt` | `prompt` is empty or whitespace | Deny |
| 2 | `block_oversized_prompt` | `prompt` > 32,000 chars | Deny |
| 3 | `block_no_session_on_write` | `_require_session=True` but no `session_id` | Deny |
| 4 | `allow_echo_mode` | `mode == "echo"` | Allow immediately |
| 5 | `allow_all` | Always matches | Allow (catch-all) |

### Checking a payload

```python
from runtime import rules

allowed, reason = rules.check({"prompt": "hello world"})
# (True, "default allow")

allowed, reason = rules.check({"prompt": ""})
# (False, "prompt is empty")
```

### Adding custom rules

```python
rules.add(
    name="block_banned_words",
    match_fn=lambda p: any(w in p.get("prompt", "") for w in ["banned1", "banned2"]),
    allow=False,
    reason="contains banned words",
    index=1  # insert before allow_all
)
```

Use `index` to control precedence. Without it, rules append just before the final `allow_all` catch-all.

### Listing rules

```python
print(rules.list_rules())
# ['block_empty_prompt', 'block_oversized_prompt', ...]
```

---

## CORS

The FastAPI surface adds broad CORS headers for local development:

```python
# runtime/surface.py — CORS middleware
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
)
```

**Production**
    Tighten `allow_origins` before deploying. The wildcard is intentional for local dev but must be restricted to our domain in production.

---

## Trust boundary

All trust boundary declarations live in `neunuc.config.json → trustBoundary`. See [Config System](config-system.md) for the full schema.

Default stance:

| Feature | Default | Rationale |
|---------|---------|-----------|
| `collectUserData` | `false` | No PII collection unless explicitly enabled |
| `analyticsEnabled` | `false` | No telemetry unless opted in |
| `paymentEnabled` | `false` | No payment processing unless needed |
| `leadCaptureEnabled` | `false` | No lead forms unless configured |
| `discordEnabled` | `false` | No bot integration unless configured |
| `turnstileEnabled` | `false` | No CAPTCHA unless configured |

## Security checklist

- [ ] Restrict CORS origins in production
- [ ] Place runtime behind a reverse proxy (Cloudflare, nginx) for TLS
- [ ] Add API-key middleware if exposing to the internet
- [ ] Adjust `RATE_PER_MIN` / `BURST` for expected load
- [ ] Review custom rules before each deployment
- [ ] Verify `trustBoundary` flags are `false` before public deploy
- [ ] Enable request-log export for SIEM integration
