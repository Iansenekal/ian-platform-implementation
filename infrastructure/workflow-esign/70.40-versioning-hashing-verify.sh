#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/70-Document-Workflow-eSign/70.40-Document-Versioning-and-Hashing.md}"
README_FILE="${README_FILE:-infrastructure/workflow-esign/README.md}"
VERSION_FILE="${VERSION_FILE:-infrastructure/workflow-esign/70.40-versioning-policy.yml}"
HASH_FILE="${HASH_FILE:-infrastructure/workflow-esign/70.40-hash-standard.yml}"
SUMMARY_FILE="${SUMMARY_FILE:-infrastructure/workflow-esign/70.40-version-evidence-summary.template.json}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/workflow-esign/70.40-versioning-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$README_FILE" ]] || { echo "missing readme: $README_FILE" >&2; exit 1; }
[[ -f "$VERSION_FILE" ]] || { echo "missing versioning policy: $VERSION_FILE" >&2; exit 1; }
[[ -f "$HASH_FILE" ]] || { echo "missing hash standard: $HASH_FILE" >&2; exit 1; }
[[ -f "$SUMMARY_FILE" ]] || { echo "missing evidence summary template: $SUMMARY_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }

grep -q "Versioning Rules" "$DOC_FILE"
grep -q "Hashing Standard" "$DOC_FILE"
grep -q "Workflow Binding to Version" "$DOC_FILE"
grep -q "Rework and Approval Carry-Over" "$DOC_FILE"
grep -q "Failure Modes and Safe Defaults" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "require_version_metadata_on_submission: true" "$VERSION_FILE"
grep -q "content_bytes_changed" "$VERSION_FILE"
grep -q "rejected_rework" "$VERSION_FILE"
grep -q "if_uncertain_create_new_version: true" "$VERSION_FILE"

grep -q "hash_algorithm: SHA-256" "$HASH_FILE"
grep -q "hash_compute_location: server_side" "$HASH_FILE"
grep -q "block_approval_on_hash_failure: true" "$HASH_FILE"
grep -q "invalidate_instance_on_mid_workflow_byte_change: true" "$HASH_FILE"

grep -q '"document_id"' "$SUMMARY_FILE"
grep -q '"document_version"' "$SUMMARY_FILE"
grep -q '"document_sha256"' "$SUMMARY_FILE"
grep -q '"receipt_id"' "$SUMMARY_FILE"
grep -q '"sealed"' "$SUMMARY_FILE"

grep -q "^VERSIONING_CONVENTION=" "$INPUTS_FILE"
grep -q "^AUTHORITATIVE_FORMAT=" "$INPUTS_FILE"
grep -q "^APPROVAL_CARRY_OVER_ALLOWED=false" "$INPUTS_FILE"
grep -q "^HASH_ALGORITHM=SHA-256" "$INPUTS_FILE"

echo "70.40-workflow-versioning-hashing: verification complete"
