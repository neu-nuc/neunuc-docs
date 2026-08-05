# nuc CLI
The `nuc` CLI (`apps/nuc-cli/`) is our internal tool for local LLM inference, model management, and skill orchestration. It is designed to run without cloud dependencies and can be packaged as a single Windows executable.

## Installation

```powershell
cd apps/nuc-cli
npm install
npm run build
npm install -g .
```

Verify:

```powershell
nuc --version
```

## Backends

The CLI supports multiple inference backends. The active backend is selected via config or the `--backend` flag.

| Backend | Purpose | Requirements |
|---------|---------|--------------|
| `ollama` | Local Ollama server | Ollama installed and running |
| `llama.cpp` | Bare-metal GGUF inference | `llama.cpp` binary or bundled DLL |
| `onnx` | ONNX Runtime inference | `onnxruntime` Python package |
| `openai` | Remote OpenAI API | `OPENAI_API_KEY` env var |
| `moonshot` | Moonshot AI API | `MOONSHOT_API_KEY` env var |
| `perplexity` | Perplexity API | `PERPLEXITY_API_KEY` env var |
| `foundry` | Azure AI Foundry | Azure credentials and endpoint |

## Commands

### Chat

```powershell
nuc "what is 2+2"
nuc --backend ollama "explain quantum computing"
nuc --backend llama.cpp --model path/to/model.gguf "hello"
```

### Interactive REPL

```powershell
nuc repl
```

REPL supports:
- Multi-turn conversation
- `/model` to switch models
- `/backend` to switch backends
- `/clear` to reset context
- `/exit` to quit

### Model management

```powershell
# List local models
nuc models list

# Pull a model from Ollama registry
nuc models pull llama3.2

# Remove a model
nuc models rm llama3.2

# Show model info
nuc models info llama3.2
```

### Skills

Skills are reusable prompt templates and tool chains.

```powershell
# List skills
nuc skills list

# Run a skill
nuc skill summarize --file document.txt
nuc skill code-review --file src/index.mjs
```

Skill definitions live in `apps/nuc-cli/skills/`.

### Config

```powershell
# Show current config
nuc config

# Set default backend
nuc config set backend ollama

# Set default model
nuc config set model llama3.2

# Open config in editor
nuc config edit
```

Config is stored at:
- Windows: `%LOCALAPPDATA%\nuc\config.json`
- macOS/Linux: `~/.config/nuc/config.json`

## Packaging

Build a single Windows executable:

```powershell
cd apps/nuc-cli
npm run package
```

Output: `dist/nuc.exe`

This bundles Node.js runtime, CLI code, and all dependencies. No external Node.js installation required on target machine.

## Environment variables

| Variable | Purpose |
|----------|---------|
| `OPENAI_API_KEY` | OpenAI backend auth |
| `MOONSHOT_API_KEY` | Moonshot backend auth |
| `PERPLEXITY_API_KEY` | Perplexity backend auth |
| `AZURE_FOUNDRY_ENDPOINT` | Azure Foundry endpoint |
| `AZURE_FOUNDRY_KEY` | Azure Foundry API key |
| `OLLAMA_HOST` | Ollama server host (default: `127.0.0.1:11434`) |

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `nuc: command not found` | Not installed globally | Run `npm install -g .` from `apps/nuc-cli/` |
| `Backend not available` | Backend server not running | Start Ollama, or check API keys |
| `Model not found` | Model not pulled locally | Run `nuc models pull <name>` |
| `package.exe fails` | Missing build tools | Install `pkg` globally: `npm install -g pkg` |
| Slow inference | CPU fallback instead of GPU | Verify DirectML / CUDA / Metal available for backend |
