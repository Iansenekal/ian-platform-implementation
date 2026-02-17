#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/71-Notifications-Mail/71.50-Retention-MailEvidence.md}"
SCHEDULE_FILE="${SCHEDULE_FILE:-infrastructure/notifications-mail/71.50-mail-evidence-retention-schedule.yml}"
HOLD_FILE="${HOLD_FILE:-infrastructure/notifications-mail/71.50-mail-evidence-legal-hold-policy.yml}"
PURGE_FILE="${PURGE_FILE:-infrastructure/notifications-mail/71.50-mail-evidence-purge-controls.yml}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/notifications-mail/71.50-mail-evidence-retention-inputs.env.example}"
CHECKLIST_FILE="${CHECKLIST_FILE:-infrastructure/notifications-mail/71.50-mail-evidence-verification-checklist.template.md}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$SCHEDULE_FILE" ]] || { echo "missing schedule: $SCHEDULE_FILE" >&2; exit 1; }
[[ -f "$HOLD_FILE" ]] || { echo "missing legal hold policy: $HOLD_FILE" >&2; exit 1; }
[[ -f "$PURGE_FILE" ]] || { echo "missing purge controls: $PURGE_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }
[[ -f "$CHECKLIST_FILE" ]] || { echo "missing checklist: $CHECKLIST_FILE" >&2; exit 1; }

grep -q "Retention Goals" "$DOC_FILE"
grep -q "Must-Not-Retain" "$DOC_FILE"
grep -q "Retention Schedule Baseline" "$DOC_FILE"
grep -q "Legal Hold and Exceptions" "$DOC_FILE"
grep -q "Purge and Disposal Rules" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "central_notification_audit_days: 365" "$SCHEDULE_FILE"
grep -q "smtp_relay_logs_days: 30" "$SCHEDULE_FILE"
grep -q "action_token_metadata_days: 365" "$SCHEDULE_FILE"
grep -q "retain_email_bodies_as_evidence: false" "$SCHEDULE_FILE"

grep -q "supported: true" "$HOLD_FILE"
grep -q "correlation_id" "$HOLD_FILE"
grep -q "retain_email_body_required: false" "$HOLD_FILE"

grep -q "automated_required: true" "$PURGE_FILE"
grep -q "PurgeStarted" "$PURGE_FILE"
grep -q "PurgeCompleted" "$PURGE_FILE"
grep -q "central_message_body_logging_allowed: false" "$PURGE_FILE"

grep -q "^CENTRAL_AUDIT_RETENTION_DAYS=" "$INPUTS_FILE"
grep -q "^SMTP_RELAY_LOG_RETENTION_DAYS=" "$INPUTS_FILE"
grep -q "^RECIPIENT_LOGGING_MODE=" "$INPUTS_FILE"
grep -q "^PURGE_WINDOW=" "$INPUTS_FILE"

grep -q "PurgeStarted" "$CHECKLIST_FILE"
grep -q "PurgeCompleted" "$CHECKLIST_FILE"
grep -q "Legal hold" "$CHECKLIST_FILE"
grep -q "do not retain email bodies" "$CHECKLIST_FILE"

echo "71.50-mail-evidence-retention: verification complete"
