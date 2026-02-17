#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/70-Document-Workflow-eSign/70.50-Audit-Trail-and-Evidence-Pack.md",
    "infrastructure/workflow-esign/README.md",
    "infrastructure/workflow-esign/70.50-evidence-pack-structure.template.txt",
    "infrastructure/workflow-esign/70.50-audit-event-minimums.yml",
    "infrastructure/workflow-esign/70.50-evidence-access-policy.yml",
    "infrastructure/workflow-esign/70.50-audit-export.template.json",
    "infrastructure/workflow-esign/70.50-evidence-pack-inputs.env.example",
    "infrastructure/workflow-esign/70.50-audit-evidence-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"70.50 workflow audit-evidence artifacts missing: {', '.join(missing)}")

doc = Path("docs/70-Document-Workflow-eSign/70.50-Audit-Trail-and-Evidence-Pack.md").read_text(encoding="utf-8")
for token in [
    "Audit Trail Objectives",
    "Evidence-Pack Concept",
    "Tamper-Evidence Model",
    "Retention and Legal Hold",
    "Audit Export Procedure",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"70.50 doc missing token: {token}")

structure = Path("infrastructure/workflow-esign/70.50-evidence-pack-structure.template.txt").read_text(encoding="utf-8")
for token in ["00-summary.json", "10-workflow-instance.json", "20-approvals/", "30-signatures/", "90-export/"]:
    if token not in structure:
        raise SystemExit(f"70.50 evidence structure missing token: {token}")

events = Path("infrastructure/workflow-esign/70.50-audit-event-minimums.yml").read_text(encoding="utf-8")
for token in ["required_event_fields", "correlation_id", "document_sha256_ref", "document_content_logging_forbidden: true"]:
    if token not in events:
        raise SystemExit(f"70.50 audit event minimums missing token: {token}")

access = Path("infrastructure/workflow-esign/70.50-evidence-access-policy.yml").read_text(encoding="utf-8")
for token in ["read_only_after_completion: true", "legal_hold_blocks_purge: true", "mfa_required: true", "project_member:"]:
    if token not in access:
        raise SystemExit(f"70.50 evidence access policy missing token: {token}")

export = Path("infrastructure/workflow-esign/70.50-audit-export.template.json").read_text(encoding="utf-8")
for token in ["\"export_id\"", "\"workflow_instance_id\"", "\"verification_public_key_ref\"", "\"minimization_applied\""]:
    if token not in export:
        raise SystemExit(f"70.50 audit export template missing token: {token}")

inputs = Path("infrastructure/workflow-esign/70.50-evidence-pack-inputs.env.example").read_text(encoding="utf-8")
for token in ["EVIDENCE_PACK_ROOT=", "EVIDENCE_ACCESS_ROLES=", "EVIDENCE_RETENTION_DAYS=", "AUDIT_EXPORT_ALLOWED="]:
    if token not in inputs:
        raise SystemExit(f"70.50 evidence inputs missing token: {token}")

verify = Path("infrastructure/workflow-esign/70.50-audit-evidence-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "STRUCTURE_FILE", "EVENTS_FILE", "ACCESS_FILE", "EXPORT_FILE", "INPUTS_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"70.50 verify script missing token: {token}")

print("workflow-audit-evidence-pack-artifacts: OK")
