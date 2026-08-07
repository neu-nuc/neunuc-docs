# Data Residency & Sovereignty

NeuNuc defaults to local execution. Data never leaves your hardware unless you explicitly configure an external destination. This document defines data handling policies for organizations with residency, sovereignty, or classification requirements.

---

## Default posture

By default, NeuNuc operates in **air-gapped mode**:

- Inference runs locally on CPU or GPU
- State and memory are stored in flat JSON files on disk
- No network calls are made
- No telemetry is transmitted
- No logs leave the host

This satisfies the strictest data residency requirements out of the box.

---

## Data classification

| Classification | Storage | Transit | Retention |
|----------------|---------|---------|-----------|
| Public | Flat JSON | TLS 1.3 | Configurable |
| Internal | Flat JSON | TLS 1.3 | Configurable |
| Confidential | Flat JSON + OS encryption | TLS 1.3 | Configurable |
| Restricted | Not supported in current release | — | — |

Restricted data (classified government data) requires FedRAMP authorization, which is targeted for Q4 2026.

---

## Residency controls

### Geographic boundaries

When deploying to Cloudflare Pages or Workers, data stays within the configured region:

```json
{
  "deployment": {
    "region": "us-east",
    "dataResidency": "US"
  }
}
```

Available regions: `us-east`, `us-west`, `eu-west`, `auto`.

### Data localization

The runtime can be configured to reject requests from non-US IP ranges:

```python
# gateway/gate.py — custom rule
rules.add(
    name="block_non_us_ip",
    match_fn=lambda p: not is_us_ip(p.get("client_ip")),
    allow=False,
    reason="non-US origin",
    index=1
)
```

### Cross-border transfer

No data is transferred across borders in the default configuration. If you enable integrations (Stripe, Discord, analytics), data transfer is governed by the third-party's DPA:

| Integration | Data type | Destination | DPA available |
|-------------|-----------|-------------|---------------|
| Stripe | Payment tokens | Stripe US | Yes |
| Discord | Message content | Discord US | Yes |
| Cloudflare Analytics | Page views | Cloudflare US | Yes |
| Plausible | Page views | EU (self-hosted option) | Yes |

---

## Retention and deletion

### Automatic expiration

Memory entries support TTL:

```python
store.mem_store("session_context", data, ttl=3600)  # 1 hour
```

Expired entries are purged on the next read or background flush.

### Manual deletion

```python
store.mem_delete("session_context")
store.state_delete("user_pref_theme")
```

### Full wipe

```powershell
# Stop runtime
# Delete data directories
Remove-Item -Recurse apps/neunuc-runtime/data/state
Remove-Item -Recurse apps/neunuc-runtime/data/memory
```

### Audit trail

Deletion events are logged:

```json
{
  "ts": 1716123000,
  "level": "info",
  "logger": "neunuc.store",
  "event": "mem_delete",
  "key": "session_context",
  "client_ip": "127.0.0.1"
}
```

---

## Backup and recovery

### State backup

Flat JSON files can be backed up with standard tools:

```powershell
# Daily backup
Compress-Archive -Path apps/neunuc-runtime/data -DestinationPath backup-$(Get-Date -Format yyyyMMdd).zip
```

### Memory export

```python
import json
from runtime import store

with open("memory-export.json", "w") as f:
    json.dump(store.mem_all(), f, indent=2)
```

### Recovery time objective (RTO)

| Component | RTO | Method |
|-----------|-----|--------|
| Runtime | 5 minutes | Restart `main.py` |
| State | 15 minutes | Restore from JSON backup |
| Memory | 30 minutes | Rebuild from logs or re-ingest |

---

## Sovereignty statement

NeuNuc does not rely on proprietary cloud AI APIs for core inference. All model execution happens on hardware you control. You are not subject to:

- Vendor lock-in on model hosting
- Cross-border data transfer for inference
- Third-party training on your data
- Terms of service that claim rights to your inputs

For organizations that require complete sovereignty, NeuNuc can operate entirely offline.
