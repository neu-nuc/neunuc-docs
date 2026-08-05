# Troubleshooting
Diagnostic procedures and known issues.

## Boot Failures

### "Boot failed — aborting"

The runtime exited during the 5-phase boot sequence.

**Check:**
1. Port conflicts — another process is using port 8400:
   ```bash
   lsof -i :8400        # macOS/Linux
   netstat -ano | findstr :8400   # Windows
   ```
2. Missing Python dependencies — verify `pip install -r requirements.txt`
3. `.env` file syntax error — check for missing `=` or quotes

**Fix:**
```bash
# Kill process on port 8400
# Or change port:
python main.py --port 8401
```

---

### "Runtime not responding" (health check)

The runtime is not running or is stuck.

**Check:**
```bash
python main.py --health
# Or via HTTP:
curl http://127.0.0.1:8400/health
```

**Fix:**
- Ensure the Python process started successfully
- Check logs in `logs/` directory
- Verify no firewall is blocking localhost
- If using `--no-node`, check that the Python API port is accessible

---

## Inference Errors

### Model fails to load

**Symptoms:**
- `/status` shows `inference.loaded: false`
- Errors mentioning `onnxruntime-directml`

**Fix:**
1. Check DirectML support (Windows only):
   ```python
   import onnxruntime as ort
   print(ort.get_device())
   ```
2. Fallback to CPU:
   ```bash
   $env:NEUNUC_DEVICE="cpu"; python main.py
   ```
3. Verify model files exist in `models/` directory

---

### Out of memory on inference

**Symptoms:**
- Process killed during inference
- `OOM` errors in logs

**Fix:**
- Use a smaller model (e.g., `phi-3-mini` instead of larger variants)
- Reduce batch size or context window in `opts`
- Close other applications
- On Windows with DirectML: ensure GPU has enough VRAM

---

## Node.js Surface Bridge

### Surface doesn't start

**Symptoms:**
- No response at `http://127.0.0.1:3400/daily/`
- Process exits immediately

**Check:**
1. `surface/server.js` exists
2. Node.js is installed:
   ```bash
   node --version
   ```
3. Python FastAPI is running on port 8400:
   ```bash
   curl http://127.0.0.1:8400/health
   ```

**Fix:**
```bash
# Start Python core first
cd apps/neunuc-runtime
python main.py --no-node --api-port=8400

# Then start bridge separately
node surface/server.js
```

---

## Memory / State Issues

### Memory not persisting

**Symptoms:**
- Stored memories disappear after restart
- `memory_len` stays 0

**Check:**
```bash
ls data/memory/memory.json   # Linux/macOS
dir data\memory\memory.json  # Windows
```

**Fix:**
- Ensure the `data/` directory is writable
- Check disk space
- Verify `.env` isn't overriding `NEUNUC_DATA_ROOT`

---

### State corruption

**Symptoms:**
- Boot errors mentioning JSON parsing
- `state.json` is empty or truncated

**Fix:**
```bash
# Reset state (warning: destroys runtime state)
rm data/state/state.json
# or
move data\state\state.json data\state\state.json.bak
```

---

## WebSocket Issues

### WS connection refused

**Symptoms:**
- `WebSocket connection failed` in browser console

**Fix:**
- Verify runtime is running
- Check CORS settings (FastAPI defaults allow `*`)
- Ensure firewall allows WS on port 8400
- If using the surface bridge, verify `/api/ws` proxy is forwarding correctly

---

## General Debugging

### Enable debug logging

```bash
python main.py --log-level debug
```

### Check recent traces

```bash
curl http://127.0.0.1:8400/status | jq .orch_traces
```

### View gate log

```bash
curl http://127.0.0.1:8400/status | jq .gate_log
```

### Get full status dump

```bash
python main.py --status
# Or via HTTP:
curl http://127.0.0.1:8400/status
```
