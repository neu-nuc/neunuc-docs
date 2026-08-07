# Procurement Readiness

NeuNuc is structured for rapid procurement by federal agencies, enterprises, and regulated industries. This page contains the information typically required during vendor evaluation, security review, and contract negotiation.

---

## Company information

| Field | Detail |
|-------|--------|
| Legal name | NeuNuc Systems LLC |
| DUNS | Available on request |
| CAGE code | Available on request |
| NAICS | 511210 (Software Publishers), 541511 (Custom Programming) |
| Business type | Small business, self-certified |
| Ownership | Privately held |
| Year founded | 2024 |
| HQ | United States |

---

## Product information

### Licensing

NeuNuc is distributed under a proprietary license. Source code is available to customers under NDA for security review.

| Tier | Description | Price |
|------|-------------|-------|
| **Community** | Self-hosted, single runtime, no support | Free |
| **Professional** | Single organization, email support, quarterly updates | $2,000 / year |
| **Enterprise** | Unlimited runtimes, SLA, dedicated support, FedRAMP path | Custom |

### Deployment models

| Model | Infrastructure | Data residency | Best for |
|-------|---------------|----------------|----------|
| On-premises | Customer hardware | Customer-controlled | Classified, air-gapped |
| Private cloud | Customer AWS/Azure/GCP account | Customer-controlled | Regulated industries |
| Managed | NeuNuc-managed Cloudflare / AWS | US-only option available | Rapid deployment |

---

## Security & compliance

| Certification | Status | Target date |
|---------------|--------|-------------|
| SOC 2 Type II | In progress | Q2 2026 |
| FedRAMP Moderate | In planning | Q4 2026 |
| ISO 27001 | In progress | Q3 2026 |
| NIST 800-53 | Aligned | Current |
| WCAG 2.1 AA | In progress | Q1 2026 |

Detailed control mappings and audit artifacts: [Security Posture](compliance-security.md)

---

## Technical specifications

### Performance

| Metric | Value | Conditions |
|--------|-------|------------|
| Cold boot | < 1 second | Python runtime, SSD |
| Inference latency | 50-500 ms | Depends on model size and hardware |
| Throughput | 10-100 req/s | CPU-bound; scales linearly with GPU |
| Concurrent sessions | 1,000+ | WebSocket connections |

### Supported platforms

| Platform | Support level |
|----------|--------------|
| Windows 10/11 | Primary |
| Windows Server 2019+ | Primary |
| Linux (Ubuntu 22.04+) | Supported |
| macOS (Apple Silicon) | Experimental |

### Integration requirements

- **Python**: 3.10+
- **Node.js**: 18+
- **pnpm**: 9.15.4+
- **GPU**: Optional (CUDA, DirectML, Metal)

---

## Support

| Tier | Channels | Response time | Hours |
|------|----------|--------------|-------|
| Community | GitHub Issues | Best effort | — |
| Professional | Email | 48 hours | Business hours US ET |
| Enterprise | Email + Slack + Phone | 4 hours | 24/7 |

---

## Contract terms

### Standard terms

- **Payment**: Net 30
- **Termination**: 30 days written notice
- **SLA**: 99.9% uptime for Enterprise tier
- **Data deletion**: 30 days after contract termination
- **Liability cap**: Annual subscription fee

### Negotiable terms

- Custom SLA (up to 99.99%)
- Dedicated infrastructure
- Custom compliance scope (additional certifications)
- Source code escrow
- Professional services (integration, training)

---

## Evaluation process

1. **Technical review** — Architecture docs, API reference, security posture
2. **Security review** — SBOM, penetration test results, control mappings
3. **Pilot deployment** — 30-day evaluation on customer hardware
4. **Contract negotiation** — Terms, SLA, support scope
5. **Production deployment** — Full rollout with monitoring

To start an evaluation, contact `sales@neunuc.com` with your use case, scale requirements, and compliance needs.

---

## References

Customer references available under NDA for qualified evaluators.
