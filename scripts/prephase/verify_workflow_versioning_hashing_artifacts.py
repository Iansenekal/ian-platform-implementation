#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/70-Document-Workflow-eSign/70.40-Document-Versioning-and-Hashing.md",
    "infrastructure/workflow-esign/README.md",
    "infrastructure/workflow-esign/70.40-versioning-policy.yml",
    "infrastructure/workflow-esign/70.40-hash-standard.yml",
    "infrastructure/workflow-esign/70.40-version-evidence-summary.template.json",
    "infrastructure/workflow-esign/70.40-versioning-inputs.env.example",
    "infrastructure/workflow-esign/70.40-versioning-hashing-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"70.40 workflow versioning-hashing artifacts missing: {', '.join(missing)}")

doc = Path("docs/70-Document-Workflow-eSign/70.40-Document-Versioning-and-Hashing.md").read_text(encoding="utf-8")
for token in [
    "Versioning Rules",
    "Hashing Standard",
    "Workflow Binding to Version",
    "Rework and Approval Carry-Over",
    "Failure Modes and Safe Defaults",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"70.40 doc missing token: {token}")

versioning = Path("infrastructure/workflow-esign/70.40-versioning-policy.yml").read_text(encoding="utf-8")
for token in [
    "require_version_metadata_on_submission: true",
    "content_bytes_changed",
    "rejected_rework",
    "if_uncertain_create_new_version: true",
]:
    if token not in versioning:
        raise SystemExit(f"70.40 versioning policy missing token: {token}")

hashing = Path("infrastructure/workflow-esign/70.40-hash-standard.yml").read_text(encoding="utf-8")
for token in [
    "hash_algorithm: SHA-256",
    "hash_compute_location: server_side",
    "block_approval_on_hash_failure: true",
    "invalidate_instance_on_mid_workflow_byte_change: true",
]:
    if token not in hashing:
        raise SystemExit(f"70.40 hash standard missing token: {token}")

summary = Path("infrastructure/workflow-esign/70.40-version-evidence-summary.template.json").read_text(encoding="utf-8")
for token in ["\"document_id\"", "\"document_version\"", "\"document_sha256\"", "\"receipt_id\"", "\"sealed\""]:
    if token not in summary:
        raise SystemExit(f"70.40 evidence summary template missing token: {token}")

inputs = Path("infrastructure/workflow-esign/70.40-versioning-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "VERSIONING_CONVENTION=",
    "AUTHORITATIVE_FORMAT=",
    "APPROVAL_CARRY_OVER_ALLOWED=false",
    "HASH_ALGORITHM=SHA-256",
]:
    if token not in inputs:
        raise SystemExit(f"70.40 inputs missing token: {token}")

verify = Path("infrastructure/workflow-esign/70.40-versioning-hashing-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "VERSION_FILE", "HASH_FILE", "SUMMARY_FILE", "INPUTS_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"70.40 verify script missing token: {token}")

print("workflow-versioning-hashing-artifacts: OK")
