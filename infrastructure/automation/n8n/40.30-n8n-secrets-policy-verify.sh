#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/40-Automation-n8n/40.30-Secrets-and-Credentials-Policy.md}"
STORAGE_FILE="${STORAGE_FILE:-infrastructure/automation/n8n/40.30-n8n-secret-storage-policy.yml}"
NAMING_FILE="${NAMING_FILE:-infrastructure/automation/n8n/40.30-n8n-credential-naming-and-ownership.csv}"
ROTATION_FILE="${ROTATION_FILE:-infrastructure/automation/n8n/40.30-n8n-rotation-policy.yml}"
IR_FILE="${IR_FILE:-infrastructure/automation/n8n/40.30-n8n-incident-response-secrets.template.md}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/automation/n8n/40.30-n8n-secrets-inputs.env.example}"
CHECKLIST_FILE="${CHECKLIST_FILE:-infrastructure/automation/n8n/40.30-n8n-secrets-verification-checklist.template.md}"

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

grep -q "path: /opt/n8n/secrets" "$STORAGE_FILE"
grep -q "file_permissions: \"600\"" "$STORAGE_FILE"
grep -q "inline_compose_secrets_allowed: false" "$STORAGE_FILE"
grep -q "encrypted_at_rest_required: true" "$STORAGE_FILE"
grep -q "secrets_in_workflow_json" "$STORAGE_FILE"

grep -q "N8N::<INTEGRATION>::<SCOPE>::<ENV>" "$NAMING_FILE"
grep -q "owner,required" "$NAMING_FILE"
grep -q "rotation_date,required" "$NAMING_FILE"

grep -q "n8n_encryption_key: annual" "$ROTATION_FILE"
grep -q "nextcloud_app_password_or_token: 90_days" "$ROTATION_FILE"
grep -q "db_password: 180_days" "$ROTATION_FILE"
grep -q "rotation_evidence_required: true" "$ROTATION_FILE"

grep -q "Contain: disable exposed credential" "$IR_FILE"
grep -q "Rotate: issue replacement credential" "$IR_FILE"
grep -q "Prevent: apply control improvements" "$IR_FILE"

grep -q "^N8N_SECRETS_BASE_PATH=" "$INPUTS_FILE"
grep -q "^N8N_CREDENTIAL_CUSTODIAN_ROLE=" "$INPUTS_FILE"
grep -q "^N8N_CREDENTIAL_NAMING_PATTERN=" "$INPUTS_FILE"
grep -q "^N8N_ROTATION_INTERVAL_TOKEN_DAYS=" "$INPUTS_FILE"

grep -q "No secrets appear" "$CHECKLIST_FILE"
grep -q "Least-privilege tests" "$CHECKLIST_FILE"
grep -q "incident tabletop" "$CHECKLIST_FILE"

echo "40.30-n8n-secrets-policy: verification complete"
