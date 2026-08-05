# Customer VC
Customer VC is the low-resource voice and video session workspace for NeuNuc. It enables encrypted 1:1 and group calls with minimal bandwidth and CPU usage.

Customer VC is designed for operators who need to talk to customers or teammates without leaving the NeuNuc ecosystem. It is "low-resource" by design: adaptive bitrate, aggressive codec selection, and WebRTC data channels for signaling. Calls can be peer-to-peer or relayed through TURN servers.

**Location:** `apps/customer-vc/`

Stack:
- WebRTC for media transport
- Custom signaling over WebSocket
- STUN/TURN for NAT traversal
- End-to-end encryption via DTLS-SRTP

```powershell
cd apps/customer-vc
pnpm run dev
pnpm run build
```

## Session Management

A session is a single call or meeting with a unique ID, participant list, timestamps, and an optional recording flag. Sessions are ephemeral: metadata is stored, but media is not retained unless recording is explicitly enabled.

- **Storage:** Runtime config or Metasystem graph (configurable)
- **Retention:** Metadata 30 days, recordings 7 days (if enabled)
- **Encryption:** DTLS-SRTP for media, TLS for signaling

```javascript
// Create a session
const session = await vc.createSession({
  type: "1:1",
  participants: ["user-a", "user-b"],
  recording: false,
  max_duration: "1h"
});
```

## Signaling

Signaling is how peers discover each other and negotiate media parameters. Customer VC uses a custom WebSocket protocol over the runtime's surface bridge.

- **Protocol:** JSON messages over WebSocket
- **Server:** `apps/neunuc-runtime/surface/server.js` (shared with runtime)
- **Messages:** `offer`, `answer`, `ice-candidate`, `join`, `leave`, `status`

```javascript
// Signaling message format
{
  type: "offer",
  session_id: "uuid",
  from: "user-a",
  to: "user-b",
  sdp: "v=0\r\no=- ..."
}
```

## Bandwidth Adaptation

Customer VC monitors network conditions in real time and adjusts bitrate, resolution, and frame rate. It prioritizes audio over video when bandwidth is constrained.

- **Algorithm:** Google Congestion Control (GCC) for WebRTC
- **Thresholds:** Configurable in `config/vc.yaml`
- **Fallback:** Audio-only mode when bandwidth < 128 kbps

```yaml
# config/vc.yaml
bandwidth:
  min_audio: 32      # kbps
  min_video: 128     # kbps
  max_video: 4000    # kbps
  adaptation_interval: 2s
```

## Power Policy

The power policy governs when Customer VC can activate the camera, microphone, or screen capture. It prevents accidental activation and respects system-level permissions.

- **Policy file:** `power-policy.mjs`
- **Checks:** User consent, system permission, battery level, thermal state

```javascript
// power-policy.mjs
export function canActivateMedia(context) {
  return context.consent === true &&
         context.systemPermission === "granted" &&
         context.battery > 0.15;
}
```
