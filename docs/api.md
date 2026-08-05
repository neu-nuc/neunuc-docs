# API Reference
Runtime endpoint specifications for `apps/neunuc-runtime/`.

Base URL: `http://127.0.0.1:8400`

## Health & status

### `GET /health`

Quick health check. Returns `status`, `checks`, and `uptime_s`.

**Example Request**

```bash
curl http://127.0.0.1:8400/health
```

**Example Response**

```json
{
  "status": "ok",
  "uptime_s": 123.45,
  "checks": [
    {"ok": true, "name": "runtime", "detail": "..."}
  ]
}
```

---

### `GET /status`

Detailed runtime status dump.

**Example Request**

```bash
curl http://127.0.0.1:8400/status
```

**Example Response**

```json
{
  "identity":   {"id": "...", "env": "development", "mode": "..."},
  "inference":  {"loaded": true, "model": "phi-3-mini", "device": "directml"},
  "ws_clients": 0,
  "sessions":   [],
  "memory_len": 0,
  "state_keys": ["neunuc.booted", "neunuc.mode", "neunuc.device"],
  "gate_log":   [],
  "orch_traces":[]
}
```

## Inference

### `POST /infer`

Run inference against the loaded model. Returns complete JSON response.

**Headers**

| Header | Value |
|--------|-------|
| `Content-Type` | `application/json` |

**Body**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `prompt` | string | yes | The text prompt to send to the model |
| `session_id` | string | no | Conversation session ID for history tracking |
| `opts` | object | no | Options dict (system prompt, temperature, etc.) |

**Example Request**

```bash
curl -X POST http://127.0.0.1:8400/infer \
  -H "Content-Type: application/json" \
  -d '{"prompt": "What is the capital of France?"}'
```

**Example Response**

```json
{
  "ok": true,
  "text": "The capital of France is Paris.",
  "elapsed_ms": 245.3,
  "trace_id": "a1b2c3d4e5",
  "req_id": "req-uuid"
}
```

**Error Responses**

| Status | Meaning |
|--------|---------|
| `400` | Empty prompt or pipeline blocked |
| `403` | Gate denied (rate limit or policy) |
| `429` | Rate limited |

---

### `POST /infer/stream`

Stream inference results via Server-Sent Events (SSE).

**Headers**

| Header | Value |
|--------|-------|
| `Content-Type` | `application/json` |
| `Accept` | `text/event-stream` |

**Body**

Same as `/infer`.

**Example Request**

```bash
curl -X POST http://127.0.0.1:8400/infer/stream \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{"prompt": "Tell me a joke", "session_id": "s1"}'
```

**Event Stream Format**

```text
data: {"type": "chunk", "text": "Why", "req_id": "..."}

data: {"type": "chunk", "text": " did", "req_id": "..."}

data: {"type": "done", "req_id": "..."}
```

When `session_id` is provided, the full response is stored in session history after streaming completes.

## Memory

### `POST /memory/store`

Store a memory entry. Upserts by key (overwrites existing).

**Body**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `key` | string | yes | Memory key (unique identifier) |
| `value` | string | yes | Memory value |
| `ttl` | int | no | Time-to-live in seconds |
| `tags` | list | no | String tags for categorization |

**Example**

```bash
curl -X POST http://127.0.0.1:8400/memory/store \
  -H "Content-Type: application/json" \
  -d '{"key": "user_name", "value": "Alice", "tags": ["profile"]}'
```

**Response**

```json
{"ok": true, "id": "abc123def0"}
```

---

### `POST /memory/search`

Search memory entries by substring match on key or value.

**Body**

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `query` | string | "" | Search string |
| `limit` | int | 10 | Max results |

**Example**

```bash
curl -X POST http://127.0.0.1:8400/memory/search \
  -H "Content-Type: application/json" \
  -d '{"query": "Alice", "limit": 5}'
```

**Response**

```json
{
  "ok": true,
  "results": [
    {"id": "...", "key": "user_name", "value": "Alice", "ts": 1699999999, "tags": ["profile"]}
  ],
  "count": 1
}
```

---

### `GET /memory/context`

Build a memory context block for prompt injection. Returns formatted text suitable for prepending to a prompt.

**Query Parameters**

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `query` | string | "" | Query to search for relevant memories |
| `max_chars` | int | 1200 | Max length of context block |

**Example**

```bash
curl "http://127.0.0.1:8400/memory/context?query=Alice&max_chars=500"
```

**Response**

```json
{"ok": true, "context": "[Memory context]\n  user_name: Alice\n  ..."}
```

## State

### `POST /state/set`

Set a runtime state key.

**Body**

| Field | Type | Required |
|-------|------|----------|
| `key` | string | yes |
| `value` | any | yes |

**Example**

```bash
curl -X POST http://127.0.0.1:8400/state/set \
  -H "Content-Type: application/json" \
  -d '{"key": "mode", "value": "production"}'
```

---

### `GET /state/get`

Get a runtime state value.

**Query Parameters**

| Param | Type | Required |
|-------|------|----------|
| `key` | string | yes |
| `default` | string | no |

**Example**

```bash
curl "http://127.0.0.1:8400/state/get?key=mode&default=development"
```

**Response**

```json
{"ok": true, "value": "production"}
```

## Orchestrator

### `POST /orchestrator/run`

Direct passthrough to the orchestrator. Runs any registered handler.

**Body**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `kind` | string | yes | Registered handler name |
| `payload` | object | no | Payload to pass to handler |

**Example**

```bash
curl -X POST http://127.0.0.1:8400/orchestrator/run \
  -H "Content-Type: application/json" \
  -d '{"kind": "infer", "payload": {"prompt": "Hello"}}'
```

**Response**

Returns whatever the orchestrator produces:

```json
{
  "trace_id": "a1b2c3d4e5",
  "kind": "infer",
  "ok": true,
  "result": {"text": "Hello! How can I help?", "elapsed_ms": 123.4},
  "error": null,
  "retries": 0,
  "elapsed_ms": 125.0,
  "ts": 1699999999.0
}
```

## WebSocket

### `WS /ws`

Real-time connection for inference and events.

**Message Format**

Send JSON messages:

```json
{"type": "infer", "prompt": "Hello", "session_id": "s1"}
```

**Message Types**

| Type | Description | Response |
|------|-------------|----------|
| `ping` | Keepalive check | `{"type": "pong", "ts": ...}` |
| `infer` | Run inference | Result broadcast via `broadcast.push` |
| *(custom)* | Any registered orchestrator kind | Handled by orchestrator |

**Example (JavaScript)**

```javascript
const ws = new WebSocket("ws://127.0.0.1:8400/ws");
ws.onopen = () => {
  ws.send(JSON.stringify({type: "infer", prompt: "Hello world"}));
};
ws.onmessage = (e) => console.log(JSON.parse(e.data));
```

**Fire-and-Forget**
    WS inference is fire-and-forget. The result comes back through the broadcast system, not directly in the WS response.

## Response Codes Summary

| Code | Meaning |
|------|---------|
| `200` | Success |
| `400` | Bad request (empty prompt, missing key, pipeline blocked) |
| `403` | Gate denied |
| `429` | Rate limited |
| `500` | Server error (inference failed, internal error) |
