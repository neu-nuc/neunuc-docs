# Examples
Reference snippets for runtime inference, streaming, memory, and WebSocket operations.

## Health Check Script

```python
#!/usr/bin/env python3
"""Quick health check with colored output."""
import httpx, sys

def check():
    try:
        r = httpx.get("http://127.0.0.1:8400/health", timeout=3)
        data = r.json()
        status = data.get("status", "unknown")
        symbol = "✓" if status == "ok" else "!"
        print(f"{symbol} NeuNuc health: {status}")
        for c in data.get("checks", []):
            ok = "✓" if c["ok"] else "✗"
            print(f"  {ok} {c['name']}: {c.get('detail', '')}")
        return status == "ok"
    except Exception as e:
        print(f"✗ Runtime not responding: {e}")
        return False

if __name__ == "__main__":
    sys.exit(0 if check() else 1)
```

## Inference Request

=== "curl"
    ```bash
    curl -X POST http://127.0.0.1:8400/infer \
      -H "Content-Type: application/json" \
      -d '{"prompt": "Explain quantum computing in one sentence"}'
    ```

=== "Python (httpx)"
    ```python
    import httpx

    r = httpx.post("http://127.0.0.1:8400/infer", json={
        "prompt": "Explain quantum computing in one sentence",
        "session_id": "demo-session",
        "opts": {"temperature": 0.7}
    })
    print(r.json()["text"])
    ```

=== "Python (async)"
    ```python
    import asyncio, httpx

    async def infer():
        async with httpx.AsyncClient() as c:
            r = await c.post("http://127.0.0.1:8400/infer", json={
                "prompt": "Hello world"
            })
            return r.json()

    print(asyncio.run(infer()))
    ```

## Streaming Inference

```python
import httpx

with httpx.Client() as client:
    with client.stream(
        "POST", "http://127.0.0.1:8400/infer/stream",
        json={"prompt": "Tell me a story", "session_id": "s1"}
    ) as response:
        for line in response.iter_lines():
            if line.startswith("data: "):
                import json
                data = json.loads(line[6:])
                if data["type"] == "chunk":
                    print(data["text"], end="", flush=True)
                elif data["type"] == "done":
                    print("\n[Done]")
```

## Store and Search Memory

```python
import httpx

base = "http://127.0.0.1:8400"

# Store
httpx.post(f"{base}/memory/store", json={
    "key": "user_name",
    "value": "Alice",
    "tags": ["profile"]
})

# Search
r = httpx.post(f"{base}/memory/search", json={"query": "Alice"})
print(r.json()["results"])

# Context
r = httpx.get(f"{base}/memory/context", params={"query": "Alice"})
print(r.json()["context"])
```

## WebSocket Client

```python
import asyncio, json, websockets

async def ws_client():
    uri = "ws://127.0.0.1:8400/ws"
    async with websockets.connect(uri) as ws:
        # Ping
        await ws.send(json.dumps({"type": "ping"}))
        pong = await ws.recv()
        print(f"Pong: {pong}")

        # Infer
        await ws.send(json.dumps({
            "type": "infer",
            "prompt": "What is 2+2?",
            "session_id": "math-session"
        }))
        # Result comes back through broadcast
        async for msg in ws:
            print(json.loads(msg))

asyncio.run(ws_client())
```

## Session-based Chat

```python
import httpx

base = "http://127.0.0.1:8400"
session = "chat-001"

def chat(message):
    r = httpx.post(f"{base}/infer", json={
        "prompt": message,
        "session_id": session
    })
    return r.json()["text"]

print(chat("My name is Bob"))
print(chat("What is my name?"))  # Uses session history
```

## Custom Pipeline Step

```python
# In your init code (runs after boot):
from runtime import pipeline

async def my_filter(payload):
    if "password" in payload.get("prompt", "").lower():
        payload["_stop"] = True
        payload["_error"] = "sensitive content blocked"
    return payload

pipeline.add("safety_filter", my_filter)
```

## Custom Orchestrator Handler

```python
from runtime import orchestrator as orch

async def handle_translate(payload):
    text = payload.get("text", "")
    lang = payload.get("lang", "en")
    # Your translation logic here
    return {"ok": True, "text": f"[{lang}] {text}"}

orch.register("translate", handle_translate)

# Now call via:
# POST /orchestrator/run {"kind": "translate", "payload": {"text": "Hello", "lang": "es"}}
```
