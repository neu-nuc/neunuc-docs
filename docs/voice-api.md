# Voice API

REST API and WebSocket endpoints for remote clients, mobile apps, and home automation integration.

---

## Overview

When running with `--api`, the voice pipeline exposes a FastAPI server on port 8080. All endpoints are stateless except the WebSocket stream, which maintains a live audio pipeline session per connection.

```bash
python -m neunuc_voice --api --port 8080
# or
neunuc-api
```

## Endpoints

### Health Check

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/v1/status` | Pipeline health + model load status |

**Response:**

```json
{
  "stt_loaded": true,
  "intent_loaded": true,
  "tts_loaded": true,
  "wakeword_loaded": true
}
```

### Transcribe

| Method | Path | Content-Type | Description |
|--------|------|--------------|-------------|
| `POST` | `/api/v1/transcribe` | `multipart/form-data` | Upload WAV/PCM audio, get transcript |

**Request:**

```bash
curl -X POST http://localhost:8080/api/v1/transcribe \
  -F "audio=@recording.wav"
```

**Response:**

```json
{
  "transcript": "turn on the lights",
  "sample_rate": 16000
}
```

### Intent Classification

| Method | Path | Content-Type | Description |
|--------|------|--------------|-------------|
| `POST` | `/api/v1/intent` | `application/json` | Text in, intent + confidence out |

**Request:**

```bash
curl -X POST http://localhost:8080/api/v1/intent \
  -H "Content-Type: application/json" \
  -d '{"text": "turn on the lights", "tts": true, "response_text": "Lights on"}'
```

**Response:**

```json
{
  "intent": {
    "intent": "lights_on",
    "confidence": 0.94,
    "source": "onnx"
  },
  "audio_b64": "//uQZ..."
}
```

| Field | Type | Description |
|-------|------|-------------|
| `text` | string | Required. Input text to classify. |
| `tts` | boolean | Optional. If true, synthesize `response_text` and return base64 WAV. |
| `response_text` | string | Optional. Text to synthesize when `tts` is true. |

### Text-to-Speech

| Method | Path | Content-Type | Description |
|--------|------|--------------|-------------|
| `POST` | `/api/v1/tts` | `application/json` | Text in, WAV audio out |

**Request:**

```bash
curl -X POST http://localhost:8080/api/v1/tts \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello from NeuNuc Voice"}' \
  --output response.wav
```

**Response:** Binary WAV audio (`audio/wav`).

## WebSocket Stream

| Protocol | Path | Description |
|----------|------|-------------|
| `WS` | `/api/v1/stream` | Real-time audio streaming |

**Client → Server messages:**

| Type | Payload | Description |
|------|---------|-------------|
| Binary | PCM float32 mono 16 kHz chunk | Raw audio for wakeword + STT |
| Text JSON | `{"action": "transcribe_buffer"}` | Trigger transcription of accumulated buffer |
| Text JSON | `{"action": "stop"}` | Close connection |

**Server → Client messages:**

| Event | Payload | Description |
|-------|---------|-------------|
| `wakeword` | `{"event": "wakeword"}` | Wakeword detected |
| `transcript` | `{"event": "transcript", "text": "..."}` | STT result |

**Example JavaScript client:**

```javascript
const ws = new WebSocket('ws://localhost:8080/api/v1/stream');
ws.binaryType = 'arraybuffer';

// Send audio chunks from microphone
navigator.mediaDevices.getUserMedia({ audio: true })
  .then(stream => {
    const ctx = new AudioContext({ sampleRate: 16000 });
    const source = ctx.createMediaStreamSource(stream);
    const processor = ctx.createScriptProcessor(4096, 1, 1);
    processor.onaudioprocess = e => {
      const float32 = e.inputBuffer.getChannelData(0);
      ws.send(float32.buffer);
    };
    source.connect(processor);
    processor.connect(ctx.destination);
  });

ws.onmessage = msg => {
  const data = JSON.parse(msg.data);
  if (data.event === 'wakeword') console.log('Wakeword!');
  if (data.event === 'transcript') console.log('Heard:', data.text);
};
```

## Home Assistant Integration

The REST API can be consumed by Home Assistant via RESTful command or custom integration:

```yaml
# configuration.yaml
rest_command:
  neunuc_transcribe:
    url: "http://YOUR_VOICE_HOST:8080/api/v1/transcribe"
    method: POST
    content_type: multipart/form-data
    payload: '{{ file }}'
```

For continuous listening, use the WebSocket endpoint with a small bridge script that feeds Home Assistant's `conversation.process` service.

## Security Notes

- The API server binds to `0.0.0.0` by default. In production, bind to `127.0.0.1` or place behind a reverse proxy with auth.
- No built-in authentication. Add API key headers or basic auth at the proxy layer.
- Audio data is processed in-memory and not logged to disk by default.
- The WebSocket endpoint accepts arbitrary binary data — validate chunk size and sample rate client-side.
