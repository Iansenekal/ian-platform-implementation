#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/71-Notifications-Mail/71.10-Mail-Architecture-LAN-Only.md",
    "infrastructure/notifications-mail/README.md",
    "infrastructure/notifications-mail/71.10-mail-routing-models.yml",
    "infrastructure/notifications-mail/71.10-smtp-relay-security-baseline.yml",
    "infrastructure/notifications-mail/71.10-mail-flow-checklist.template.md",
    "infrastructure/notifications-mail/71.10-mail-architecture-inputs.env.example",
    "infrastructure/notifications-mail/71.10-mail-architecture-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"71.10 notifications/mail architecture artifacts missing: {', '.join(missing)}")

doc = Path("docs/71-Notifications-Mail/71.10-Mail-Architecture-LAN-Only.md").read_text(encoding="utf-8")
for token in [
    "Goal State Architecture",
    "Trust Boundaries",
    "Routing Models",
    "Approve/Reject Link Flow",
    "SMTP Relay Security Baseline",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"71.10 doc missing token: {token}")

models = Path("infrastructure/notifications-mail/71.10-mail-routing-models.yml").read_text(encoding="utf-8")
for token in ["default_model: A", "dedicated_postfix_relay", "ui_only_no_email", "no_public_smtp_exposure: true"]:
    if token not in models:
        raise SystemExit(f"71.10 routing models missing token: {token}")

baseline = Path("infrastructure/notifications-mail/71.10-smtp-relay-security-baseline.yml").read_text(encoding="utf-8")
for token in ["source_ip_allowlist_required: true", "open_relay_forbidden: true", "sender_domain_restrictions_required: true", "inbound:", "587"]:
    if token not in baseline:
        raise SystemExit(f"71.10 smtp baseline missing token: {token}")

checklist = Path("infrastructure/notifications-mail/71.10-mail-flow-checklist.template.md").read_text(encoding="utf-8")
for token in ["Relay reachable only from allowlisted app IPs", "Open relay test", "redirect to SSO and enforce MFA"]:
    if token not in checklist:
        raise SystemExit(f"71.10 mail flow checklist missing token: {token}")

inputs = Path("infrastructure/notifications-mail/71.10-mail-architecture-inputs.env.example").read_text(encoding="utf-8")
for token in ["MAIL_ROUTING_MODEL=", "SMTP_RELAY_HOST=", "SMTP_INBOUND_PORT=", "SMTP_AUTH_REQUIRED="]:
    if token not in inputs:
        raise SystemExit(f"71.10 inputs missing token: {token}")

verify = Path("infrastructure/notifications-mail/71.10-mail-architecture-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "MODELS_FILE", "SECURITY_FILE", "CHECKLIST_FILE", "INPUTS_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"71.10 verify script missing token: {token}")

print("notifications-mail-architecture-artifacts: OK")
