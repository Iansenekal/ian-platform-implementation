#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/71-Notifications-Mail/71.40-Audit-Logging-MailEvents.md}"
TAXONOMY_FILE="${TAXONOMY_FILE:-infrastructure/notifications-mail/71.40-mail-audit-event-taxonomy.yml}"
FIELDS_FILE="${FIELDS_FILE:-infrastructure/notifications-mail/71.40-mail-audit-common-fields.yml}"
RETENTION_FILE="${RETENTION_FILE:-infrastructure/notifications-mail/71.40-mail-audit-retention-policy.yml}"
CHECKLIST_FILE="${CHECKLIST_FILE:-infrastructure/notifications-mail/71.40-mail-audit-verification-checklist.template.md}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/notifications-mail/71.40-mail-audit-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$TAXONOMY_FILE" ]] || { echo "missing taxonomy: $TAXONOMY_FILE" >&2; exit 1; }
[[ -f "$FIELDS_FILE" ]] || { echo "missing fields: $FIELDS_FILE" >&2; exit 1; }
[[ -f "$RETENTION_FILE" ]] || { echo "missing retention policy: $RETENTION_FILE" >&2; exit 1; }
[[ -f "$CHECKLIST_FILE" ]] || { echo "missing checklist: $CHECKLIST_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }

grep -q "Audit Design Principles" "$DOC_FILE"
grep -q "Minimum Event Taxonomy" "$DOC_FILE"
grep -q "Mandatory Common Fields" "$DOC_FILE"
grep -q "POPIA" "$DOC_FILE"
grep -q "Retention Policy Baseline" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "NOTIF_CREATED" "$TAXONOMY_FILE"
grep -q "EMAIL_SENT" "$TAXONOMY_FILE"
grep -q "ACTION_TOKEN_ISSUED" "$TAXONOMY_FILE"
grep -q "TOKEN_REPLAY_BLOCKED" "$TAXONOMY_FILE"
grep -q "log_token_value: false" "$TAXONOMY_FILE"

grep -q "correlation_id" "$FIELDS_FILE"
grep -q "source_component" "$FIELDS_FILE"
grep -q "timezone_aware_timestamp_required: true" "$FIELDS_FILE"

grep -q "central_audit_events_days: 365" "$RETENTION_FILE"
grep -q "smtp_relay_local_logs_days: 30" "$RETENTION_FILE"
grep -q "default_recipient_logging_mode: count" "$RETENTION_FILE"
grep -q "append_only_from_app_identity: true" "$RETENTION_FILE"

grep -q "NOTIF_CREATED" "$CHECKLIST_FILE"
grep -q "TOKEN_EXPIRED" "$CHECKLIST_FILE"
grep -q "correlation_id" "$CHECKLIST_FILE"

grep -q "^CENTRAL_AUDIT_RETENTION_DAYS=" "$INPUTS_FILE"
grep -q "^SMTP_RELAY_LOG_RETENTION_DAYS=" "$INPUTS_FILE"
grep -q "^RECIPIENT_LOGGING_MODE=" "$INPUTS_FILE"
grep -q "^REJECT_REASON_LOGGING_MODE=" "$INPUTS_FILE"

echo "71.40-mail-audit-logging: verification complete"
