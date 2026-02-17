#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/71-Notifications-Mail/71.50-Retention-MailEvidence.md",
    "infrastructure/notifications-mail/71.50-mail-evidence-retention-schedule.yml",
    "infrastructure/notifications-mail/71.50-mail-evidence-legal-hold-policy.yml",
    "infrastructure/notifications-mail/71.50-mail-evidence-purge-controls.yml",
    "infrastructure/notifications-mail/71.50-mail-evidence-retention-inputs.env.example",
    "infrastructure/notifications-mail/71.50-mail-evidence-verification-checklist.template.md",
    "infrastructure/notifications-mail/71.50-mail-evidence-retention-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"71.50 mail-retention artifacts missing: {', '.join(missing)}")

doc = Path("docs/71-Notifications-Mail/71.50-Retention-MailEvidence.md").read_text(encoding="utf-8")
for token in [
    "Retention Goals",
    "Mail-Evidence Scope",
    "Must-Not-Retain",
    "Retention Schedule Baseline",
    "Legal Hold and Exceptions",
    "Purge and Disposal Rules",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"71.50 doc missing token: {token}")

schedule = Path("infrastructure/notifications-mail/71.50-mail-evidence-retention-schedule.yml").read_text(encoding="utf-8")
for token in [
    "central_notification_audit_days: 365",
    "smtp_relay_logs_days: 30",
    "action_token_metadata_days: 365",
    "retain_email_bodies_as_evidence: false",
    "retain_tokenized_action_links: false",
]:
    if token not in schedule:
        raise SystemExit(f"71.50 schedule missing token: {token}")

hold = Path("infrastructure/notifications-mail/71.50-mail-evidence-legal-hold-policy.yml").read_text(encoding="utf-8")
for token in [
    "supported: true",
    "correlation_id",
    "retain_email_body_required: false",
    "exception_time_box_required: true",
]:
    if token not in hold:
        raise SystemExit(f"71.50 legal hold policy missing token: {token}")

purge = Path("infrastructure/notifications-mail/71.50-mail-evidence-purge-controls.yml").read_text(encoding="utf-8")
for token in [
    "automated_required: true",
    "PurgeStarted",
    "PurgeCompleted",
    "central_logs_lifecycle_expiry_required: true",
    "central_message_body_logging_allowed: false",
]:
    if token not in purge:
        raise SystemExit(f"71.50 purge controls missing token: {token}")

inputs = Path("infrastructure/notifications-mail/71.50-mail-evidence-retention-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "CENTRAL_AUDIT_RETENTION_DAYS=",
    "SMTP_RELAY_LOG_RETENTION_DAYS=",
    "RECIPIENT_LOGGING_MODE=",
    "LEGAL_HOLD_APPROVER_GROUP=",
    "PURGE_WINDOW=",
]:
    if token not in inputs:
        raise SystemExit(f"71.50 inputs missing token: {token}")

checklist = Path("infrastructure/notifications-mail/71.50-mail-evidence-verification-checklist.template.md").read_text(encoding="utf-8")
for token in [
    "PurgeStarted",
    "PurgeCompleted",
    "Legal hold",
    "do not retain email bodies",
]:
    if token not in checklist:
        raise SystemExit(f"71.50 checklist missing token: {token}")

verify = Path("infrastructure/notifications-mail/71.50-mail-evidence-retention-verify.sh").read_text(encoding="utf-8")
for token in [
    "DOC_FILE",
    "SCHEDULE_FILE",
    "HOLD_FILE",
    "PURGE_FILE",
    "INPUTS_FILE",
    "CHECKLIST_FILE",
    "grep -q",
    "verification complete",
]:
    if token not in verify:
        raise SystemExit(f"71.50 verify script missing token: {token}")

print("notifications-mail-retention-artifacts: OK")
