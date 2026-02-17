#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/70-Document-Workflow-eSign/70.10-Approval-Chain-Model.md",
    "infrastructure/workflow-esign/README.md",
    "infrastructure/workflow-esign/70.10-approval-chain-template.yml",
    "infrastructure/workflow-esign/70.10-routing-inputs-schema.yml",
    "infrastructure/workflow-esign/70.10-delegation-policy.yml",
    "infrastructure/workflow-esign/70.10-approval-chain-inputs.env.example",
    "infrastructure/workflow-esign/70.10-approval-chain-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"70.10 workflow approval-chain artifacts missing: {', '.join(missing)}")

doc = Path("docs/70-Document-Workflow-eSign/70.10-Approval-Chain-Model.md").read_text(encoding="utf-8")
for token in [
    "Supported Chain Patterns",
    "Mandatory Rules",
    "No self-approval",
    "MFA required",
    "Delegation Model",
    "Reject and Rework Model",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"70.10 doc missing token: {token}")

template = Path("infrastructure/workflow-esign/70.10-approval-chain-template.yml").read_text(encoding="utf-8")
for token in [
    "explicit_decision_required: true",
    "no_self_approval: true",
    "mfa_required_for_approvers: true",
    "step_id: S1_DOCUMENT_OWNER",
    "step_id: S2_HOD",
    "step_id: S3_GM",
]:
    if token not in template:
        raise SystemExit(f"70.10 approval template missing token: {token}")

routing = Path("infrastructure/workflow-esign/70.10-routing-inputs-schema.yml").read_text(encoding="utf-8")
for token in ["required_metadata", "document_type", "project_code", "fail_closed_on_missing_required: true"]:
    if token not in routing:
        raise SystemExit(f"70.10 routing schema missing token: {token}")

delegation = Path("infrastructure/workflow-esign/70.10-delegation-policy.yml").read_text(encoding="utf-8")
for token in [
    "time_bound_required: true",
    "no_self_approval_override: false",
    "WORKFLOW_DELEGATION_CREATED",
]:
    if token not in delegation:
        raise SystemExit(f"70.10 delegation policy missing token: {token}")

inputs = Path("infrastructure/workflow-esign/70.10-approval-chain-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "WORKFLOW_TEMPLATE_ID=",
    "IDENTITY_MODE=",
    "DELEGATION_ENABLED=",
    "MFA_APPROVAL_REQUIRED=true",
    "SELF_APPROVAL_BLOCKED=true",
]:
    if token not in inputs:
        raise SystemExit(f"70.10 inputs missing token: {token}")

verify = Path("infrastructure/workflow-esign/70.10-approval-chain-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "TEMPLATE_FILE", "ROUTING_FILE", "DELEGATION_FILE", "INPUTS_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"70.10 verify script missing token: {token}")

print("workflow-approval-chain-artifacts: OK")
