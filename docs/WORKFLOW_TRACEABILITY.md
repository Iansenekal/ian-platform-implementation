# Workflow Traceability Matrix (00-99)

Last Updated: 2026-02-17
Purpose: Map the original delivery workflow to concrete repository artifacts, delivery status, ownership, and gate criteria.

Status legend:
- DONE: Implemented and verified in repo/CI.
- PARTIAL: Scaffold or documentation exists; runtime implementation incomplete.
- NOT_STARTED: No concrete implementation yet.

## 00-09 Operator + Repo Setup

| ID | Workflow Item | Primary Repo Artifact | Status | Sprint/Phase | Gate to Close |
|---|---|---|---|---|---|
| 00 | Workstations VS Code setup | `.devcontainer/devcontainer.json`, `tools/setup-dev.sh` | DONE | Baseline | Devcontainer launches and setup script exits 0 |
| 01 | Repo skeleton variables/evidence | `README.md`, `REPO_CONVENTIONS.md`, `docs/PLATFORM_AUDIT.md` | DONE | Baseline | CI green + required docs present |
| 02 | Client pack/site variables | `configs/client-rollout-variables.example.yaml` | PARTIAL | Sprint A | Client-specific values finalized per site |
| 03.30 | Audit logging standard baseline | `platform/observability/audit-events/EVENT_SCHEMA.md` | DONE | Baseline | Event schema adopted by services |
| 06.40 | Compliance evidence preservation baseline | `docs/PLATFORM_AUDIT.md` | PARTIAL | Sprint B+ | Automated evidence pack generation |

## 10-29 Infrastructure + Pre-Phase

| ID | Workflow Item | Primary Repo Artifact | Status | Sprint/Phase | Gate to Close |
|---|---|---|---|---|---|
| 10 | Proxmox install hardening | `infrastructure/proxmox/install-hardening/README.md` | PARTIAL | Sprint A | Automated install/hardening scripts validated on target host |
| 11 | Proxmox networking | `infrastructure/proxmox/networking/README.md`, `infrastructure/proxmox/networking/81.60-network-verification.sh` | PARTIAL | Sprint A | 81.50 implementation + 81.60 verification evidence validated on target host |
| 12 | Proxmox storage | `infrastructure/proxmox/storage/README.md`, `infrastructure/proxmox/storage/81.90-storage-verification.sh` | PARTIAL | Sprint A | 81.70 decision + 81.80 implementation + 81.90 verification evidence validated on target host |
| 13 | VM blueprints/resources | `infrastructure/vm-provisioning/blueprints/vm-blueprints.yml`, `docs/81-Proxmox-Host/81.100-VM-Blueprints-CPU-RAM-Disk-NIC.md` | PARTIAL | Sprint A | Blueprints accepted and used for VM creation with guest agent enabled |
| 14 | AI-DATA01 provision | `docs/81-Proxmox-Host/81.110-Ubuntu-24.04-Minimal-Install-DataVM.md`, `infrastructure/vm-provisioning/install/81.110-ai-data01-verify.sh` | PARTIAL | Sprint A | AI-DATA01 installed on target host and verification evidence captured |
| 15 | AI-FRONTEND01 provision | `docs/81-Proxmox-Host/81.120-Ubuntu-24.04-Minimal-Install-FrontendVM.md`, `infrastructure/vm-provisioning/install/81.120-ai-frontend01-verify.sh` | PARTIAL | Sprint A | AI-FRONTEND01 installed on target host and verification evidence captured |
| 16 | VM base hardening | `docs/81-Proxmox-Host/81.150-VM-Base-Hardening-SSH-UFW-UnattendedUpgrades.md`, `infrastructure/vm-provisioning/hardening/base-hardening.sh`, `infrastructure/vm-provisioning/hardening/verify-hardening.sh` | PARTIAL | Sprint A | 81.150 hardening applied to each VM with evidence |
| 17 | VM access + SSH keys | `docs/81-Proxmox-Host/81.160-VM-Access-RemoteSSH-Keys-and-AdminWorkstations.md`, `infrastructure/vm-provisioning/access/provision-admin-access.sh`, `infrastructure/vm-provisioning/access/verify-admin-access.sh` | PARTIAL | Sprint A | Unique user keys onboarded and UFW SSH allowlists verified per VM |
| 18 | VM provisioning verification gate | `docs/81-Proxmox-Host/81.190-VM-Provisioning-Verification-Checklist.md`, `infrastructure/vm-provisioning/verification/81.190-vm-provisioning-gate.sh` | PARTIAL | Sprint A | 81.190 gate executed with PASS report and evidence bundle |
| 19 | GPU Ollama build | `docs/82-LLM-Pointer-Server/82.00-Overview-and-RoleInPlatform.md`, `docs/82-LLM-Pointer-Server/82.10-BIOS-UEFI-GPU-Prechecks.md`, `docs/82-LLM-Pointer-Server/82.40-Ollama-Install-AMD-GPU.md`, `infrastructure/ollama-gpu/82.10-bios-precheck-gate.sh`, `infrastructure/ollama-gpu/82.40-ollama-install-apply.sh` | PARTIAL | Sprint A | BIOS/UEFI/GPU prechecks completed and pointer host provisioned with stable runtime |
| 20 | Model allowlist + LAN-only gate | `docs/82-LLM-Pointer-Server/82.50-US-EU-Model-Allowlist-Policy.md`, `docs/82-LLM-Pointer-Server/82.60-Ollama-LAN-Only-Bind-and-UFW-Allowlist.md`, `docs/82-LLM-Pointer-Server/82.80-Verification-Checklist.md`, `docs/82-LLM-Pointer-Server/82.90-Client-Rollout-Variables.md`, `infrastructure/ollama-gpu/82.50-model-allowlist.yaml.example`, `infrastructure/ollama-gpu/82.50-allowlist-enforced-pull.sh`, `infrastructure/ollama-gpu/82.50-allowlist-audit.sh`, `infrastructure/ollama-gpu/82.60-lan-allowlist-apply.sh`, `infrastructure/ollama-gpu/82.80-verification-run.sh`, `infrastructure/ollama-gpu/82.90-client-rollout-variables.yaml` | PARTIAL | Sprint A | US/EU allowlist + LAN-only UFW/SSH controls enforced with evidence |
| 21 | Pre-phase integration tests | `docs/83-PrePhase-Integration/83.00-EndToEnd-Connectivity-Tests.md`, `docs/83-PrePhase-Integration/83.10-DNS-and-Naming-Resolution-Tests.md`, `docs/83-PrePhase-Integration/83.20-Security-Smoke-Tests.md`, `infrastructure/prephase/tests/83.00-end-to-end-connectivity.sh`, `infrastructure/prephase/tests/83.10-dns-resolution-tests.sh`, `infrastructure/prephase/tests/83.20-security-smoke-tests.sh`, `scripts/prephase/verify_prephase_connectivity_artifacts.py`, `scripts/prephase/verify_prephase_dns_artifacts.py`, `scripts/prephase/verify_prephase_security_smoke_artifacts.py`, `tests/infrastructure/test_phase_10_29_artifacts.py` | DONE | Sprint A | Test suite passes in CI |
| 22 | Pre-phase go-live gate | `docs/83-PrePhase-Integration/83.30-PreBootstrap-GoLive-Gate.md`, `infrastructure/prephase/tests/83.30-prebootstrap-go-live-gate.md`, `infrastructure/prephase/tests/83.30-go-live-gate-report.sh`, `scripts/prephase/verify_prebootstrap_go_live_gate_artifacts.py` | PARTIAL | Sprint A | Formal gate review complete with signed report and evidence bundle |

## 30-59 Core Platform Rollout

| ID | Workflow Item | Primary Repo Artifact | Status | Sprint/Phase | Gate to Close |
|---|---|---|---|---|---|
| 30 | Platform bootstrap baseline | `platform/observability/*`, `platform/security/secrets-management/*` | PARTIAL | Sprint B | Secrets + audit runtime controls active in services |
| 31 | Identity provider deploy (Keycloak) | `infrastructure/keycloak/docker-compose.yml`, `scripts/smoke/keycloak_realm_bootstrap.sh` | PARTIAL | Sprint B | Keycloak health + admin login + realm bootstrap |
| 32 | Identity mode A (AD/LDAPS) | `infrastructure/keycloak/README.md` | NOT_STARTED | Post-Sprint B | LDAPS bind tested |
| 33 | Identity mode B (local users) | `infrastructure/keycloak/README.md` | PARTIAL | Sprint B | Local realm users tested |
| 34 | MFA policy | `infrastructure/keycloak/realm/realm-export.json` | PARTIAL | Sprint B | MFA policy enabled and verified |
| 35 | Group-to-role mapping (RBAC) | `infrastructure/keycloak/realm/realm-export.json` | PARTIAL | Sprint B | Role mappings validated in test realm |
| 36 | Frontend ingress + internal TLS | `infrastructure/gateway/nginx/nginx.conf` | PARTIAL | Sprint B | TLS cert integration and ingress test |
| 37 | UI SSO flow (Ingress-IdP) | `infrastructure/gateway/README.md` | NOT_STARTED | Post-Sprint B | Full OIDC SSO login flow verified |
| 38 | Backend gateway + token validation | `infrastructure/gateway/nginx/nginx.conf` | PARTIAL | Sprint B | JWT validation active with protected upstream |
| 39 | Gateway healthchecks + watchdog | `infrastructure/gateway/nginx/nginx.conf` | PARTIAL | Sprint B | Healthcheck endpoints monitored + alerts |
| 40 | Nextcloud deploy | `infrastructure/nextcloud/` (planned) | NOT_STARTED | Future | Nextcloud operational |
| 41 | Nextcloud permissions/roles | `platform/security/rbac/` (planned) | NOT_STARTED | Future | ACL model validated |
| 42 | Nextcloud audit/workflow hooks | `services/workflow-engine/` (planned) | NOT_STARTED | Future | End-to-end audit hooks verified |
| 43 | Search + graph baseline | `infrastructure/search-graph/` (planned) | NOT_STARTED | Future | Search ingestion operational |
| 44 | ACL inheritance (search/graph) | `infrastructure/search-graph/` (planned) | NOT_STARTED | Future | ACL filter tests pass |
| 45 | Retention/privacy controls (search/graph) | `platform/observability/audit-events/RETENTION_POLICY.md` | PARTIAL | Future | Implemented purge/retention automation |

## 60-79 Voice + Workflow + Email

| ID | Workflow Item | Primary Repo Artifact | Status | Sprint/Phase | Gate to Close |
|---|---|---|---|---|---|
| 60 | Voice ingestion baseline | `services/voice-ingestion-service/` (planned) | NOT_STARTED | Future | Voice ingest API + storage flow |
| 61 | Voice storage model + RBAC | `services/voice-ingestion-service/` (planned) | NOT_STARTED | Future | RBAC checks enforce policy |
| 62 | Voice retention + audit events | `platform/observability/audit-events/` | PARTIAL | Future | Voice-specific events emitted |
| 63 | Voice indexing + graph linking | `infrastructure/search-graph/` (planned) | NOT_STARTED | Future | Transcript indexing verified |
| 70 | Workflow approval chain | `services/workflow-engine/` (planned) | NOT_STARTED | Future | Approval chain e2e passes |
| 71 | Signature standards + hashing | `services/workflow-engine/` (planned) | NOT_STARTED | Future | Signature verification tests pass |
| 72 | Audit trail + eSign evidence pack | `docs/runbooks/` (planned) | NOT_STARTED | Future | Evidence export accepted |
| 73 | Notifications + LAN mail | `services/notification-service/` (planned) | NOT_STARTED | Future | Mail relay integration tested |
| 74 | Actionable email approve/reject | `services/notification-service/` (planned) | NOT_STARTED | Future | Secure action links verified |
| 75 | Mail audit logging + retention | `platform/observability/audit-events/` | PARTIAL | Future | Mail events emitted + retention enforced |
| 76 | Optional automation n8n | `infrastructure/automation/n8n/` (planned) | NOT_STARTED | Future | Optional enablement gate |
| 77 | Optional automation Windmill | `infrastructure/automation/windmill/` (planned) | NOT_STARTED | Future | Optional enablement gate |

## 80-99 Monitoring, DR, Day-2 Ops, Final Gate

| ID | Workflow Item | Primary Repo Artifact | Status | Sprint/Phase | Gate to Close |
|---|---|---|---|---|---|
| 80 | Monitoring stack + scrape plan | `platform/observability/metrics/prometheus.yml`, `services/reference-app/docker-compose.yml` | PARTIAL | Sprint B | Production scrape targets + dashboards complete |
| 81 | Audit events + retention (platform-wide) | `platform/observability/audit-events/*` | PARTIAL | Sprint B+ | Platform services emit to schema |
| 82 | Workflow/transcription/eSign dashboards | `platform/observability/metrics/alert-rules.yml` | PARTIAL | Future | Domain dashboards in Grafana |
| 90 | Backup scope + schedules | `infrastructure/backup/` (planned) | NOT_STARTED | Future | Backup policy implemented |
| 91 | Restore procedure test proof | `infrastructure/backup/` (planned) | NOT_STARTED | Future | Successful restore evidence |
| 92 | DR runbook validation + tabletop | `infrastructure/dr/` (planned) | NOT_STARTED | Future | Tabletop sign-off completed |
| 93 | Compliance evidence preservation final | `docs/PLATFORM_AUDIT.md` | PARTIAL | Future | Evidence pack automation |
| 95 | Day-2 ops start/stop runbooks | `docs/runbooks/` (planned) | NOT_STARTED | Future | Approved operational runbooks |
| 96 | Day-2 ops upgrades | `docs/runbooks/` (planned) | NOT_STARTED | Future | Upgrade path verified |
| 97 | Day-2 ops log review | `docs/runbooks/` (planned) | NOT_STARTED | Future | Log review cadence active |
| 98 | Incident response + capacity checks | `docs/runbooks/` (planned) | NOT_STARTED | Future | Incident drills + capacity reports |
| 99 | Final security validation + GO/NO-GO | `infrastructure/prephase/tests/prebootstrap-go-live-gate.md` | NOT_STARTED | Final Gate | All mandatory gates signed |

## Current Sprint Summary

- Sprint A target: 10-29 skeleton + executable verification tests.
- Sprint B target: keycloak + gateway + secrets/audit runtime controls + CI checks.
- Completion signal for these sprints: `make lint && make build && make test && make verify` passes in CI.
