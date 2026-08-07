# Trust & Security

NeuNuc is built on a simple principle: **your data stays yours**. The system defaults to zero external connectivity. Every integration is gated. Every request is traced.

---

## Security model

### Two-layer defense

**Gate** — Network-level enforcement. Every request hits the gate first. Unknown routes return `403`. Rate-limited clients return `429`. Only exact `(method, path)` pairs in the route table pass through.

**Rules** — Payload-level policy. After the gate, write operations are validated against an ordered rule set. First match wins. Custom rules can be injected at runtime without restarting.

### Default-deny trust boundary

```json
{
  "trustBoundary": {
    "collectUserData": false,
    "analyticsEnabled": false,
    "paymentEnabled": false,
    "leadCaptureEnabled": false,
    "discordEnabled": false,
    "turnstileEnabled": false
  }
}
```

Every flag defaults to `false`. No PII is collected. No telemetry is sent. No external API is called unless you explicitly enable it.

### Request tracing

Every gate check generates a 12-character request ID derived from IP, path, and nanosecond timestamp. The last 500 decisions are held in memory for inspection:

```python
from gateway import gate

for entry in gate.recent(n=10):
    print(entry["id"], entry["allowed"], entry["reason"])
```

### Rate limiting

Token-bucket per client IP. Defaults: 60 requests per minute sustained, burst capacity of 20. Tuned via environment variables before deployment.

---

## Encryption

| Layer | Implementation |
|-------|---------------|
| Transport | TLS 1.3 via Cloudflare or reverse proxy |
| At rest | Filesystem-level (OS-managed) |
| In transit | HTTPS / WSS for all external surfaces |

The runtime itself operates on `127.0.0.1` by default. Bind it to `0.0.0.0` only when placing it behind a TLS-terminating reverse proxy.

---

## Authentication

The runtime does not ship with built-in user authentication. Access control is handled at the infrastructure layer:

- **Local development**: `127.0.0.1` binding prevents external access
- **Production**: Place behind nginx, Cloudflare, or API gateway with JWT or mTLS
- **API keys**: Add middleware in `runtime/surface.py` if exposing to the internet

---

## Vulnerability response

| Severity | Response time | Action |
|----------|--------------|--------|
| Critical | 24 hours | Patch released, advisory published |
| High | 72 hours | Patch released, advisory published |
| Medium | 7 days | Patch in next scheduled release |
| Low | Next release | Addressed in backlog |

Report security issues to `security@neunuc.com`. GPG key available on request.

---

## Compliance roadmap

| Standard | Status | Target |
|----------|--------|--------|
| SOC 2 Type II | Planned | Q2 2026 |
| FedRAMP Moderate | In planning | Q4 2026 |
| NIST 800-53 | Aligned | Current |
| ISO 27001 | Planned | Q3 2026 |
| Section 508 / WCAG 2.1 AA | In progress | Q1 2026 |

See [Compliance](compliance-security.md) for detailed control mappings and audit artifacts.
