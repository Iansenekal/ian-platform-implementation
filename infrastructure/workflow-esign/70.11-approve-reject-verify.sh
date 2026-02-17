#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/70-Document-Workflow-eSign/70.11-Approve-Reject-Actions-and-Escalations.md}"
README_FILE="${README_FILE:-infrastructure/workflow-esign/README.md}"
SEMANTICS_FILE="${SEMANTICS_FILE:-infrastructure/workflow-esign/70.11-action-semantics.yml}"
SLA_FILE="${SLA_FILE:-infrastructure/workflow-esign/70.11-sla-escalation-policy.yml}"
EMAIL_FILE="${EMAIL_FILE:-infrastructure/workflow-esign/70.11-email-action-policy.yml}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/workflow-esign/70.11-approve-reject-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$README_FILE" ]] || { echo "missing readme: $README_FILE" >&2; exit 1; }
[[ -f "$SEMANTICS_FILE" ]] || { echo "missing semantics: $SEMANTICS_FILE" >&2; exit 1; }
[[ -f "$SLA_FILE" ]] || { echo "missing sla policy: $SLA_FILE" >&2; exit 1; }
[[ -f "$EMAIL_FILE" ]] || { echo "missing email policy: $EMAIL_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }

grep -q "Non-Negotiable Rules" "$DOC_FILE"
grep -q "No auto-approval" "$DOC_FILE"
grep -q "Reject reason mandatory" "$DOC_FILE"
grep -q "Step SLAs, Reminders, and Escalations" "$DOC_FILE"
grep -q "Email-Based Approve/Reject" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "approve:" "$SEMANTICS_FILE"
grep -q "reject:" "$SEMANTICS_FILE"
grep -q "required_inputs:" "$SEMANTICS_FILE"
grep -q "reject_reason" "$SEMANTICS_FILE"
grep -q "auto_approval_allowed: false" "$SEMANTICS_FILE"

grep -q "at_percent: 50" "$SLA_FILE"
grep -q "at_percent: 80" "$SLA_FILE"
grep -q "level: 1" "$SLA_FILE"
grep -q "level: 2" "$SLA_FILE"
grep -q "level: 3" "$SLA_FILE"
grep -q "never_auto_approve: true" "$SLA_FILE"

grep -q "signed_token_required: true" "$EMAIL_FILE"
grep -q "identity_bound_token: true" "$EMAIL_FILE"
grep -q "mfa_required_on_action: true" "$EMAIL_FILE"
grep -q "APPROVAL_TOKEN_INVALID" "$EMAIL_FILE"

grep -q "^REJECT_REASON_REQUIRED=true" "$INPUTS_FILE"
grep -q "^EMAIL_ACTION_TOKEN_TTL_MINUTES=" "$INPUTS_FILE"
grep -q "^MFA_REQUIRED_FOR_APPROVAL=true" "$INPUTS_FILE"
grep -q "^AUTO_APPROVAL_ENABLED=false" "$INPUTS_FILE"

echo "70.11-workflow-approve-reject-escalation: verification complete"
