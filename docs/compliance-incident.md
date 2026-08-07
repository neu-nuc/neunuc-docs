# Incident Response

NeuNuc's incident response plan defines roles, timelines, and communication patterns for security events. This plan aligns with NIST SP 800-61 Rev 2.

---

## Incident severity

| Level | Criteria | Response time | Examples |
|-------|----------|--------------|----------|
| **Critical** | Active exploitation, data breach, system compromise | 15 minutes | RCE in runtime, unauthorized data exfiltration |
| **High** | Potential vulnerability with exploit path | 1 hour | Auth bypass, privilege escalation |
| **Medium** | Security weakness without known exploit | 24 hours | Misconfigured CORS, information disclosure |
| **Low** | Hygiene issue | 7 days | Missing security headers, outdated dependency |

---

## Response phases

### 1. Detection

Detection sources:

- Gate trace anomalies (spike in denied requests)
- Health check failures
- SIEM alerts
- Manual reporting (`security@neunuc.com`)

### 2. Analysis

```powershell
# Check recent gate decisions for attack patterns
python -c "from gateway import gate; [print(e) for e in gate.recent(n=100) if not e['allowed']]"

# Review logs for the affected period
Select-String -Path logs/neunuc.log -Pattern "error|warning" | Select-Object -Last 50

# Verify trust boundary flags
python -c "import json; print(json.load(open('neunuc.config.json'))['trustBoundary'])"
```

### 3. Containment

Immediate actions:

- **Isolate runtime**: Stop `main.py` and revoke any exposed API tokens
- **Block IP ranges**: Add custom gate rules for malicious sources
- **Disable integrations**: Set all `trustBoundary` flags to `false`
- **Preserve evidence**: Copy logs before they rotate

```python
# Emergency shutdown
import os
os.kill(os.getpid(), 9)

# Block an IP
rules.add(
    name="emergency_block",
    match_fn=lambda p: p.get("client_ip") == "10.0.0.99",
    allow=False,
    reason="incident containment",
    index=0
)
```

### 4. Eradication

- Remove compromised credentials
- Patch vulnerable dependencies
- Rebuild containers from clean base images
- Verify SBOM against known-good baseline

### 5. Recovery

- Restart runtime with patched code
- Verify health checks pass
- Monitor gate traces for 24 hours post-recovery
- Re-enable integrations one at a time

### 6. Lessons learned

Post-incident review within 72 hours:

- Timeline reconstruction
- Root cause analysis
- Control gaps identified
- Remediation assigned

---

## Communication

| Audience | Channel | Timing |
|----------|---------|--------|
| Response team | Private Slack / Signal | Immediate |
| Customers | Email + status page | Within 4 hours (critical) |
| Regulators | As required by contract | Within 72 hours (if PII involved) |
| Public | Blog post + GitHub advisory | After containment |

---

## Contact tree

```text
Incident Commander (IC)
├── Technical Lead (TL)
│   ├── Runtime engineer
│   ├── Infrastructure engineer
│   └── Security analyst
├── Communications Lead (CL)
│   ├── Customer notifications
│   └── Regulatory filings
└── Legal Counsel (if PII involved)
```

---

## Playbooks

### RCE in runtime

1. Stop all runtime instances immediately
2. Preserve `logs/` and `data/` directories
3. Identify affected version from boot logs
4. Patch and redeploy
5. Notify customers if exploit evidence exists

### Data exfiltration

1. Determine scope from gate traces and logs
2. Identify egress path (API, WebSocket, file export)
3. Block affected tokens / IPs
4. Preserve evidence for law enforcement if required
5. Notify affected parties within regulatory timelines

### Denial of service

1. Enable rate limiting (if not already active)
2. Add IP-based gate rules
3. Scale up behind load balancer
4. Contact upstream provider for DDoS mitigation

---

## Testing

Incident response drills are conducted quarterly:

| Quarter | Scenario | Participants |
|---------|----------|--------------|
| Q1 | RCE in runtime | Engineering + Security |
| Q2 | Data exfiltration | Engineering + Legal |
| Q3 | Denial of service | Engineering + Ops |
| Q4 | Supply chain compromise | Engineering + Security + Legal |

Drill outcomes are documented and reviewed by leadership.
