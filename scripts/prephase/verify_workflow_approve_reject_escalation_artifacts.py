#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/70-Document-Workflow-eSign/70.11-Approve-Reject-Actions-and-Escalations.md",
    "infrastructure/workflow-esign/README.md",
    "infrastructure/workflow-esign/70.11-action-semantics.yml",
    "infrastructure/workflow-esign/70.11-sla-escalation-policy.yml",
    "infrastructure/workflow-esign/70.11-email-action-policy.yml",
    "infrastructure/workflow-esign/70.11-approve-reject-inputs.env.example",
    "infrastructure/workflow-esign/70.11-approve-reject-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"70.11 workflow approve/reject artifacts missing: {', '.join(missing)}")

doc = Path("docs/70-Document-Workflow-eSign/70.11-Approve-Reject-Actions-and-Escalations.md").read_text(encoding="utf-8")
for token in [
    "Non-Negotiable Rules",
    "No auto-approval",
    "Reject reason mandatory",
    "Step SLAs, Reminders, and Escalations",
    "Email-Based Approve/Reject",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"70.11 doc missing token: {token}")

semantics = Path("infrastructure/workflow-esign/70.11-action-semantics.yml").read_text(encoding="utf-8")
for token in ["approve:", "reject:", "required_inputs:", "reject_reason", "auto_approval_allowed: false"]:
    if token not in semantics:
        raise SystemExit(f"70.11 action semantics missing token: {token}")

sla = Path("infrastructure/workflow-esign/70.11-sla-escalation-policy.yml").read_text(encoding="utf-8")
for token in ["at_percent: 50", "at_percent: 80", "level: 1", "level: 2", "level: 3", "never_auto_approve: true"]:
    if token not in sla:
        raise SystemExit(f"70.11 SLA escalation policy missing token: {token}")

email = Path("infrastructure/workflow-esign/70.11-email-action-policy.yml").read_text(encoding="utf-8")
for token in ["signed_token_required: true", "identity_bound_token: true", "mfa_required_on_action: true", "APPROVAL_TOKEN_INVALID"]:
    if token not in email:
        raise SystemExit(f"70.11 email action policy missing token: {token}")

inputs = Path("infrastructure/workflow-esign/70.11-approve-reject-inputs.env.example").read_text(encoding="utf-8")
for token in ["REJECT_REASON_REQUIRED=true", "EMAIL_ACTION_TOKEN_TTL_MINUTES=", "MFA_REQUIRED_FOR_APPROVAL=true", "AUTO_APPROVAL_ENABLED=false"]:
    if token not in inputs:
        raise SystemExit(f"70.11 inputs missing token: {token}")

verify = Path("infrastructure/workflow-esign/70.11-approve-reject-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "SEMANTICS_FILE", "SLA_FILE", "EMAIL_FILE", "INPUTS_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"70.11 verify script missing token: {token}")

print("workflow-approve-reject-escalation-artifacts: OK")
