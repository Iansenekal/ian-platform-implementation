#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/40-Automation-n8n/40.00-Overview.md",
    "infrastructure/automation/n8n/README.md",
    "infrastructure/automation/n8n/40.00-n8n-role-boundaries.yml",
    "infrastructure/automation/n8n/40.00-n8n-trust-boundary-matrix.csv",
    "infrastructure/automation/n8n/40.00-n8n-governance-checklist.template.md",
    "infrastructure/automation/n8n/40.00-n8n-inputs.env.example",
    "infrastructure/automation/n8n/40.00-n8n-overview-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"40.00 n8n overview artifacts missing: {', '.join(missing)}")

doc = Path("docs/40-Automation-n8n/40.00-Overview.md").read_text(encoding="utf-8")
for token in [
    "Role of n8n",
    "Allowed and Disallowed",
    "Trust Boundaries",
    "Identity, SSO, and MFA",
    "Secrets and Credentials",
    "Workflow Lifecycle",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"40.00 doc missing token: {token}")

role = Path("infrastructure/automation/n8n/40.00-n8n-role-boundaries.yml").read_text(encoding="utf-8")
for token in [
    "runtime_mode: lan_only",
    "public_exposure_allowed: false",
    "gateway_api",
    "outbound_internet_runtime_calls",
]:
    if token not in role:
        raise SystemExit(f"40.00 role boundaries missing token: {token}")

matrix = Path("infrastructure/automation/n8n/40.00-n8n-trust-boundary-matrix.csv").read_text(encoding="utf-8")
for token in [
    "n8n-ai-data01,backend-gateway",
    "n8n-ai-data01,nextcloud",
    "n8n-ai-data01,postgres",
    "read-only-default",
]:
    if token not in matrix:
        raise SystemExit(f"40.00 trust matrix missing token: {token}")

checklist = Path("infrastructure/automation/n8n/40.00-n8n-governance-checklist.template.md").read_text(encoding="utf-8")
for token in [
    "Workflow catalog maintained",
    "No secrets in workflow JSON exports",
    "Outbound internet calls are disabled",
    "SSO + MFA",
]:
    if token not in checklist:
        raise SystemExit(f"40.00 governance checklist missing token: {token}")

inputs = Path("infrastructure/automation/n8n/40.00-n8n-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "N8N_ENABLED=",
    "N8N_DEPLOYMENT_VM=",
    "N8N_INTERNAL_URL=",
    "N8N_SSO_ENABLED=",
]:
    if token not in inputs:
        raise SystemExit(f"40.00 inputs missing token: {token}")

verify = Path("infrastructure/automation/n8n/40.00-n8n-overview-verify.sh").read_text(encoding="utf-8")
for token in [
    "DOC_FILE",
    "ROLE_FILE",
    "MATRIX_FILE",
    "CHECKLIST_FILE",
    "INPUTS_FILE",
    "grep -q",
    "verification complete",
]:
    if token not in verify:
        raise SystemExit(f"40.00 verify script missing token: {token}")

print("automation-n8n-overview-artifacts: OK")
