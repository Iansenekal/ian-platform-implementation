# Implementation Backlog (00-99 Workflow)

Last Updated: 2026-02-17

## Board Columns
- `todo`: not started
- `doing`: in progress
- `blocked`: dependency/risk waiting
- `done`: complete with evidence

## Sprint A (Current) - Traceability + 10-29 Skeleton + Verification

### doing
- [ ] A5 Convert placeholder Proxmox/network/storage plans into executable IaC (networking/storage/VM gates plus 82.00 pointer profile artifacts added; host execution evidence pending)
- [ ] A6 Add SSH key distribution automation for VM provisioning (81.160 scripts/templates added; host execution evidence pending)
- [ ] A7 Add pre-phase go-live automated gate report generation (83.30 prebootstrap gate report script + template added; signed host execution evidence pending)
- [ ] A8 Add connectivity, DNS, and security smoke runners that execute against real VMs (83.00 end-to-end + 83.10 DNS + 83.20 security smoke runners added; host execution evidence pending)

### todo

### done
- [x] A0 Baseline CI/test harness established for reference app
- [x] A1 Create complete workflow traceability matrix (`docs/WORKFLOW_TRACEABILITY.md`)
- [x] A2 Build infrastructure skeleton for 10-29 under `infrastructure/`
- [x] A3 Add executable pre-phase verification scripts under `scripts/prephase/`
- [x] A4 Add tests for 10-29 artifacts and checks under `tests/infrastructure/`

## Sprint B (Current) - Keycloak + Gateway + Secrets/Audit Runtime Controls + CI

### doing
- [ ] B14 Add revocation/disabled-user token behavior checks in gateway smoke tests

### todo
- [ ] B15 Add nightly drift report for controls snapshot hashes

### blocked
- [ ] B9 AD/LDAPS integration requires customer directory details

### done
- [x] B1 Add Keycloak deployment scaffold (`infrastructure/keycloak/`)
- [x] B2 Add gateway deployment scaffold (`infrastructure/gateway/`)
- [x] B3 Add secrets management controls (`platform/security/secrets-management/`, `tools/pre-commit-secrets-check.sh`)
- [x] B4 Add runtime audit-event emission controls in `services/reference-app/app.py`
- [x] B5 Expand CI/Makefile quality gates for Sprint A and B checks
- [x] B6 Wire full OIDC SSO (gateway <-> keycloak) with token validation middleware
- [x] B7 Add keycloak realm bootstrap job and smoke tests
- [x] B8 Add config syntax checks for Prometheus and Nginx via CI tools
- [x] B10 Add gateway integration tests with authenticated/unauthenticated flows
- [x] B11 Add secrets rotation evidence automation in CI/release
- [x] B12 Add token signature validation tests against Keycloak JWKS
- [x] B13 Add release pipeline signing/attestation for compliance artifacts

## Wave 3 (Post-Sprint B): 31-45 Core Platform

### todo
- [ ] C1 Implement Keycloak Mode A (AD/LDAPS)
- [ ] C2 Finalize MFA + break-glass policy enforcement
- [ ] C3 Implement RBAC group-role mapping automation
- [ ] C4 Deploy Nextcloud and permission lifecycle controls
- [ ] C5 Deploy search/graph baseline + ACL inheritance

## Wave 4: 60-79 Voice/Workflow/Email

### todo
- [ ] D1 Voice ingestion service + transcript pipeline
- [ ] D2 Voice retention and audit events
- [ ] D3 Workflow engine + eSign verification model
- [ ] D4 Notification service + audit retention
- [ ] D5 Optional automation platform enablement (n8n/Windmill)

## Wave 5: 80-99 Monitoring/DR/Day-2/Final Gate

### todo
- [ ] E1 Full metrics dashboards (workflow/transcription/eSign)
- [ ] E2 Backup/restore automated tests and evidence
- [ ] E3 DR runbook + tabletop validation
- [ ] E4 Day-2 runbooks (start/stop/upgrades/log review/incident response)
- [ ] E5 Final security validation + GO/NO-GO pack

## Full 00-99 Pre-filled Checklist

### 00-09 Operator + Repo Setup
- [x] 00 Workstations + repo development environment
- [x] 01 Repo skeleton variables + baseline evidence
- [ ] 02 Client pack site variables finalized

### 10-29 Infrastructure + Pre-Phase
- [ ] 10 Proxmox install hardening implementation
- [ ] 11 Networking bridge/VLAN implementation
- [ ] 12 Storage implementation and verification (repo gates added; host evidence pending)
- [ ] 13 VM blueprints finalized (repo blueprint updated; host provisioning pending)
- [ ] 14 AI-DATA01 provisioned (81.110 runbook and verifier added; host execution evidence pending)
- [ ] 15 AI-FRONTEND01 provisioned (81.120 runbook and verifier added; host execution evidence pending)
- [ ] 16 VM base hardening enforced (81.150 scripts/templates added; host execution evidence pending)
- [ ] 17 SSH key access automation complete (81.160 tooling added; host execution evidence pending)
- [ ] 18 VM verification gate complete (81.190 gate tooling added; host PASS evidence pending)
- [ ] 19 GPU Ollama VM build complete (82.00 architecture + 82.10 BIOS/GPU precheck + 82.40 install/apply/verify artifacts added; host runtime verification pending)
- [ ] 20 Model allowlist + LAN-only policy enforced (82.30 hardening + 82.50 allowlist policy/wrapper/audit + 82.60 bind/UFW allowlist + 82.80 verification + 82.90 client rollout variables artifacts added; host enforcement evidence pending)
- [x] 21 Pre-phase integration test scaffolds in repo
- [ ] 22 Pre-phase go-live gate signed

### 30-59 Core Platform Rollout
- [ ] 30 Bootstrap baseline fully operationalized
- [ ] 31 Keycloak deployment productionized
- [ ] 32 Keycloak AD/LDAPS integration
- [ ] 33 Keycloak local users mode
- [ ] 34 MFA policy enforcement
- [ ] 35 Group-role RBAC baseline
- [ ] 36 Frontend ingress + internal TLS
- [ ] 37 UI SSO flow integration
- [ ] 38 Backend gateway + token validation
- [ ] 39 Gateway healthchecks/watchdog
- [ ] 40 Nextcloud deployment
- [ ] 41 Nextcloud permission model
- [ ] 42 Nextcloud audit/workflow hooks
- [ ] 43 Search + graph baseline
- [ ] 44 ACL inheritance in search/graph
- [ ] 45 Retention/privacy controls in search/graph

### 60-79 Voice + Workflow + Email
- [ ] 60 Voice ingestion baseline
- [ ] 61 Voice storage model + RBAC
- [ ] 62 Voice retention + audit events
- [ ] 63 Voice indexing + graph linking
- [ ] 70 Workflow approval chain
- [ ] 71 Signature standards + hashing
- [ ] 72 eSign audit trail + evidence pack
- [ ] 73 Notifications + LAN-only mail
- [ ] 74 Actionable secure email links
- [ ] 75 Mail audit logging + retention
- [ ] 76 Optional automation n8n
- [ ] 77 Optional automation Windmill

### 80-99 Monitoring + DR + Day-2 + Final Gate
- [ ] 80 Monitoring stack deploy + scrape plan
- [ ] 81 Platform-wide audit + retention implementation
- [ ] 82 Domain metrics dashboards
- [ ] 90 Backup scope + schedules
- [ ] 91 Restore procedure proof
- [ ] 92 DR runbook validation
- [ ] 93 Compliance evidence pack finalized
- [ ] 95 Day-2 start/stop runbooks
- [ ] 96 Day-2 upgrade runbooks
- [ ] 97 Day-2 log review runbooks
- [ ] 98 Incident response + capacity checks
- [ ] 99 Final security validation + GO/NO-GO
