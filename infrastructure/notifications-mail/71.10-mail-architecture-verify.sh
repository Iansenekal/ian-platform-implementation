#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/71-Notifications-Mail/71.10-Mail-Architecture-LAN-Only.md}"
README_FILE="${README_FILE:-infrastructure/notifications-mail/README.md}"
MODELS_FILE="${MODELS_FILE:-infrastructure/notifications-mail/71.10-mail-routing-models.yml}"
SECURITY_FILE="${SECURITY_FILE:-infrastructure/notifications-mail/71.10-smtp-relay-security-baseline.yml}"
CHECKLIST_FILE="${CHECKLIST_FILE:-infrastructure/notifications-mail/71.10-mail-flow-checklist.template.md}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/notifications-mail/71.10-mail-architecture-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$README_FILE" ]] || { echo "missing readme: $README_FILE" >&2; exit 1; }
[[ -f "$MODELS_FILE" ]] || { echo "missing routing models: $MODELS_FILE" >&2; exit 1; }
[[ -f "$SECURITY_FILE" ]] || { echo "missing relay baseline: $SECURITY_FILE" >&2; exit 1; }
[[ -f "$CHECKLIST_FILE" ]] || { echo "missing flow checklist: $CHECKLIST_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }

grep -q "Goal State Architecture" "$DOC_FILE"
grep -q "Trust Boundaries" "$DOC_FILE"
grep -q "Routing Models" "$DOC_FILE"
grep -q "Approve/Reject Link Flow" "$DOC_FILE"
grep -q "SMTP Relay Security Baseline" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "default_model: A" "$MODELS_FILE"
grep -q "dedicated_postfix_relay" "$MODELS_FILE"
grep -q "ui_only_no_email" "$MODELS_FILE"
grep -q "no_public_smtp_exposure: true" "$MODELS_FILE"

grep -q "source_ip_allowlist_required: true" "$SECURITY_FILE"
grep -q "open_relay_forbidden: true" "$SECURITY_FILE"
grep -q "sender_domain_restrictions_required: true" "$SECURITY_FILE"
grep -q "inbound:" "$SECURITY_FILE"
grep -q "587" "$SECURITY_FILE"

grep -q "Relay reachable only from allowlisted app IPs" "$CHECKLIST_FILE"
grep -q "Open relay test" "$CHECKLIST_FILE"
grep -q "redirect to SSO and enforce MFA" "$CHECKLIST_FILE"

grep -q "^MAIL_ROUTING_MODEL=" "$INPUTS_FILE"
grep -q "^SMTP_RELAY_HOST=" "$INPUTS_FILE"
grep -q "^SMTP_INBOUND_PORT=" "$INPUTS_FILE"
grep -q "^SMTP_AUTH_REQUIRED=" "$INPUTS_FILE"

echo "71.10-notifications-mail-architecture: verification complete"
