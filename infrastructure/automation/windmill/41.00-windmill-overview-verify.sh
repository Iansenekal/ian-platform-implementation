#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/41-Automation-Windmill/41.00-Overview.md}"
ROLE_FILE="${ROLE_FILE:-infrastructure/automation/windmill/41.00-windmill-role-boundaries.yml}"
MATRIX_FILE="${MATRIX_FILE:-infrastructure/automation/windmill/41.00-windmill-vs-n8n-decision-matrix.csv}"
CHECKLIST_FILE="${CHECKLIST_FILE:-infrastructure/automation/windmill/41.00-windmill-governance-checklist.template.md}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/automation/windmill/41.00-windmill-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$ROLE_FILE" ]] || { echo "missing role boundaries: $ROLE_FILE" >&2; exit 1; }
[[ -f "$MATRIX_FILE" ]] || { echo "missing decision matrix: $MATRIX_FILE" >&2; exit 1; }
[[ -f "$CHECKLIST_FILE" ]] || { echo "missing governance checklist: $CHECKLIST_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }

grep -q "Role of Windmill" "$DOC_FILE"
grep -q "Windmill vs n8n Decision Guide" "$DOC_FILE"
grep -q "Allowed and Prohibited" "$DOC_FILE"
grep -q "Trust Boundaries" "$DOC_FILE"
grep -q "Identity, SSO, and MFA" "$DOC_FILE"
grep -q "Script/Job Lifecycle" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "runtime_mode: lan_only" "$ROLE_FILE"
grep -q "public_exposure_allowed: false" "$ROLE_FILE"
grep -q "backend_gateway_api" "$ROLE_FILE"
grep -q "outbound_internet_runtime_calls" "$ROLE_FILE"

grep -q "human_approvals_event_workflow,n8n" "$MATRIX_FILE"
grep -q "scheduled_scripts_data_transforms,windmill" "$MATRIX_FILE"
grep -q "hybrid_multi_step,n8n_plus_windmill" "$MATRIX_FILE"
grep -q "simple_api_routing,gateway_or_n8n" "$MATRIX_FILE"

grep -q "Job catalog maintained" "$CHECKLIST_FILE"
grep -q "No secrets in scripts" "$CHECKLIST_FILE"
grep -q "SSO + MFA" "$CHECKLIST_FILE"
grep -q "Outbound internet calls disabled" "$CHECKLIST_FILE"

grep -q "^WINDMILL_ENABLED=" "$INPUTS_FILE"
grep -q "^WINDMILL_DEPLOYMENT_VM=" "$INPUTS_FILE"
grep -q "^WINDMILL_INTERNAL_URL=" "$INPUTS_FILE"
grep -q "^WINDMILL_SSO_ENABLED=" "$INPUTS_FILE"

echo "41.00-windmill-overview: verification complete"
