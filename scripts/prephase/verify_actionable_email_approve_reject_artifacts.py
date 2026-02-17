#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/71-Notifications-Mail/71.15-Actionable-Email-Approve-Reject-Links.md",
    "infrastructure/notifications-mail/71.15-action-token-policy.yml",
    "infrastructure/notifications-mail/71.15-email-template-fields.yml",
    "infrastructure/notifications-mail/71.15-actionable-email-inputs.env.example",
    "infrastructure/notifications-mail/71.15-action-flow-checklist.template.md",
    "infrastructure/notifications-mail/71.15-actionable-email-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"71.15 actionable-email artifacts missing: {', '.join(missing)}")

doc = Path("docs/71-Notifications-Mail/71.15-Actionable-Email-Approve-Reject-Links.md").read_text(encoding="utf-8")
for token in [
    "Non-Negotiable Rules",
    "Threat Model",
    "Token Controls",
    "SSO and MFA",
    "single-use",
    "Required Audit Events",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"71.15 doc missing token: {token}")

token_policy = Path("infrastructure/notifications-mail/71.15-action-token-policy.yml").read_text(encoding="utf-8")
for token in [
    "default_ttl_minutes: 15",
    "single_use_required: true",
    "bind_to_workflow_step: true",
    "allow_decision_without_auth: false",
    "allow_decision_without_mfa: false",
]:
    if token not in token_policy:
        raise SystemExit(f"71.15 token policy missing token: {token}")

template = Path("infrastructure/notifications-mail/71.15-email-template-fields.yml").read_text(encoding="utf-8")
for token in [
    "approve_link",
    "reject_link",
    "view_details_link",
    "security_footer",
    "attachments_enabled_default: false",
    "https_only: true",
]:
    if token not in template:
        raise SystemExit(f"71.15 template fields missing token: {token}")

inputs = Path("infrastructure/notifications-mail/71.15-actionable-email-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "APPROVAL_EMAIL_ENABLED=",
    "ACTION_LINK_TTL_MINUTES=",
    "STRICT_RECIPIENT_BINDING=",
    "REJECT_REASON_CATEGORIES_REQUIRED=",
]:
    if token not in inputs:
        raise SystemExit(f"71.15 inputs missing token: {token}")

checklist = Path("infrastructure/notifications-mail/71.15-action-flow-checklist.template.md").read_text(encoding="utf-8")
for token in [
    "explicit Approve and Reject",
    "single-use",
    "Forwarded-link",
    "Expired-token flow",
]:
    if token not in checklist:
        raise SystemExit(f"71.15 checklist missing token: {token}")

verify = Path("infrastructure/notifications-mail/71.15-actionable-email-verify.sh").read_text(encoding="utf-8")
for token in [
    "DOC_FILE",
    "TOKEN_POLICY_FILE",
    "TEMPLATE_FILE",
    "CHECKLIST_FILE",
    "INPUTS_FILE",
    "grep -q",
    "verification complete",
]:
    if token not in verify:
        raise SystemExit(f"71.15 verify script missing token: {token}")

print("actionable-email-approve-reject-artifacts: OK")
