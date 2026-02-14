# Platform Audit Against Mandatory Standards

**Audit Date:** 2026-02-13  
**Repository:** ian-platform-implementation  
**Scope:** Phase 0–1 (Repo Hygiene + Observability/Security Foundations)

---

## SECTION 1 — REPOSITORY HYGIENE & BASELINE

| Check | Status | Evidence |
|-------|--------|----------|
| README.md explaining purpose, scope, local-only intent | ✅ PASS | [README.md](../README.md) covers purpose, setup, dev container usage |
| .gitignore includes secrets (.env, *.key, *.pem, *.crt) | ✅ PASS | [.gitignore](../.gitignore) excludes .env*, *.key, *.pem, .secrets |
| .devcontainer/ directory present and valid | ✅ PASS | [.devcontainer/](../.devcontainer/) exists with devcontainer.json |
| devcontainer.json exists and builds successfully | ✅ PASS | Minimal image (mcr.microsoft.com/vscode/devcontainers/base:ubuntu) |
| No secrets committed to Git history | ✅ PASS | .env.example only (no real secrets) |

**Summary:** ✅ **PASS** — Repository hygiene baseline is solid.

---

## SECTION 2 — SECRETS STANDARD (03.20)

| Check | Status | Evidence |
|-------|--------|----------|
| No secrets stored in repository | ✅ PASS | .env*.gitignore, .env.example is placeholder only |
| .env excluded via .gitignore | ✅ PASS | .gitignore line: `.env` and `.env.*` |
| Secrets injected at runtime only | ⚠️ PARTIAL | Pattern described in README; no implementation example yet |
| Secrets never logged | ⚠️ PARTIAL | No logging standard yet (see Section 3) |
| Rotation strategy possible without image rebuild | ⚠️ PARTIAL | .env pattern supports this; no documented procedure |
| Secrets pattern documented | ⚠️ PARTIAL | README mentions env vars; no detailed runbook |
| .env.example exists (no real values) | ✅ PASS | [.env.example](../.env.example) with placeholders |

**Summary:** ⚠️ **PARTIAL** — Baseline exists; documentation and rotation runbook needed.

**Corrective Actions (Priority: Medium):**
- [ ] Create `docs/SECRETS_MANAGEMENT.md` with runtime injection patterns (Docker secrets, env vars, mounted files)
- [ ] Create `docs/SECRETS_ROTATION_PROCEDURE.md` with timelines and verification steps
- [ ] Add pre-commit hook example in `tools/pre-commit-secrets-check.sh`

---

## SECTION 3 — AUDIT LOGGING (03.30)

| Check | Status | Evidence |
|-------|--------|----------|
| Authentication events (login, MFA, session) | ❌ MISSING | No audit schema defined |
| Authorization events (role/group, access denied) | ❌ MISSING | No audit schema defined |
| Admin actions (config, deployment, privilege escalation) | ❌ MISSING | No audit schema defined |
| Data access metadata (file/API calls, no payloads) | ❌ MISSING | No audit schema defined |
| Time sync enforced (Africa/Johannesburg TZ) | ❌ MISSING | No timezone enforcement in platform |
| Log format (timestamp, actor, source, action, result) | ❌ MISSING | No schema defined |
| LAN-only logging (no cloud shipping) | ⚠️ PARTIAL | Intended by design (dev container) but not documented |

**Summary:** ❌ **MISSING** — Audit logging schema and event definitions required.

**Corrective Actions (Priority: CRITICAL):**
- [ ] Create `platform/observability/audit-events/EVENT_SCHEMA.md` with:
  - Standard fields: timestamp, source_system, event_type, actor_id, source_ip, target_resource, action, outcome
  - Example events (auth, authz, admin, data access)
  - Timezone requirement: Africa/Johannesburg (UTC+2)
- [ ] Create `platform/observability/audit-events/AUDIT_EVENT_CATALOG.md` listing all event types
- [ ] Create `examples/audit-logging-integration.md` with JSON/structured log format examples

---

## SECTION 4 — AUDIT EVENT MODEL (50.30)

| Check | Status | Evidence |
|-------|--------|----------|
| Standard event fields (timestamp, source_system, event_type, etc.) | ❌ MISSING | No schema defined |
| Correlation/request IDs for tracing | ❌ MISSING | No tracing pattern defined |
| Metadata-only logging (no file contents, no PII payloads) | ⚠️ PARTIAL | Intended but not documented or validated |

**Summary:** ❌ **MISSING** — Event model schema required, including correlation ID pattern.

**Corrective Actions (Priority: CRITICAL):**
- [ ] Create `platform/observability/audit-events/CORRELATION_ID_PATTERN.md` specifying:
  - Request ID generation (UUID, timestamp-based, etc.)
  - Propagation across service calls (HTTP headers, logging context)
  - Example: `X-Request-ID`, `X-Trace-ID` headers
- [ ] Create `platform/observability/audit-events/EVENT_EXAMPLES.json` with realistic events

---

## SECTION 5 — RETENTION & PURGE (03.40 / 50.30)

| Check | Status | Evidence |
|-------|--------|----------|
| Retention rules defined | ❌ MISSING | No retention policy |
| Enforceable by config/automation | ❌ MISSING | No retention mechanism |
| Auth & admin logs: 180–365 days | ❌ MISSING | No policy |
| File/share metadata: ~180 days | ❌ MISSING | No policy |
| Automation/system logs: 90–365 days | ❌ MISSING | No policy |
| Purge capability (scripts, cron, etc.) | ❌ MISSING | No tooling |
| Legal hold / exception process | ❌ MISSING | No documented procedure |

**Summary:** ❌ **MISSING** — Comprehensive retention and purge strategy required.

**Corrective Actions (Priority: HIGH):**
- [ ] Create `platform/observability/audit-events/RETENTION_POLICY.md` with:
  - Auth & admin events: 365 days (POPIA compliance)
  - File/share access metadata: 180 days
  - System/automation logs: 90 days (configurable)
  - Legal hold process and exceptions
- [ ] Create `deploy/audit-log-purge.sh` with dry-run and enforcement options
- [ ] Create `docs/LEGAL_HOLD_PROCEDURE.md` for compliance exceptions

---

## SECTION 6 — DEV CONTAINER & LOCAL DEV

| Check | Status | Evidence |
|-------|--------|----------|
| Dev Container builds successfully | ✅ PASS | [.devcontainer/devcontainer.json](../.devcontainer/devcontainer.json) valid |
| Git works inside container | ✅ PASS | Base image includes Git; setup script verifies it |
| Docker CLI available if required | ✅ PASS | tools/setup-dev.sh installs docker.io (optional) |
| Non-root default user inside container | ✅ PASS | remoteUser: vscode |
| Workspace path is /workspaces/<repo> | ✅ PASS | Standard VS Code dev container layout |

**Summary:** ✅ **PASS** — Dev container baseline is functional.

**Corrective Actions (Optional):**
- [ ] Update [.devcontainer/README.md](../.devcontainer/README.md) with build/troubleshooting steps
- [ ] Add Makefile stub in root with `make dev-build`, `make dev-shell` targets

---

## SECTION 7 — GAP SUMMARY

### Overall Status by Section

| Section | Status | Priority | Impact |
|---------|--------|----------|--------|
| 1. Repository Hygiene | ✅ PASS | — | Foundational baseline achieved |
| 2. Secrets Standard | ⚠️ PARTIAL | Medium | Pattern exists; rotation procedure needed |
| 3. Audit Logging | ❌ MISSING | **CRITICAL** | Cannot begin Phase 1a until schema defined |
| 4. Audit Event Model | ❌ MISSING | **CRITICAL** | Blocks all service development (correlation IDs) |
| 5. Retention & Purge | ❌ MISSING | HIGH | POPIA compliance blocker |
| 6. Dev Container | ✅ PASS | — | Ready for development |

---

### Prioritized TODO List (Highest Risk First)

#### 🔴 CRITICAL (Blocks Phase 1 + all downstream):

1. **Define Audit Event Schema** (Section 3)
   - Create core event fields and types
   - Time zone enforcement (Africa/Johannesburg)
   - Metadata-only logging guardrails
   - Deliverable: `platform/observability/audit-events/EVENT_SCHEMA.md`

2. **Define Correlation ID Pattern** (Section 4)
   - Request ID generation and propagation
   - Tracing across service boundaries
   - Deliverable: `platform/observability/audit-events/CORRELATION_ID_PATTERN.md`

3. **Define Retention Policy** (Section 5)
   - Auth/admin: 365 days
   - File/share: 180 days
   - System: 90 days
   - Legal hold exception process
   - Deliverable: `platform/observability/audit-events/RETENTION_POLICY.md`

#### 🟡 HIGH (Blocks service rollout):

4. **Create Audit Event Catalog** (Section 3)
   - All auth, authz, admin, data access events
   - Deliverable: `platform/observability/audit-events/AUDIT_EVENT_CATALOG.md`

5. **Create Retention Automation** (Section 5)
   - Purge/delete script with dry-run
   - Deliverable: `deploy/audit-log-purge.sh`

6. **Create Secrets Rotation Runbook** (Section 2)
   - Timeline, method, verification
   - Deliverable: `docs/SECRETS_ROTATION_PROCEDURE.md`

#### 🟢 MEDIUM (Improve dev experience):

7. **Secrets Injection Patterns** (Section 2)
   - Docker secrets, env vars, mounted files examples
   - Deliverable: `docs/SECRETS_MANAGEMENT.md`

8. **Pre-commit Secrets Detection** (Section 2)
   - Shell script to detect hardcoded secrets
   - Deliverable: `tools/pre-commit-secrets-check.sh`

9. **Audit Event Examples** (Section 4)
   - Realistic JSON payloads for all event types
   - Deliverable: `platform/observability/audit-events/EVENT_EXAMPLES.json`

10. **Dev Container Documentation** (Section 6)
    - Build, troubleshoot, extend
    - Deliverable: Enhanced `.devcontainer/README.md`

---

### Next Step

**Recommended:** Begin with CRITICAL items 1–3 (Sections 3–5).

These are prerequisites for:
- Phase 1a (Audit Logging) implementation
- Phase 1b–1d (Logging, Metrics, Secrets) that depend on event schema
- All downstream service development (phases 2–11)

**Sequencing:**
1. Define Event Schema + Catalog (1 day)
2. Define Correlation ID Pattern (0.5 day)
3. Define Retention Policy (0.5 day)
4. Create example implementations (1 day)

**Then proceed to:** Phase 1a reference implementation + Phase 2 (Reference Service).

---

## Compliance Alignment

| Standard | Status | Coverage |
|----------|--------|----------|
| POPIA (Protection of Personal Information Act) | ⚠️ PARTIAL | Audit baseline ready; retention policy required for full compliance |
| Data Protection (Audit Trail Retention) | ❌ MISSING | Retention policy needed |
| LAN-only Architecture | ✅ PASS | By design (no cloud shipping) |
| Ubuntu 24.04 Hardening | ⚠️ PARTIAL | Baseline ready; VM hardening scripts needed (Phase 3) |

---

**Audit Sign-off:** Ready to proceed with Phase 1 once CRITICAL items 1–3 are delivered.
