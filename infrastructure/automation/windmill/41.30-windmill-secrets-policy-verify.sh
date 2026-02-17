#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/41-Automation-Windmill/41.30-Secrets-Policy.md}"
STORAGE_FILE="${STORAGE_FILE:-infrastructure/automation/windmill/41.30-windmill-secret-storage-policy.yml}"
NAMING_FILE="${NAMING_FILE:-infrastructure/automation/windmill/41.30-windmill-secret-naming-and-ownership.csv}"
ROTATION_FILE="${ROTATION_FILE:-infrastructure/automation/windmill/41.30-windmill-rotation-policy.yml}"
IR_FILE="${IR_FILE:-infrastructure/automation/windmill/41.30-windmill-incident-response-secrets.template.md}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/automation/windmill/41.30-windmill-secrets-inputs.env.example}"
CHECKLIST_FILE="${CHECKLIST_FILE:-infrastructure/automation/windmill/41.30-windmill-secrets-verification-checklist.template.md}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$STORAGE_FILE" ]] || { echo "missing storage policy: $STORAGE_FILE" >&2; exit 1; }
[[ -f "$NAMING_FILE" ]] || { echo "missing naming/ownership policy: $NAMING_FILE" >&2; exit 1; }
[[ -f "$ROTATION_FILE" ]] || { echo "missing rotation policy: $ROTATION_FILE" >&2; exit 1; }
[[ -f "$IR_FILE" ]] || { echo "missing incident response template: $IR_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }
[[ -f "$CHECKLIST_FILE" ]] || { echo "missing checklist: $CHECKLIST_FILE" >&2; exit 1; }

grep -q "Policy Goals and Principles" "$DOC_FILE"
grep -q "Secret Types and Storage" "$DOC_FILE"
grep -q "Service Accounts" "$DOC_FILE"
grep -q "Rotation Policy" "$DOC_FILE"
grep -q "Incident Response" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "path: /opt/windmill/secrets" "$STORAGE_FILE"
grep -q "file_permissions: \"600\"" "$STORAGE_FILE"
grep -q "inline_compose_secrets_allowed: false" "$STORAGE_FILE"
grep -q "encrypted_at_rest_required: true" "$STORAGE_FILE"
grep -q "job_arguments" "$STORAGE_FILE"

grep -q "WM::<INTEGRATION>::<SCOPE>::<ENV>" "$NAMING_FILE"
grep -q "owner,required" "$NAMING_FILE"
grep -q "rotation_date,required" "$NAMING_FILE"

grep -q "gateway_client_secret_or_api_key: 90_days" "$ROTATION_FILE"
grep -q "nextcloud_app_password_or_token: 90_days" "$ROTATION_FILE"
grep -q "db_password: 180_days" "$ROTATION_FILE"
grep -q "rotation_evidence_required: true" "$ROTATION_FILE"

grep -q "Contain: disable exposed credential" "$IR_FILE"
grep -q "Rotate: issue replacement credential" "$IR_FILE"
grep -q "Prevent: update controls" "$IR_FILE"

grep -q "^WINDMILL_SECRETS_BASE_PATH=" "$INPUTS_FILE"
grep -q "^WINDMILL_SECRET_CUSTODIAN_ROLE=" "$INPUTS_FILE"
grep -q "^WINDMILL_SECRET_NAMING_PATTERN=" "$INPUTS_FILE"
grep -q "^WINDMILL_ROTATION_INTERVAL_TOKEN_DAYS=" "$INPUTS_FILE"

grep -q "No secrets appear" "$CHECKLIST_FILE"
grep -q "Host secret files" "$CHECKLIST_FILE"
grep -q "Least-privilege tests" "$CHECKLIST_FILE"
grep -q "incident tabletop" "$CHECKLIST_FILE"

echo "41.30-windmill-secrets-policy: verification complete"
