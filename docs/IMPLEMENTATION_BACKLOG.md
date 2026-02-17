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
- [x] A9 Add 02.20 UFW policy runbook + deterministic firewall scripts + CI artifact verification

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
- [x] B16 Add 03.20 secrets standard runbook + deterministic secrets scripts + CI artifact verification
- [x] B17 Add 03.30 audit logging runbook + source map + verification automation
- [x] B18 Add 50.30 audit events/retention policy doc + legal-hold/access-review templates + CI verification
- [x] B19 Add 11.00 identity provider overview baseline + CI artifact verification
- [x] B20 Add 11.10 IdP ports/boundaries baseline + verification script + CI artifact checks
- [x] B21 Add 04.20 AD-vs-Local auth mode standard + decision matrix + CI verification
- [x] B22 Add 11.40 AD-LDAPS integration templates + verification automation
- [x] B23 Add 11.50 local-users (no-directory) runbook + templates + verification automation
- [x] B24 Add 04.30 MFA policy standard + CI artifact verification
- [x] B25 Add 04.70 break-glass/recovery standard + CI artifact verification
- [x] B26 Add 11.60 IdP MFA (TOTP/WebAuthn/recovery-codes) runbook + templates + verification automation
- [x] B27 Add 04.40 role-model RBAC/groups standard + matrix + verification automation
- [x] B28 Add 11.70 group-to-role mapping claims standard + templates + verification automation
- [x] B29 Add 20.20 frontend ingress internal-TLS (private CA) standard + verification automation
- [x] B30 Add 04.60 SSO integration matrix (all apps) + gateway templates + verification automation
- [x] B31 Add 20.30 UI SSO flow (OIDC) baseline + verification automation
- [x] B32 Add 10.40 gateway auth-token validation baseline + verification automation
- [x] B33 Add 10.50 gateway RBAC authorization baseline + verification automation
- [x] B34 Add 10.80 gateway healthchecks/watchdog baseline + verification automation
- [x] B35 Add 21.00 Nextcloud overview/role baseline + verification automation
- [x] B36 Add 21.30 Nextcloud auth-options (SSO/AD/Local) baseline + verification automation
- [x] B37 Add 21.35 Nextcloud permissions/roles baseline + verification automation
- [x] B38 Add 21.36 Nextcloud group-naming canonical taxonomy + verification automation
- [x] B39 Add 21.37 Nextcloud project-folder ACL blueprint + verification automation
- [x] B40 Add 21.45 Nextcloud audit logging events + evidence-pack baseline + verification automation
- [x] B41 Add 21.80 Nextcloud document lifecycle + workflow/eSign integration baseline + verification automation
- [x] B42 Add 21.81 Nextcloud eSign integration options baseline + verification automation
- [x] B43 Add 30.00 search + knowledge-graph overview baseline + verification automation
- [x] B44 Add 30.10 search + knowledge-graph sources/connectors baseline + verification automation
- [x] B45 Add 30.15 search + knowledge-graph ACL inheritance baseline + verification automation
- [x] B46 Add 30.70 search + knowledge-graph retention/privacy baseline + verification automation
- [x] B53 Add 30.90 search + knowledge-graph voice transcript indexing/graph-linking baseline + verification automation
- [x] B47 Add 60.00 voice/transcription overview baseline + verification automation
- [x] B48 Add 60.10 voice/transcription architecture/data-flow baseline + verification automation
- [x] B49 Add 60.30 voice/transcription storage-model baseline + verification automation
- [x] B50 Add 60.40 voice/transcription RBAC baseline + verification automation
- [x] B51 Add 60.50 voice/transcription retention-policy baseline + verification automation
- [x] B52 Add 60.60 voice/transcription audit-events baseline + verification automation
- [x] B54 Add 60.70 voice/transcription search-indexing integration baseline + verification automation
- [x] B55 Add 70.10 workflow/eSign approval-chain baseline + verification automation
- [x] B56 Add 70.11 workflow/eSign approve-reject and escalation baseline + verification automation
- [x] B57 Add 70.30 workflow/eSign signature-standard and verification baseline + automation
- [x] B58 Add 70.40 workflow/eSign document versioning-and-hashing baseline + verification automation
- [x] B59 Add 70.50 workflow/eSign audit-trail and evidence-pack baseline + verification automation
- [x] B60 Add 71.10 notifications/mail LAN-only architecture baseline + verification automation
- [x] B61 Add 71.15 actionable email Approve/Reject links security baseline + verification automation
- [x] B62 Add 71.40 notifications/mail audit-logging and retention baseline + verification automation
- [x] B63 Add 71.50 notifications/mail evidence-retention standard + purge/legal-hold verification automation
- [x] B64 Add 40.00 n8n optional automation overview baseline + verification automation
- [x] B65 Add 40.10 n8n ports/trust-boundaries baseline + verification automation
- [x] B66 Add 40.20 n8n SSO/MFA policy baseline + verification automation
- [x] B67 Add 40.30 n8n secrets-and-credentials policy baseline + verification automation
- [x] B68 Add 40.50 n8n backup-and-restore baseline + verification automation
- [x] B69 Add 40.60 n8n mandatory verification-checklist baseline + verification automation
- [x] B70 Add 41.00 Windmill optional automation overview baseline + verification automation
- [x] B71 Add 41.10 Windmill ports-and-trust-boundaries baseline + verification automation
- [x] B72 Add 41.20 Windmill SSO-and-MFA policy baseline + verification automation
- [x] B73 Add 41.30 Windmill secrets-policy baseline + verification automation
- [x] B74 Add 41.50 Windmill backup-and-restore baseline + verification automation
- [x] B75 Add 41.60 Windmill mandatory verification-checklist baseline + verification automation
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
- [ ] C2 Finalize MFA + break-glass policy enforcement (04.30 + 04.70 baselines/verifiers added; runtime drill evidence pending)
- [ ] C3 Implement RBAC group-role mapping automation
- [ ] C4 Deploy Nextcloud and permission lifecycle controls
- [ ] C5 Deploy search/graph baseline + ACL inheritance

## Wave 4: 60-79 Voice/Workflow/Email

### todo
- [ ] D1 Voice ingestion service + transcript pipeline (60.00 + 60.10 + 60.30 + 60.40 + 60.70 baselines/verifiers added; runtime service/orchestration and search-integration evidence pending)
- [ ] D2 Voice retention and audit events (60.50 + 60.60 baselines/verifiers added; runtime purge-event emission, tamper-evident pipeline evidence, and operational audit evidence pending)
- [ ] D3 Workflow engine + eSign verification model (70.10 + 70.11 + 70.30 + 70.40 + 70.50 baselines/verifiers added; runtime workflow implementation, eSign integration, signature/version verification, and end-to-end evidence pending)
- [ ] D4 Notification service + audit retention (71.10 + 71.15 + 71.40 + 71.50 baselines/verifiers added; runtime SMTP relay integration, secure actionable-email decision flow, centralized audit pipeline, purge/legal-hold execution, and mail retention evidence pending)
- [ ] D5 Optional automation platform enablement (40.00 + 40.10 + 40.20 + 40.30 + 40.50 + 40.60 n8n baselines/verifiers and 41.00 + 41.10 + 41.20 + 41.30 + 41.50 + 41.60 Windmill baselines/verifiers added; runtime n8n/Windmill deployment, allowlist enforcement, SSO/MFA integration, verification gate execution evidence, backup/restore drills, and secrets/credentials governance evidence pending)

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
- [ ] 02.20 UFW policy applied on AI-FRONTEND01 and AI-DATA01 (repo artifacts + CI checks added; host execution evidence pending)
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
- [ ] 30 Bootstrap baseline fully operationalized (03.20 secrets standard artifacts added; host execution evidence pending)
- [ ] 31 Keycloak deployment productionized (11.00/11.10 baselines added; runtime hardening/ops evidence pending)
- [ ] 32 Keycloak AD/LDAPS integration (04.20 + 11.40 baselines and verification assets added; live LDAPS bind evidence pending)
- [ ] 33 Keycloak local users mode (04.20 + 11.50 baselines and verification assets added; live user lifecycle evidence pending)
- [ ] 34 MFA policy enforcement (04.30 + 04.70 + 11.60 baselines/verifiers added; runtime enforcement and drill evidence pending)
- [ ] 35 Group-role RBAC baseline (04.40 + 11.70 baselines/templates/verifiers added; runtime group-role enforcement evidence pending)
- [ ] 36 Frontend ingress + internal TLS (20.20 TLS baseline + verifier added; live cert/trust rollout evidence pending)
- [ ] 37 UI SSO flow integration (04.60 + 20.30 baselines/verifiers added; live end-to-end SSO evidence pending)
- [ ] 38 Backend gateway + token validation + RBAC authorization (10.40/10.50 baselines + verifiers added; live runtime evidence pending)
- [ ] 39 Gateway healthchecks/watchdog (10.80 baseline + verifier added; live runtime drill evidence pending)
- [ ] 40 Nextcloud deployment (21.00 + 21.30 baselines/verifiers added; runtime deployment/auth-mode/access/restore evidence pending)
- [ ] 41 Nextcloud permission model (21.35 + 21.36 + 21.37 baselines/verifiers added; runtime ACL behavior and cross-app inheritance evidence pending)
- [ ] 42 Nextcloud audit/workflow hooks (21.45 + 21.80 + 21.81 baselines/verifiers added; runtime signing workflow execution and independent signature-verification evidence pending)
- [ ] 43 Search + graph baseline (30.00 + 30.10 baselines/verifiers added; runtime connector ingestion and permission-aware mind-map evidence pending)
- [ ] 44 ACL inheritance in search/graph (30.15 baseline + verifier added; runtime ACL sampling/deny-test and drift-remediation evidence pending)
- [ ] 45 Retention/privacy controls in search/graph (30.70 baseline + verifier added; runtime purge execution, deletion-SLA evidence, and privacy regression evidence pending)
- [ ] 46 Voice transcript indexing + graph linking (30.90 baseline + verifier added; runtime transcript ingestion, ACL-filtered graph visibility, and relevance-validation evidence pending)

### 60-79 Voice + Workflow + Email
- [ ] 60 Voice ingestion baseline (60.00 + 60.10 baselines/verifiers added; runtime ingest/transcribe flow evidence pending)
- [ ] 61 Voice storage model + RBAC (60.30 + 60.40 baselines/verifiers added; runtime ACL/approval/index/export-control evidence pending)
- [ ] 62 Voice retention + audit events (60.50 + 60.60 baselines/verifiers added; runtime purge/hold execution evidence and audit-event emissions pending)
- [ ] 63 Voice indexing + graph linking (60.70 + 30.90 baselines/verifiers added; runtime indexing-gate, ACL-filtered graph visibility, and purge/reindex evidence pending)
- [ ] 70 Workflow approval chain (70.10 + 70.11 baselines/verifiers added; runtime chain execution, no-self-approval/MFA enforcement, approve-reject/escalation evidence, and step-audit evidence pending)
- [ ] 71 Signature standards + hashing (70.30 + 70.40 baselines/verifiers added; runtime receipt signing, version-bound approvals, and key-rotation evidence pending)
- [ ] 72 eSign audit trail + evidence pack (70.50 baseline + verifier added; runtime immutable Evidence-Pack enforcement, export-control, and retention/legal-hold evidence pending)
- [ ] 73 Notifications + LAN-only mail (71.10 baseline + verifier added; runtime relay integration and delivery/security evidence pending)
- [ ] 74 Actionable secure email links (71.15 baseline + verifier added; runtime single-use token service, SSO+MFA action flow, and anti-forward/replay evidence pending)
- [ ] 75 Mail audit logging + retention (71.40 + 71.50 baselines/verifiers added; runtime mail-event emission, central-log integrity controls, legal-hold enforcement, and retention/purge evidence pending)
- [ ] 76 Optional automation n8n (40.00 + 40.10 + 40.20 + 40.30 + 40.50 + 40.60 baselines/verifiers added; runtime deployment, port/boundary enforcement, SSO/MFA enforcement, verification-gate evidence, backup/restore evidence, and secrets/rotation evidence pending)
- [ ] 77 Optional automation Windmill (41.00 + 41.10 + 41.20 + 41.30 + 41.50 + 41.60 baselines/verifiers added; runtime deployment, role enforcement, port/boundary allowlist evidence, SSO/MFA enforcement evidence, secrets governance execution evidence, backup/restore drill evidence, production verification-gate execution evidence, and operational evidence pending)

### 80-99 Monitoring + DR + Day-2 + Final Gate
- [ ] 80 Monitoring stack deploy + scrape plan
- [ ] 81 Platform-wide audit + retention implementation (50.30 policy/matrix/templates added; runtime emitter and purge orchestration expansion pending)
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
