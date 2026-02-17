#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/71-Notifications-Mail/71.15-Actionable-Email-Approve-Reject-Links.md}"
TOKEN_POLICY_FILE="${TOKEN_POLICY_FILE:-infrastructure/notifications-mail/71.15-action-token-policy.yml}"
TEMPLATE_FILE="${TEMPLATE_FILE:-infrastructure/notifications-mail/71.15-email-template-fields.yml}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/notifications-mail/71.15-actionable-email-inputs.env.example}"
CHECKLIST_FILE="${CHECKLIST_FILE:-infrastructure/notifications-mail/71.15-action-flow-checklist.template.md}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$TOKEN_POLICY_FILE" ]] || { echo "missing token policy: $TOKEN_POLICY_FILE" >&2; exit 1; }
[[ -f "$TEMPLATE_FILE" ]] || { echo "missing template fields: $TEMPLATE_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }
[[ -f "$CHECKLIST_FILE" ]] || { echo "missing checklist: $CHECKLIST_FILE" >&2; exit 1; }

grep -q "Non-Negotiable Rules" "$DOC_FILE"
grep -q "Threat Model" "$DOC_FILE"
grep -q "Token Controls" "$DOC_FILE"
grep -q "SSO and MFA" "$DOC_FILE"
grep -q "single-use" "$DOC_FILE"
grep -q "Reject" "$DOC_FILE"
grep -q "Required Audit Events" "$DOC_FILE"

grep -q "default_ttl_minutes: 15" "$TOKEN_POLICY_FILE"
grep -q "single_use_required: true" "$TOKEN_POLICY_FILE"
grep -q "allow_decision_without_auth: false" "$TOKEN_POLICY_FILE"
grep -q "allow_decision_without_mfa: false" "$TOKEN_POLICY_FILE"
grep -q "log_token_value: false" "$TOKEN_POLICY_FILE"

grep -q "approve_link" "$TEMPLATE_FILE"
grep -q "reject_link" "$TEMPLATE_FILE"
grep -q "security_footer" "$TEMPLATE_FILE"
grep -q "attachments_enabled_default: false" "$TEMPLATE_FILE"
grep -q "https_only: true" "$TEMPLATE_FILE"

grep -q "^APPROVAL_EMAIL_ENABLED=" "$INPUTS_FILE"
grep -q "^ACTION_LINK_TTL_MINUTES=" "$INPUTS_FILE"
grep -q "^STRICT_RECIPIENT_BINDING=" "$INPUTS_FILE"
grep -q "^REJECT_REASON_CATEGORIES_REQUIRED=" "$INPUTS_FILE"

grep -q "explicit Approve and Reject" "$CHECKLIST_FILE"
grep -q "single-use" "$CHECKLIST_FILE"
grep -q "Forwarded-link" "$CHECKLIST_FILE"
grep -q "Expired-token flow" "$CHECKLIST_FILE"

echo "71.15-actionable-email: verification complete"
