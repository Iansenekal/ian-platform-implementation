#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/70-Document-Workflow-eSign/70.50-Audit-Trail-and-Evidence-Pack.md}"
README_FILE="${README_FILE:-infrastructure/workflow-esign/README.md}"
STRUCTURE_FILE="${STRUCTURE_FILE:-infrastructure/workflow-esign/70.50-evidence-pack-structure.template.txt}"
EVENTS_FILE="${EVENTS_FILE:-infrastructure/workflow-esign/70.50-audit-event-minimums.yml}"
ACCESS_FILE="${ACCESS_FILE:-infrastructure/workflow-esign/70.50-evidence-access-policy.yml}"
EXPORT_FILE="${EXPORT_FILE:-infrastructure/workflow-esign/70.50-audit-export.template.json}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/workflow-esign/70.50-evidence-pack-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$README_FILE" ]] || { echo "missing readme: $README_FILE" >&2; exit 1; }
[[ -f "$STRUCTURE_FILE" ]] || { echo "missing structure template: $STRUCTURE_FILE" >&2; exit 1; }
[[ -f "$EVENTS_FILE" ]] || { echo "missing event minimums: $EVENTS_FILE" >&2; exit 1; }
[[ -f "$ACCESS_FILE" ]] || { echo "missing access policy: $ACCESS_FILE" >&2; exit 1; }
[[ -f "$EXPORT_FILE" ]] || { echo "missing export template: $EXPORT_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }

grep -q "Audit Trail Objectives" "$DOC_FILE"
grep -q "Evidence-Pack Concept" "$DOC_FILE"
grep -q "Tamper-Evidence Model" "$DOC_FILE"
grep -q "Retention and Legal Hold" "$DOC_FILE"
grep -q "Audit Export Procedure" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "00-summary.json" "$STRUCTURE_FILE"
grep -q "10-workflow-instance.json" "$STRUCTURE_FILE"
grep -q "20-approvals/" "$STRUCTURE_FILE"
grep -q "30-signatures/" "$STRUCTURE_FILE"
grep -q "90-export/" "$STRUCTURE_FILE"

grep -q "required_event_fields" "$EVENTS_FILE"
grep -q "correlation_id" "$EVENTS_FILE"
grep -q "document_sha256_ref" "$EVENTS_FILE"
grep -q "document_content_logging_forbidden: true" "$EVENTS_FILE"

grep -q "read_only_after_completion: true" "$ACCESS_FILE"
grep -q "legal_hold_blocks_purge: true" "$ACCESS_FILE"
grep -q "mfa_required: true" "$ACCESS_FILE"
grep -q "project_member:" "$ACCESS_FILE"

grep -q '"export_id"' "$EXPORT_FILE"
grep -q '"workflow_instance_id"' "$EXPORT_FILE"
grep -q '"verification_public_key_ref"' "$EXPORT_FILE"
grep -q '"minimization_applied"' "$EXPORT_FILE"

grep -q "^EVIDENCE_PACK_ROOT=" "$INPUTS_FILE"
grep -q "^EVIDENCE_ACCESS_ROLES=" "$INPUTS_FILE"
grep -q "^EVIDENCE_RETENTION_DAYS=" "$INPUTS_FILE"
grep -q "^AUDIT_EXPORT_ALLOWED=" "$INPUTS_FILE"

echo "70.50-workflow-audit-evidence-pack: verification complete"
