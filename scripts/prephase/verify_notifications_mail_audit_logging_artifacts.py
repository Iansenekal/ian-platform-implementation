#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/71-Notifications-Mail/71.40-Audit-Logging-MailEvents.md",
    "infrastructure/notifications-mail/71.40-mail-audit-event-taxonomy.yml",
    "infrastructure/notifications-mail/71.40-mail-audit-common-fields.yml",
    "infrastructure/notifications-mail/71.40-mail-audit-retention-policy.yml",
    "infrastructure/notifications-mail/71.40-mail-audit-verification-checklist.template.md",
    "infrastructure/notifications-mail/71.40-mail-audit-inputs.env.example",
    "infrastructure/notifications-mail/71.40-mail-audit-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"71.40 mail-audit artifacts missing: {', '.join(missing)}")

doc = Path("docs/71-Notifications-Mail/71.40-Audit-Logging-MailEvents.md").read_text(encoding="utf-8")
for token in [
    "Audit Design Principles",
    "Minimum Event Taxonomy",
    "Mandatory Common Fields",
    "POPIA",
    "Retention Policy Baseline",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"71.40 doc missing token: {token}")

taxonomy = Path("infrastructure/notifications-mail/71.40-mail-audit-event-taxonomy.yml").read_text(encoding="utf-8")
for token in [
    "NOTIF_CREATED",
    "EMAIL_SENT",
    "ACTION_TOKEN_ISSUED",
    "APPROVAL_DECISION_APPROVED",
    "TOKEN_EXPIRED",
    "TOKEN_REPLAY_BLOCKED",
    "log_token_value: false",
]:
    if token not in taxonomy:
        raise SystemExit(f"71.40 taxonomy missing token: {token}")

fields = Path("infrastructure/notifications-mail/71.40-mail-audit-common-fields.yml").read_text(encoding="utf-8")
for token in [
    "correlation_id",
    "source_component",
    "severity",
    "timezone_aware_timestamp_required: true",
    "ntp_sync_required: true",
]:
    if token not in fields:
        raise SystemExit(f"71.40 common fields missing token: {token}")

retention = Path("infrastructure/notifications-mail/71.40-mail-audit-retention-policy.yml").read_text(encoding="utf-8")
for token in [
    "central_audit_events_days: 365",
    "smtp_relay_local_logs_days: 30",
    "smtp_relay_local_logs_max_days: 90",
    "default_recipient_logging_mode: count",
    "append_only_from_app_identity: true",
]:
    if token not in retention:
        raise SystemExit(f"71.40 retention policy missing token: {token}")

checklist = Path("infrastructure/notifications-mail/71.40-mail-audit-verification-checklist.template.md").read_text(encoding="utf-8")
for token in [
    "NOTIF_CREATED",
    "TOKEN_REPLAY_BLOCKED",
    "TOKEN_EXPIRED",
    "correlation_id",
]:
    if token not in checklist:
        raise SystemExit(f"71.40 checklist missing token: {token}")

inputs = Path("infrastructure/notifications-mail/71.40-mail-audit-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "CENTRAL_AUDIT_RETENTION_DAYS=",
    "SMTP_RELAY_LOG_RETENTION_DAYS=",
    "RECIPIENT_LOGGING_MODE=",
    "REJECT_REASON_LOGGING_MODE=",
]:
    if token not in inputs:
        raise SystemExit(f"71.40 inputs missing token: {token}")

verify = Path("infrastructure/notifications-mail/71.40-mail-audit-verify.sh").read_text(encoding="utf-8")
for token in [
    "DOC_FILE",
    "TAXONOMY_FILE",
    "FIELDS_FILE",
    "RETENTION_FILE",
    "CHECKLIST_FILE",
    "INPUTS_FILE",
    "grep -q",
    "verification complete",
]:
    if token not in verify:
        raise SystemExit(f"71.40 verify script missing token: {token}")

print("notifications-mail-audit-logging-artifacts: OK")
