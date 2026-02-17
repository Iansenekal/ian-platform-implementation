#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/40-Automation-n8n/40.30-Secrets-and-Credentials-Policy.md",
    "infrastructure/automation/n8n/40.30-n8n-secret-storage-policy.yml",
    "infrastructure/automation/n8n/40.30-n8n-credential-naming-and-ownership.csv",
    "infrastructure/automation/n8n/40.30-n8n-rotation-policy.yml",
    "infrastructure/automation/n8n/40.30-n8n-incident-response-secrets.template.md",
    "infrastructure/automation/n8n/40.30-n8n-secrets-inputs.env.example",
    "infrastructure/automation/n8n/40.30-n8n-secrets-verification-checklist.template.md",
    "infrastructure/automation/n8n/40.30-n8n-secrets-policy-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"40.30 n8n secrets-policy artifacts missing: {', '.join(missing)}")

doc = Path("docs/40-Automation-n8n/40.30-Secrets-and-Credentials-Policy.md").read_text(encoding="utf-8")
for token in [
    "Policy Goals and Principles",
    "Secret Types and Storage",
    "Service Accounts",
    "Naming and Ownership",
    "Rotation Policy",
    "Incident Response",
    "Audit Requirements",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"40.30 doc missing token: {token}")

storage = Path("infrastructure/automation/n8n/40.30-n8n-secret-storage-policy.yml").read_text(encoding="utf-8")
for token in [
    "path: /opt/n8n/secrets",
    "file_permissions: \"600\"",
    "inline_compose_secrets_allowed: false",
    "encrypted_at_rest_required: true",
    "secrets_in_workflow_json",
]:
    if token not in storage:
        raise SystemExit(f"40.30 secret storage policy missing token: {token}")

naming = Path("infrastructure/automation/n8n/40.30-n8n-credential-naming-and-ownership.csv").read_text(encoding="utf-8")
for token in [
    "N8N::<INTEGRATION>::<SCOPE>::<ENV>",
    "owner,required",
    "purpose,required",
    "rotation_date,required",
]:
    if token not in naming:
        raise SystemExit(f"40.30 naming/ownership policy missing token: {token}")

rotation = Path("infrastructure/automation/n8n/40.30-n8n-rotation-policy.yml").read_text(encoding="utf-8")
for token in [
    "n8n_encryption_key: annual",
    "nextcloud_app_password_or_token: 90_days",
    "db_password: 180_days",
    "rotation_evidence_required: true",
    "least_privilege_revalidation_required: true",
]:
    if token not in rotation:
        raise SystemExit(f"40.30 rotation policy missing token: {token}")

ir = Path("infrastructure/automation/n8n/40.30-n8n-incident-response-secrets.template.md").read_text(encoding="utf-8")
for token in [
    "Contain: disable exposed credential",
    "Rotate: issue replacement credential",
    "Purge: remove leaked material",
    "Prevent: apply control improvements",
]:
    if token not in ir:
        raise SystemExit(f"40.30 incident response template missing token: {token}")

inputs = Path("infrastructure/automation/n8n/40.30-n8n-secrets-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "N8N_SECRETS_BASE_PATH=",
    "N8N_CREDENTIAL_CUSTODIAN_ROLE=",
    "N8N_CREDENTIAL_NAMING_PATTERN=",
    "N8N_ROTATION_INTERVAL_TOKEN_DAYS=",
]:
    if token not in inputs:
        raise SystemExit(f"40.30 inputs missing token: {token}")

checklist = Path("infrastructure/automation/n8n/40.30-n8n-secrets-verification-checklist.template.md").read_text(encoding="utf-8")
for token in [
    "No secrets appear",
    "encryption key",
    "Least-privilege tests",
    "incident tabletop",
]:
    if token not in checklist:
        raise SystemExit(f"40.30 checklist missing token: {token}")

verify = Path("infrastructure/automation/n8n/40.30-n8n-secrets-policy-verify.sh").read_text(encoding="utf-8")
for token in [
    "DOC_FILE",
    "STORAGE_FILE",
    "NAMING_FILE",
    "ROTATION_FILE",
    "IR_FILE",
    "INPUTS_FILE",
    "CHECKLIST_FILE",
    "grep -q",
    "verification complete",
]:
    if token not in verify:
        raise SystemExit(f"40.30 verify script missing token: {token}")

print("automation-n8n-secrets-policy-artifacts: OK")
