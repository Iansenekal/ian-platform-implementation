#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/41-Automation-Windmill/41.30-Secrets-Policy.md",
    "infrastructure/automation/windmill/41.30-windmill-secret-storage-policy.yml",
    "infrastructure/automation/windmill/41.30-windmill-secret-naming-and-ownership.csv",
    "infrastructure/automation/windmill/41.30-windmill-rotation-policy.yml",
    "infrastructure/automation/windmill/41.30-windmill-incident-response-secrets.template.md",
    "infrastructure/automation/windmill/41.30-windmill-secrets-inputs.env.example",
    "infrastructure/automation/windmill/41.30-windmill-secrets-verification-checklist.template.md",
    "infrastructure/automation/windmill/41.30-windmill-secrets-policy-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"41.30 windmill secrets-policy artifacts missing: {', '.join(missing)}")

doc = Path("docs/41-Automation-Windmill/41.30-Secrets-Policy.md").read_text(encoding="utf-8")
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
        raise SystemExit(f"41.30 doc missing token: {token}")

storage = Path("infrastructure/automation/windmill/41.30-windmill-secret-storage-policy.yml").read_text(encoding="utf-8")
for token in [
    "path: /opt/windmill/secrets",
    "file_permissions: \"600\"",
    "inline_compose_secrets_allowed: false",
    "encrypted_at_rest_required: true",
    "job_arguments",
]:
    if token not in storage:
        raise SystemExit(f"41.30 secret storage policy missing token: {token}")

naming = Path("infrastructure/automation/windmill/41.30-windmill-secret-naming-and-ownership.csv").read_text(encoding="utf-8")
for token in [
    "WM::<INTEGRATION>::<SCOPE>::<ENV>",
    "owner,required",
    "purpose,required",
    "rotation_date,required",
]:
    if token not in naming:
        raise SystemExit(f"41.30 naming/ownership policy missing token: {token}")

rotation = Path("infrastructure/automation/windmill/41.30-windmill-rotation-policy.yml").read_text(encoding="utf-8")
for token in [
    "gateway_client_secret_or_api_key: 90_days",
    "nextcloud_app_password_or_token: 90_days",
    "db_password: 180_days",
    "rotation_evidence_required: true",
    "least_privilege_revalidation_required: true",
]:
    if token not in rotation:
        raise SystemExit(f"41.30 rotation policy missing token: {token}")

ir = Path("infrastructure/automation/windmill/41.30-windmill-incident-response-secrets.template.md").read_text(encoding="utf-8")
for token in [
    "Contain: disable exposed credential",
    "Rotate: issue replacement credential",
    "Purge: remove leaked material",
    "Prevent: update controls",
]:
    if token not in ir:
        raise SystemExit(f"41.30 incident response template missing token: {token}")

inputs = Path("infrastructure/automation/windmill/41.30-windmill-secrets-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "WINDMILL_SECRETS_BASE_PATH=",
    "WINDMILL_SECRET_CUSTODIAN_ROLE=",
    "WINDMILL_SECRET_NAMING_PATTERN=",
    "WINDMILL_ROTATION_INTERVAL_TOKEN_DAYS=",
]:
    if token not in inputs:
        raise SystemExit(f"41.30 inputs missing token: {token}")

checklist = Path("infrastructure/automation/windmill/41.30-windmill-secrets-verification-checklist.template.md").read_text(encoding="utf-8")
for token in [
    "No secrets appear",
    "Host secret files",
    "Least-privilege tests",
    "incident tabletop",
]:
    if token not in checklist:
        raise SystemExit(f"41.30 checklist missing token: {token}")

verify = Path("infrastructure/automation/windmill/41.30-windmill-secrets-policy-verify.sh").read_text(encoding="utf-8")
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
        raise SystemExit(f"41.30 verify script missing token: {token}")

print("automation-windmill-secrets-policy-artifacts: OK")
