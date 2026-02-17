#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/40-Automation-n8n/40.00-Overview.md}"
README_FILE="${README_FILE:-infrastructure/automation/n8n/README.md}"
ROLE_FILE="${ROLE_FILE:-infrastructure/automation/n8n/40.00-n8n-role-boundaries.yml}"
MATRIX_FILE="${MATRIX_FILE:-infrastructure/automation/n8n/40.00-n8n-trust-boundary-matrix.csv}"
CHECKLIST_FILE="${CHECKLIST_FILE:-infrastructure/automation/n8n/40.00-n8n-governance-checklist.template.md}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/automation/n8n/40.00-n8n-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$README_FILE" ]] || { echo "missing readme: $README_FILE" >&2; exit 1; }
[[ -f "$ROLE_FILE" ]] || { echo "missing role boundaries: $ROLE_FILE" >&2; exit 1; }
[[ -f "$MATRIX_FILE" ]] || { echo "missing trust matrix: $MATRIX_FILE" >&2; exit 1; }
[[ -f "$CHECKLIST_FILE" ]] || { echo "missing governance checklist: $CHECKLIST_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }

grep -q "Role of n8n" "$DOC_FILE"
grep -q "Allowed and Disallowed" "$DOC_FILE"
grep -q "Trust Boundaries" "$DOC_FILE"
grep -q "Identity, SSO, and MFA" "$DOC_FILE"
grep -q "Secrets and Credentials" "$DOC_FILE"
grep -q "Workflow Lifecycle" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "runtime_mode: lan_only" "$ROLE_FILE"
grep -q "public_exposure_allowed: false" "$ROLE_FILE"
grep -q "gateway_api" "$ROLE_FILE"
grep -q "outbound_internet_runtime_calls" "$ROLE_FILE"

grep -q "n8n-ai-data01,backend-gateway" "$MATRIX_FILE"
grep -q "n8n-ai-data01,nextcloud" "$MATRIX_FILE"
grep -q "read-only-default" "$MATRIX_FILE"

grep -q "Workflow catalog maintained" "$CHECKLIST_FILE"
grep -q "No secrets in workflow JSON exports" "$CHECKLIST_FILE"
grep -q "SSO + MFA" "$CHECKLIST_FILE"

grep -q "^N8N_ENABLED=" "$INPUTS_FILE"
grep -q "^N8N_DEPLOYMENT_VM=" "$INPUTS_FILE"
grep -q "^N8N_INTERNAL_URL=" "$INPUTS_FILE"
grep -q "^N8N_SSO_ENABLED=" "$INPUTS_FILE"

echo "40.00-n8n-overview: verification complete"
