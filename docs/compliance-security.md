# Security Posture

NeuNuc's security posture is designed for organizations that cannot afford to leak data. Every control defaults to closed. Every decision is logged. Every component is inspectable.

---

## Control framework

Controls are mapped to NIST 800-53 Rev 5. Where a control is not yet fully implemented, the gap is documented with a remediation date.

| Control | Family | Status | Evidence |
|---------|--------|--------|----------|
| AC-2 | Account Management | Implemented | `neunuc.config.json` trust boundary |
| AC-3 | Access Enforcement | Implemented | Gateway route table + rate limiting |
| AC-6 | Least Privilege | Implemented | Default-deny trust boundary |
| AU-3 | Content of Audit Records | Implemented | Structured JSON logs with req_id |
| AU-6 | Audit Review | Partial | Manual review; SIEM integration planned Q2 2026 |
| CM-2 | Baseline Configuration | Implemented | `neunuc.config.json` as single source of truth |
| CM-7 | Least Functionality | Implemented | Opt-in only; all features disabled by default |
| IA-2 | Identification and Authentication | Planned | JWT middleware template in `runtime/surface.py` |
| SC-8 | Transmission Confidentiality | Implemented | TLS 1.3 via Cloudflare / nginx |
| SC-28 | Protection at Rest | Partial | OS-level encryption; application-layer planned Q2 2026 |

---

## FedRAMP path

FedRAMP Moderate authorization is targeted for Q4 2026. The following prerequisites are in progress:

### Phase 1: Documentation (Current)

- [x] System Security Plan (SSP) draft
- [x] Control mappings to NIST 800-53 Rev 5
- [ ] Privacy Impact Assessment (PIA)
- [ ] e-Authentication Risk Assessment

### Phase 2: Technical implementation (Q2 2026)

- [ ] FIPS 140-2 validated encryption modules
- [ ] Continuous monitoring pipeline (SIEM)
- [ ] Vulnerability scanning integration
- [ ] Penetration testing (annual)

### Phase 3: Audit (Q3 2026)

- [ ] Third-party assessment organization (3PAO) engagement
- [ ] Security assessment report (SAR)
- [ ] Remediation of findings
- [ ] Authorization to Operate (ATO) submission

---

## Supply chain security

### Dependencies

Python and Node.js dependencies are pinned in `requirements.txt` and `package-lock.json`. No unpinned dependencies are allowed in production builds.

### SBOM

A Software Bill of Materials is generated on every release:

```powershell
cd apps/neunuc-runtime
pip install cyclonedx-bom
cyclonedx-py -r -o sbom.json
```

SBOMs are published with each GitHub release and retained for 7 years.

### Container scanning

Docker images are scanned with Trivy before deployment:

```bash
docker build -t neunuc:latest .
trivy image neunuc:latest
```

---

## Penetration testing

| Date | Scope | Findings | Status |
|------|-------|----------|--------|
| Planned Q2 2026 | Full runtime + surfaces | — | Scheduled |

Historical findings and remediations are published in the Security Advisory section of the repository.

---

## Security contacts

- **Reporting**: `security@neunuc.com`
- **GPG key**: Available on request
- **Response SLA**: 24 hours for critical, 72 hours for high
