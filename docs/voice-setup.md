# Voice Setup

Installation and configuration for the NeuNuc Voice Pipeline.

---

## Prerequisites

- Python 3.10, 3.11, or 3.12
- Windows 10/11, macOS, or Linux
- Microphone access (first run will prompt)
- Optional: DirectML-compatible GPU for faster Whisper inference

## Install from Source

```bash
git clone https://github.com/helzkelz/neunuc-voice.git
cd neunuc-voice
pip install -e ".[train]"
```

Optional extras:

```bash
pip install -e ".[gui]"     # Toga desktop GUI
pip install -e ".[api]"     # FastAPI + Uvicorn REST server
pip install -e ".[mobile]"   # Toga mobile
pip install -e ".[dev]"     # PyInstaller, pytest, black, ruff
```

## Download Models

Run the helper script:

```bash
python scripts/download_models.py
```

Or manually place models in the `models/` directory:

```
models/
├── openwakeword/
│   └── hey_nuc.onnx
├── whisper/
│   └── whisper-tiny.onnx
├── intent/
│   └── phi-intent.onnx
└── piper/
    ├── en_US-lessac-medium.onnx
    └── en_US-lessac-medium.onnx.json
```

## Configuration

Edit `config/config.yaml`:

```yaml
pipeline:
  name: "neunuc-voice"
  version: "0.1.0"
  sample_rate: 16000
  chunk_duration_ms: 30
  silence_threshold_db: -40.0
  max_recording_seconds: 30
  post_wake_listen_seconds: 5

wakeword:
  engine: "openwakeword"
  model_path: "models/openwakeword/hey_nuc.onnx"
  pretrained_models:
    - "hey_mycroft"
    - "hey_jarvis"
    - "alexa"
  threshold: 0.5
  buffer_duration_ms: 500
  custom:
    enabled: true
    name: "hey_nuc"
    training_samples: 100
    negative_samples: 500

stt:
  engine: "whisper_onnx"
  model_path: "models/whisper/whisper-tiny.onnx"
  model_size: "tiny"
  language: "en"
  beam_size: 5
  onnx:
    execution_provider: "DmlExecutionProvider"
    intra_op_num_threads: 4
    graph_optimization_level: "ORT_ENABLE_ALL"
  vad:
    enabled: true
    aggressiveness: 2

intent:
  engine: "phi_onnx"
  model_path: "models/intent/phi-intent.onnx"
  tokenizer_path: "models/intent/tokenizer.json"
  labels:
    - "lights_on"
    - "lights_off"
    - "set_timer"
    - "cancel_timer"
    - "weather_query"
    - "general_query"
    - "status_check"
    - "shutdown"
  threshold: 0.7
  fallback_keywords:
    lights_on:
      - "turn on the light"
      - "lights on"
    lights_off:
      - "turn off the light"
      - "lights off"

tts:
  engine: "piper"
  model_path: "models/piper/en_US-lessac-medium.onnx"
  config_path: "models/piper/en_US-lessac-medium.onnx.json"
  speaker_id: 0
  length_scale: 1.0
  noise_scale: 0.667
  noise_w: 0.8
  output_device: null
  output_sample_rate: 22050

audio:
  input_device: null
  output_device: null
  sample_rate: 16000
  channels: 1
  dtype: "int16"
  block_size: 480

nucortex:
  enabled: true
  endpoint: "ws://localhost:8765"
  api_key: null
  context_window_messages: 10
  personality:
    enabled: true
    mode: "sharp"
    system_prompt: |
      You are NeuNuc Voice — a local AI assistant with zero patience for bullshit.
      You are fact-based, efficient, and razor-sharp.
      You use sarcasm, dry wit, and occasional profanity when appropriate.
      You never apologize for being direct. You get shit done.
      Keep responses concise. No corporate fluff. No disclaimers.
      If the user asks something stupid, call it out tactfully.
      If you don't know something, say so without hand-wringing.

logging:
  level: "INFO"
  format: "%(asctime)s | %(name)s | %(levelname)s | %(message)s"
```

## Configuration Reference

| Section | Key | Default | Description |
|---------|-----|---------|-------------|
| `pipeline` | `sample_rate` | 16000 | Audio sample rate in Hz |
| `pipeline` | `max_recording_seconds` | 30 | Max seconds to listen after wakeword |
| `wakeword` | `threshold` | 0.5 | Detection confidence threshold (0 to 1) |
| `wakeword` | `custom.enabled` | true | Enable custom wakeword training |
| `stt` | `model_size` | tiny | whisper-tiny, whisper-base, whisper-small |
| `stt.onnx` | `execution_provider` | DmlExecutionProvider | DirectML, CUDA, or CPUExecutionProvider |
| `intent` | `threshold` | 0.7 | Intent classification confidence threshold |
| `tts` | `length_scale` | 1.0 | Speech speed (higher = slower) |
| `tts` | `noise_scale` | 0.667 | Neural noise variance |
| `nucortex` | `enabled` | true | Route general queries to NuCortex |
| `nucortex.personality` | `mode` | sharp | polite or sharp |

## First Run

```bash
python -m neunuc_voice --sharp
```

Expected output:

```
INFO | neunuc_voice.orchestrator | Initializing NeuNuc Voice Pipeline…
INFO | neunuc_voice.orchestrator | Pipeline initialized — waiting for wakeword
```

Say the wakeword (default: "hey nuc"). The pipeline enters LISTENING state. Speak your command. After 1.2 seconds of silence, it transcribes, classifies intent, and responds via TTS.

## Custom Wakeword Training

Record samples:

```bash
python scripts/record_samples.py --name "hey_nuc" --count 100
```

Train the model:

```bash
python scripts/train_wakeword.py \
  --positive-samples "samples/hey_nuc/" \
  --negative-samples "samples/negative/" \
  --output "models/openwakeword/hey_nuc.onnx"
```

Update `config.yaml`:

```yaml
wakeword:
  model_path: "models/openwakeword/hey_nuc.onnx"
```

## Voice Cloning (Piper)

Record 5 to 10 minutes of clean speech:

```bash
python scripts/record_samples.py --name "my_voice" --duration 300
```

Train Piper voice:

```bash
python scripts/train_tts_voice.py \
  --samples "samples/my_voice/" \
  --output "models/piper/my_voice.onnx"
```

Update `config.yaml`:

```yaml
tts:
  model_path: "models/piper/my_voice.onnx"
  config_path: "models/piper/my_voice.onnx.json"
```

## Model Quantization

Reduce model size and improve inference speed:

```bash
python scripts/quantize_models.py \
  --input "models/whisper/whisper-tiny.onnx" \
  --output "models/whisper/whisper-tiny-int8.onnx" \
  --int8
```

Update `config.yaml` with the quantized path. INT8 models use approximately half the memory and run 20 to 40 percent faster on compatible hardware.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| No audio input | Mic not default device | Set `audio.input_device` to device index |
| Wakeword never triggers | Threshold too high | Lower `wakeword.threshold` to 0.3 |
| Transcription gibberish | Wrong sample rate | Ensure mic matches `pipeline.sample_rate` |
| TTS silent | Output device wrong | Set `tts.output_device` or use null for default |
| NuCortex timeout | WebSocket not running | Start NuCortex on `ws://localhost:8765` |
| Slow inference | CPU-only fallback | Install DirectML or use quantized models |
| Import error on `sounddevice` | PortAudio not installed | Install PortAudio (`brew install portaudio` on macOS) |
