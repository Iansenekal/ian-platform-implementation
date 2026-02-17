#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/70-Document-Workflow-eSign/70.10-Approval-Chain-Model.md}"
README_FILE="${README_FILE:-infrastructure/workflow-esign/README.md}"
TEMPLATE_FILE="${TEMPLATE_FILE:-infrastructure/workflow-esign/70.10-approval-chain-template.yml}"
ROUTING_FILE="${ROUTING_FILE:-infrastructure/workflow-esign/70.10-routing-inputs-schema.yml}"
DELEGATION_FILE="${DELEGATION_FILE:-infrastructure/workflow-esign/70.10-delegation-policy.yml}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/workflow-esign/70.10-approval-chain-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$README_FILE" ]] || { echo "missing readme: $README_FILE" >&2; exit 1; }
[[ -f "$TEMPLATE_FILE" ]] || { echo "missing template: $TEMPLATE_FILE" >&2; exit 1; }
[[ -f "$ROUTING_FILE" ]] || { echo "missing routing schema: $ROUTING_FILE" >&2; exit 1; }
[[ -f "$DELEGATION_FILE" ]] || { echo "missing delegation policy: $DELEGATION_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }

grep -q "Mandatory Rules" "$DOC_FILE"
grep -q "No self-approval" "$DOC_FILE"
grep -q "MFA required" "$DOC_FILE"
grep -q "Delegation Model" "$DOC_FILE"
grep -q "Reject and Rework" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "explicit_decision_required: true" "$TEMPLATE_FILE"
grep -q "no_self_approval: true" "$TEMPLATE_FILE"
grep -q "mfa_required_for_approvers: true" "$TEMPLATE_FILE"
grep -q "step_id: S1_DOCUMENT_OWNER" "$TEMPLATE_FILE"
grep -q "step_id: S2_HOD" "$TEMPLATE_FILE"
grep -q "step_id: S3_GM" "$TEMPLATE_FILE"

grep -q "required_metadata" "$ROUTING_FILE"
grep -q "document_type" "$ROUTING_FILE"
grep -q "project_code" "$ROUTING_FILE"
grep -q "fail_closed_on_missing_required: true" "$ROUTING_FILE"

grep -q "delegation:" "$DELEGATION_FILE"
grep -q "time_bound_required: true" "$DELEGATION_FILE"
grep -q "no_self_approval_override: false" "$DELEGATION_FILE"
grep -q "WORKFLOW_DELEGATION_CREATED" "$DELEGATION_FILE"

grep -q "^WORKFLOW_TEMPLATE_ID=" "$INPUTS_FILE"
grep -q "^IDENTITY_MODE=" "$INPUTS_FILE"
grep -q "^DELEGATION_ENABLED=" "$INPUTS_FILE"
grep -q "^MFA_APPROVAL_REQUIRED=true" "$INPUTS_FILE"
grep -q "^SELF_APPROVAL_BLOCKED=true" "$INPUTS_FILE"

echo "70.10-workflow-approval-chain: verification complete"
