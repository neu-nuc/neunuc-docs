# Customer VC Pilot
The Customer VC Pilot (`apps/customer-vc-pilot/`) is the authenticated control-plane service for the next Customer VC production slice. It is not the bare-metal custody runtime. It keeps account data, HTTP/JSON, room orchestration, media-provider calls, CRM projection, and recording-worker orchestration outside `nuc-custody`.

The custody boundary may later receive only canonical commands, consent evidence, opaque ciphertext references, digests, authorization state, and signed audit records. This pilot proves the control-plane architecture before it is hardened for production.

- **Location:** `apps/customer-vc-pilot/`
- **Stack:** Node.js, vanilla JS (browser UI)
- **Port:** `4190` (development)
- **Entry:** `src/server.mjs`
- **Boot:** `npm run dev` or `NODE_ENV=production node src/server.mjs`

```bash
cd apps/customer-vc-pilot
npm test
npm run dev
```

Open `http://127.0.0.1:4190`. The server prints a one-time bootstrap token. Use that token in the owner setup form, save the TOTP secret and recovery codes, activate MFA, and sign in.

---

## Security model

The pilot uses a layered security model:

| Layer | Mechanism |
|---|---|
| Owner bootstrap | Terminal-only one-time token |
| Passwords | scrypt hashing |
| MFA | TOTP + one-use recovery codes |
| Sessions | Fifteen-minute signed sessions |
| Invitations | One-time, expiring room invitations |
| Recording | Blocked until all participants consent |
| Audit | Signed append-only Ed25519 event ledger with digest chaining |
| Mutation safety | Filesystem sync before in-memory mutation |
| CRM projection | HMAC-signed webhook after evidence commit |

---

## Room controls

The pilot supports full room lifecycle management:

- **Protected rooms** and breakout rooms
- **Waiting-room** admission, mute, remove, close, emergency stop
- **Provider-neutral SFU** room and participant-token adapter
- **Recording jobs** blocked until every admitted participant has current recording consent
- **Generic server-side recording-worker** adapter returning opaque ciphertext references

---

## Production environment

Production fails closed unless all of the following are supplied:

```text
NODE_ENV=production
PILOT_DATA_DIR=/durable/private/path
SESSION_SIGNING_KEY=<high-entropy secret>
INVITE_SIGNING_KEY=<different high-entropy secret>
EVENT_SIGNING_PRIVATE_KEY_B64=<base64 PKCS8 Ed25519 private key PEM>
SFU_ADAPTER_URL=https://internal-sfu-adapter.example
SFU_ADAPTER_TOKEN=<secret>
RECORDING_WORKER_URL=https://internal-recording-worker.example
RECORDING_WORKER_TOKEN=<secret>
CRM_WEBHOOK_URL=https://internal-crm-adapter.example/events
CRM_WEBHOOK_SECRET=<secret>
```

Production startup is rejected when no owner exists, when signing/session keys are absent, or when no SFU/recording adapter is configured.

---

## Adapter contracts

### SFU adapter

- `POST /rooms`
- `POST /join-token`
- `POST /commands/mute`
- `POST /commands/remove`
- `POST /commands/close`

### Recording worker

- `POST /start`
- `POST /stop`

The recording worker response must include `jobId` and an opaque `ciphertextRef`. Plaintext recordings and decryption keys remain outside the custody runtime.

### CRM webhook

Each committed CRM projection is sent with:

```text
X-Customer-VC-Signature: sha256=<HMAC of stable event JSON>
```

CRM mutation must reject events with an invalid signature or a repeated event ID.

---

## Remaining infrastructure

This repository contains the control-plane pilot only. Real media still requires:

- SFU deployment
- Recording worker
- Encrypted object store
- Production key authority
- Durable database/event sink
- NUC1 control-plane bridge into the bare-metal custody runtime
