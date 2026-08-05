# Models
& Inference

NeuNuc supports multiple inference backends across the runtime and CLI. This page documents all backends, their requirements, and how we select between them.

## Backends

### Runtime: ONNX Runtime + DirectML

The Python runtime (`apps/neunuc-runtime/`) uses `onnxruntime-directml` for GPU acceleration on Windows with DirectML-capable hardware (AMD Radeon, Intel Arc, NVIDIA via DirectML).

```python
import onnxruntime as ort
print(ort.get_device())  # Should print 'DML' or similar
```

Fallback devices:

| Device | Env Var | Use Case |
|--------|---------|----------|
| `directml` | `NEUNUC_DEVICE=directml` | Windows with GPU (default) |
| `cpu` | `NEUNUC_DEVICE=cpu` | Any OS, no GPU |
| `cuda` | `NEUNUC_DEVICE=cuda` | Linux with NVIDIA GPU |

### CLI: llama.cpp + GGUF

The `nuc` CLI (`apps/nuc-cli/`) supports bare-metal GGUF inference via llama.cpp.

Requirements:
- `llama.cpp` binary or bundled DLL
- `.gguf` model file

```powershell
nuc --backend llama.cpp --model path/to/model.gguf "hello"
```

### CLI: Ollama

Local Ollama server backend.

Requirements:
- Ollama installed and running
- `OLLAMA_HOST` env var (default: `127.0.0.1:11434`)

```powershell
nuc --backend ollama --model llama3.2 "explain quantum computing"
```

### CLI: Remote APIs

| Provider | Env Var | Notes |
|----------|---------|-------|
| OpenAI | `OPENAI_API_KEY` | GPT-4, GPT-3.5 |
| Moonshot | `MOONSHOT_API_KEY` | Moonshot AI models |
| Perplexity | `PERPLEXITY_API_KEY` | Perplexity API |
| Azure Foundry | `AZURE_FOUNDRY_ENDPOINT`, `AZURE_FOUNDRY_KEY` | Enterprise Azure |

## Model loading

Models load asynchronously during boot Phase 4:

```python
# From runtime/boot.py
from inference import run as inf_run
inf_run.load({"model_dir": model_dir, "model_name": "phi-3-mini", "device": device})
```

The runtime is ready to serve before the model finishes loading. First inference request may trigger a wait.

## Model Files

Expected layout under `models/`:

```text
models/
├── phi-3-mini/
│   ├── model.onnx              # ONNX model
│   ├── tokenizer.json          # Tokenizer config
│   └── config.json             # Model config
└── manifest.json               # Model registry
```

## Inference API

### Synchronous

```python
import inference.run as inf_run

result = await inf_run.infer("Hello world", {"temperature": 0.7})
# Returns: {ok, text, elapsed_ms}
```

### Streaming

```python
async for chunk in inf_run.stream("Tell me a story", {}):
    print(chunk, end="", flush=True)
```

### Status

```python
status = inf_run.status()
# Returns: {loaded, model, device, ...}
```

## Adding a New Model

1. **Download or convert** to ONNX format
2. **Place files** under `models/your-model-name/`
3. **Update manifest** in `models/manifest.json`
4. **Set default** in boot or `.env`:
   ```bash
   NEUNUC_MODEL_NAME=your-model-name
   ```
5. **Validate** locally:
   ```bash
   python -c "import inference.run as i; print(i.status())"
   ```

Keep model files out of git. Use `.gitignore`:
```
models/*/
!models/manifest.json
```

## Performance Tips

| Tip | Effect |
|-----|--------|
| Use DirectML | 5-10x faster than CPU on supported hardware |
| Warm up model | First inference is slow; trigger a dummy request on boot |
| Limit context | Shorter prompts = faster generation |
| Batch requests | Use session-based chat instead of single-turn |
| Reduce beam width | Set `opts={"num_beams": 1}` for greedy decoding |

## Model Checklist

- [ ] Model files placed under `models/your-model/`
- [ ] Tokenizer config included
- [ ] Manifest updated
- [ ] Local inference validated
- [ ] Performance benchmarked
- [ ] Large files excluded from git
