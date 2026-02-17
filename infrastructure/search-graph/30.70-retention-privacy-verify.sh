#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/30-Search-KnowledgeGraph/30.70-Retention-Privacy-Controls.md}"
README_FILE="${README_FILE:-infrastructure/search-graph/README.md}"
POLICY_FILE="${POLICY_FILE:-infrastructure/search-graph/30.70-retention-policy.yml}"
MATRIX_FILE="${MATRIX_FILE:-infrastructure/search-graph/30.70-content-class-retention-matrix.csv}"
SLA_FILE="${SLA_FILE:-infrastructure/search-graph/30.70-deletion-propagation-sla.yml}"
CHECKLIST_FILE="${CHECKLIST_FILE:-infrastructure/search-graph/30.70-privacy-regression-checklist.template.md}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/search-graph/30.70-retention-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$README_FILE" ]] || { echo "missing readme: $README_FILE" >&2; exit 1; }
[[ -f "$POLICY_FILE" ]] || { echo "missing policy: $POLICY_FILE" >&2; exit 1; }
[[ -f "$MATRIX_FILE" ]] || { echo "missing matrix: $MATRIX_FILE" >&2; exit 1; }
[[ -f "$SLA_FILE" ]] || { echo "missing sla: $SLA_FILE" >&2; exit 1; }
[[ -f "$CHECKLIST_FILE" ]] || { echo "missing checklist: $CHECKLIST_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }

grep -q "POPIA" "$DOC_FILE"
grep -q "metadata-first" "$DOC_FILE"
grep -q "Retention" "$DOC_FILE"
grep -q "Deletion Propagation" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "RC-01" "$POLICY_FILE"
grep -q "RC-02" "$POLICY_FILE"
grep -q "RC-03" "$POLICY_FILE"
grep -q "RC-04" "$POLICY_FILE"
grep -q "metadata_first: true" "$POLICY_FILE"
grep -q "audit_summary_required: true" "$POLICY_FILE"

grep -q "content_class,default_indexing,retention_class,notes" "$MATRIX_FILE"
grep -q "hr_personnel" "$MATRIX_FILE"
grep -q "personal_onedrive" "$MATRIX_FILE"

grep -q "source_deleted" "$SLA_FILE"
grep -q "acl_narrowed" "$SLA_FILE"
grep -q "moved_out_of_scope" "$SLA_FILE"
grep -q "purge_graph_nodes_edges: true" "$SLA_FILE"

grep -q "Metadata-only default enforced" "$CHECKLIST_FILE"
grep -q "Deletion propagation SLA test" "$CHECKLIST_FILE"
grep -q "Person/entity enrichment remains disabled" "$CHECKLIST_FILE"

grep -q "^DEFAULT_INDEXING_MODE=metadata-only" "$INPUTS_FILE"
grep -q "^RETENTION_RC01_DAYS=" "$INPUTS_FILE"
grep -q "^DELETION_PROPAGATION_SLA_HOURS=" "$INPUTS_FILE"
grep -q "^QUERY_LOGGING_LEVEL=" "$INPUTS_FILE"

echo "30.70-search-graph-retention-privacy: verification complete"
