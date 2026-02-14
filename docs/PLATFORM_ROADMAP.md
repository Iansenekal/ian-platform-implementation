# Platform Roadmap

## Vision

Build a production-ready, enterprise platform spanning infrastructure (Proxmox), identity (Keycloak), document management (Nextcloud), search/knowledge graph, voice processing, workflow/eSign, automation, and Day-2 Ops — with **observability and security as foundational pillars**.

---

## Roadmap Structure

The roadmap is organized in phases aligned with the complete workflow (00–99):

### **Phase 0: Foundations (00–09)**
**Objective:** Set up operator tooling, repo conventions, and CI/CD baseline.

**Deliverables:**
- ✅ VSCode + dev container setup
- ✅ Repository skeleton (README, .env pattern, REPO_CONVENTIONS.md)
- ✅ Folder structure for evidence and configurations
- ✅ GitHub Actions CI (lint/build/test placeholders)
- ✅ .devcontainer with minimal tooling

**Guardrails:**
- No secrets in version control (`.env.example` only)
- All automation runs in CI; no manual deployments to prod

---

### **Phase 1: Observability + Security Foundations (01–09 + 30–39)**
**Objective:** Establish structured logging, audit events, metrics instrumentation, and secrets baseline before any workload deployment.

**Sub-phases:**

#### 1a. Audit Logging & Structured Events (03.20, 03.30, 50.30)
- Define audit event schema (who, what, when, where, why, result)
- Create `platform/observability/audit-events/` with:
  - Event schema (JSON/protobuf definitions)
  - Event catalog (all system events cross-referenced to workflow phase)
  - Retention policy templates (03.40, 50.30)
- Create `examples/audit-logging-integration.md` — runbook for services to emit audit events

**Why first:** Compliance (06.40 evidence pack), incident response, and access tracking depend on this.

#### 1b. Structured Logging (03.30, 50.20)
- Create `platform/observability/logging/` with:
  - Log level definitions (debug, info, warn, error, critical)
  - Structured JSON logging templates (language-agnostic examples)
  - Log field standardization (service, trace-id, user-id, action, result)
- Example: service logs `{"timestamp": "2026-02-13T10:00:00Z", "service": "auth", "level": "info", "action": "login", "user": "alice", "result": "success", "trace_id": "xyz", "duration_ms": 120}`

#### 1c. Metrics Instrumentation (50.10)
- Create `platform/observability/metrics/` with:
  - Prometheus scrape configuration templates
  - Common metric types (counters, gauges, histograms)
  - Service-level SLO guidelines (latency, availability, error rate)
- Create `examples/prometheus-integration.md` — how to expose `/metrics` endpoint

#### 1d. Secrets Baseline (03.20, 10.40)
- Create `platform/security/secrets-management/` with:
  - Secrets rotation policy (intervals, methods, audit)
  - Local dev `.env` pattern extensions (per service)
  - Service-to-service auth patterns (API keys, mTLS, JWT token validation)
- Create `deploy/secret-scanning.sh` — pre-commit hook to detect hardcoded secrets
- Create `docs/secrets-checklist.md` — baseline for all services

**Deliverables (Phase 1 end):**
- `platform/observability/` with audit, logging, metrics templates
- `platform/security/secrets-management/` with rotation + auth patterns
- Example integrations in `examples/`
- Pre-commit secret detection in CI

**Guardrails:**
- All services log to stdout (no file I/O); log aggregation handled by infra
- All services expose `/metrics` and `/health` endpoints
- No secrets in code or config files; all via `.env` or secret store

---

### **Phase 2: Reference Micro-Service (01–09 + 10–29 Pre-work)**
**Objective:** Create a runnable, instrumented reference service demonstrating observability + security integration.

**Deliverables:**
- Create `services/reference-app/` with:
  - Minimal HTTP server (language TBD: shell `nc`, Python, Go, Node.js)
  - Structured logging integration (audit + access logs)
  - Prometheus metrics exporter (request latency, error counts)
  - Auth token validation placeholder (for 10.40 integration)
  - Health check endpoint (`/health`, `/metrics`)
- Create `examples/reference-app-deployment.md` — how to run locally and in infra
- Update CI to build + test + scan reference app

**Why:** Template for all 60+ services to follow; validates observability + security stack before large deployments.

---

### **Phase 3: Infrastructure Scaffolds (10–29 Infrastructure)**
**Objective:** Create IaC templates and deployment patterns for Proxmox, networking, storage, VM hardening.

**Deliverables:**
- `infrastructure/proxmox/` with:
  - VM blueprint templates (CPU, RAM, disk, NIC specs per 81.100)
  - Network bridge + VLAN config templates (81.40, 81.50)
  - Storage plan decision trees (LVM vs ZFS, 81.70)
  - Hardening scripts (SSH, UFW, unattended upgrades, 81.150)
- `infrastructure/vm-provisioning/` with:
  - Cloud-init or kickstart templates for Ubuntu 24.04
  - SSH key distribution automation (81.160)
  - Post-install verification checklist automation (81.190)
- `infrastructure/monitoring/` with:
  - Node exporter setup (for Prometheus scraping, 50.10)
  - Audit logging forwarding (syslog or file shipping, 03.30, 50.30)

**Guardrails:**
- All hardening runs through infra automation; no manual steps
- All VMs have observability agents (node exporter, audit forwarding) pre-built
- All secrets (SSH keys, certs) stored separately from IaC

---

### **Phase 4: Identity Foundation (31–35 Identity Provider)**
**Objective:** Deploy Keycloak with LDAP/AD integration, MFA, RBAC mapping.

**Deliverables:**
- `infrastructure/keycloak/` with:
  - Keycloak deployment templates (container or systemd)
  - Database schema (PostgreSQL)
  - TLS config (internal CA, 20.20)
  - LDAPS integration for AD (11.40) or local user setup (11.50)
  - MFA policy (TOTP, WebAuthn, recovery codes, 11.60, 04.70)
  - Group-to-role mapping (RBAC baseline, 11.70, 04.40)
- `platform/security/rbac/` with:
  - Role hierarchy and permissions model
  - Group naming convention (21.36)
  - Permission inheritance logic
- `examples/keycloak-integration.md` — how services validate tokens (10.40)

**Guardrails:**
- Keycloak logs audit events (user login, group changes, policy updates, 03.30)
- All admin actions logged and queryable
- MFA enforced for all non-service accounts

---

### **Phase 5: API Gateway + Backend (36–39 Gateway)**
**Objective:** Deploy ingress gateway for UI SSO flow and backend API auth validation.

**Deliverables:**
- `infrastructure/gateway/` with:
  - Reverse proxy config (Nginx, Envoy, or HAProxy)
  - OAuth2/OIDC middleware (proxy auth to Keycloak, 37)
  - Auth token validation for backend services (10.40, 10.50)
  - Health check + watchdog (10.80)
- `platform/security/gateway-policies/` with:
  - Rate limiting rules
  - TLS/mTLS configuration
  - RBAC authorization checks before forwarding
- Metrics + audit logging from gateway (50.10, 03.30)

---

### **Phase 6: Document Management (40–45 Nextcloud + Search)**
**Objective:** Deploy Nextcloud with auth, permissions, audit logging, and search indexing.

**Deliverables:**
- `infrastructure/nextcloud/` with:
  - Nextcloud container or systemd deployment
  - Database + object storage (S3-compatible or local filesystem)
  - SSO auth (Keycloak OAuth2 provider, 21.30, 04.60)
  - Permission inheritance model (21.35, 21.37)
  - Audit logging hooks (21.45)
- `infrastructure/search-graph/` with:
  - Elasticsearch or search index templates (30.10)
  - Document connector (crawl Nextcloud, 30.10)
  - ACL + permission inheritance in search results (30.15)
  - Knowledge graph linking (30.90, 63)
- Metrics + audit forwarding (50.30, 60.60)

**Guardrails:**
- All document access logged (who, when, action)
- Search results filtered by user permissions in real-time

---

### **Phase 7: Voice + Transcription (60–63 Voice)**
**Objective:** Integrate voice ingestion, storage, retention, and search indexing.

**Deliverables:**
- `services/voice-ingestion-service/` with:
  - Audio upload API
  - Ollama integration (LLM inference for transcription, 82.40, 82.50)
  - Storage model (Nextcloud folders per 60.30)
  - RBAC checks (60.40)
  - Audit logging (60.60)
- `infrastructure/ollama-gpu/` with:
  - GPU VM provisioning (82.00–82.80)
  - Ollama model allowlist enforcement (82.50)
  - LAN-only binding + UFW rules (82.60)
- Voice transcript indexing into search graph (30.90, 60.70)

---

### **Phase 8: Workflow + eSign (70–75 Workflow)**
**Objective:** Implement document approval chains, signature validation, audit trails.

**Deliverables:**
- `services/workflow-engine/` with:
  - Approval chain model (70.10, 70.11)
  - Signature standards + verification (70.30, 70.40)
  - Document versioning + hashing (70.40)
  - Audit trail + evidence pack generation (70.50, 06.40)
- `services/notification-service/` with:
  - Email notifications (LAN-only mail, 71.10)
  - Actionable approval/reject links (71.15, security tokens)
  - Mail audit logging (71.40)
  - Mail evidence retention (71.50)
- Integration with search graph and Nextcloud

---

### **Phase 9: Automation (76–77 Optional)**
**Objective:** Deploy n8n or Windmill for workflow automation (optional, if enabled).

**Deliverables:**
- `infrastructure/automation/` with:
  - n8n or Windmill deployment templates
  - SSO + MFA policy (40.20, 41.20)
  - Secrets management (40.30, 41.30)
  - Backup / restore (40.50, 41.50)
- Integration with workflow engine, Nextcloud, and identity

---

### **Phase 10: Monitoring + Observability Stack (80–82)**
**Objective:** Deploy Prometheus + Grafana for metrics, alerting, and custom dashboards.

**Deliverables:**
- `infrastructure/prometheus/` with:
  - Prometheus server + scrape config (50.10)
  - Service discovery (auto-register new services)
  - Retention policy (aligned with audit requirements)
- `infrastructure/grafana/` with:
  - Grafana server + dashboards (50.20)
  - Workflow + transcription + eSign metrics dashboards (50.50)
  - Alert rules (SLO violations, security events)
- Audit event dashboard linking to workflow events (50.30, 03.30)

---

### **Phase 11: Backup, DR, Compliance (90–99)**
**Objective:** Implement backup, restore, and compliance evidence preservation.

**Deliverables:**
- `infrastructure/backup/` with:
  - Backup scope + schedules (06.00, 06.10)
  - Backup exclusions (secrets, logs)
  - Restore procedure automation + testing (06.20)
- `infrastructure/dr/` with:
  - DR runbook automation (06.30)
  - Failover procedures (documented + tested)
  - RTO/RPO SLOs
- `deploy/compliance-evidence-pack.sh` with:
  - Automated evidence collection (06.40)
  - Screenshots, logs, audit trails
  - Compliance report generation
- Day-2 Ops runbooks (05.00–05.30):
  - Start/stop procedures
  - Upgrade runbooks
  - Log review dashboards
  - Incident response playbooks

---

## Implementation Order (Recommended)

1. **Phase 1 (Observability + Security)** — Audit, logging, metrics, secrets baseline (Week 1–2)
2. **Phase 2 (Reference Service)** — Validate observability + security stack (Week 2–3)
3. **Phase 3 (Infrastructure Scaffolds)** — Proxmox, networking, storage, VM hardening (Week 3–6)
4. **Phase 4 (Identity)** — Keycloak, LDAP, MFA, RBAC (Week 6–8)
5. **Phase 5 (Gateway)** — API gateway, auth, token validation (Week 8–9)
6. **Phase 6 (Document Management)** — Nextcloud, search + graph (Week 9–12)
7. **Phase 7 (Voice)** — Transcription, Ollama, indexing (Week 12–14)
8. **Phase 8 (Workflow)** — Approvals, eSign, audit trails (Week 14–18)
9. **Phase 9 (Automation)** — n8n or Windmill (Week 18–20, optional)
10. **Phase 10 (Monitoring)** — Prometheus + Grafana (Week 20–22)
11. **Phase 11 (Backup + DR + Compliance)** — Finalize (Week 22–26)

---

## Guardrails (Cross-cutting)

- **Zero Trust:** All service-to-service calls require auth tokens (Keycloak)
- **Observability:** All services emit structured logs, metrics, and audit events
- **Secrets:** Never in code; always via `.env` or secret store
- **Compliance:** Audit events retained per policy (03.40, 50.30)
- **Security Scanning:** CI pre-commit hooks + SAST/DAST in CI (GitHub Actions)
- **Capacity Planning:** Regular reviews against load baselines (05.30 incident response)

---

## Tech Stack (Decisions Deferred)

All components are **technology-agnostic** unless the platform makes a specific choice:

- **Infrastructure:** Proxmox (given), others TBD
- **Container orchestration:** TBD (Kubernetes, Docker Swarm, or manual)
- **Service mesh:** TBD (Istio, Linkerd, or none)
- **Message queue:** TBD (RabbitMQ, Kafka, or synchronous)
- **Database:** TBD (PostgreSQL, MySQL, or other)
- **Search:** TBD (Elasticsearch, Milvus, or other)
- **Metrics:** Prometheus (assumed, can be swapped)

Each phase will refine tech choices as needed; roadmap remains agnostic.
