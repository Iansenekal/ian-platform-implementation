#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/40-Automation-n8n/40.60-Verification-Checklist.md",
    "infrastructure/automation/n8n/40.60-n8n-verification-matrix.csv",
    "infrastructure/automation/n8n/40.60-n8n-verification-checklist.template.md",
    "infrastructure/automation/n8n/40.60-n8n-evidence-pack.template.md",
    "infrastructure/automation/n8n/40.60-n8n-verification-inputs.env.example",
    "infrastructure/automation/n8n/40.60-n8n-verification-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"40.60 n8n verification-checklist artifacts missing: {', '.join(missing)}")

doc = Path("docs/40-Automation-n8n/40.60-Verification-Checklist.md").read_text(encoding="utf-8")
for token in [
    "Severity legend",
    "Network Exposure and Trust Boundaries",
    "Identity, SSO, MFA, and RBAC",
    "Secrets and Credentials Hygiene",
    "Workflow Governance and Change Control",
    "Logging, Monitoring, and Alerting",
    "Backup and Restore Readiness",
    "Security Posture and Operational Readiness",
    "Stop rollout immediately if any P0 fails",
]:
    if token not in doc and token.lower() not in doc.lower():
        raise SystemExit(f"40.60 doc missing token: {token}")

matrix = Path("infrastructure/automation/n8n/40.60-n8n-verification-matrix.csv").read_text(encoding="utf-8")
for token in [
    "NET-01,P0",
    "NET-02,P0",
    "ID-03,P0",
    "SEC-01,P0",
    "WF-02,P1",
    "OBS-01,P1",
    "BDR-02,P1",
    "OPS-03,P2",
]:
    if token not in matrix:
        raise SystemExit(f"40.60 verification matrix missing token: {token}")

checklist = Path("infrastructure/automation/n8n/40.60-n8n-verification-checklist.template.md").read_text(encoding="utf-8")
for token in [
    "P0 Gate",
    "NET-01",
    "ID-02",
    "SEC-01",
    "Gate Decision",
]:
    if token not in checklist:
        raise SystemExit(f"40.60 checklist template missing token: {token}")

evidence = Path("infrastructure/automation/n8n/40.60-n8n-evidence-pack.template.md").read_text(encoding="utf-8")
for token in [
    "Required attachments",
    "UFW allowlist proof",
    "SSO + MFA enforcement evidence",
    "backup logs and lab restore-test report",
]:
    if token not in evidence:
        raise SystemExit(f"40.60 evidence template missing token: {token}")

inputs = Path("infrastructure/automation/n8n/40.60-n8n-verification-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "N8N_ENVIRONMENT=",
    "N8N_ALLOWED_SOURCE_IPS=",
    "N8N_ADMIN_MFA_REQUIRED=true",
    "N8N_WORKFLOW_CATALOG_PATH=",
    "N8N_BACKUP_LOG_PATH=",
]:
    if token not in inputs:
        raise SystemExit(f"40.60 inputs missing token: {token}")

verify = Path("infrastructure/automation/n8n/40.60-n8n-verification-verify.sh").read_text(encoding="utf-8")
for token in [
    "DOC_FILE",
    "MATRIX_FILE",
    "CHECKLIST_FILE",
    "EVIDENCE_FILE",
    "INPUTS_FILE",
    "grep -q",
    "verification complete",
]:
    if token not in verify:
        raise SystemExit(f"40.60 verify script missing token: {token}")

print("automation-n8n-verification-checklist-artifacts: OK")
