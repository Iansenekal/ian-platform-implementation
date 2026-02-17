#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/30-Search-KnowledgeGraph/30.15-ACL-and-Permissions-Inheritance.md}"
README_FILE="${README_FILE:-infrastructure/search-graph/README.md}"
POLICY_FILE="${POLICY_FILE:-infrastructure/search-graph/30.15-acl-enforcement-policy.yml}"
MAPPING_FILE="${MAPPING_FILE:-infrastructure/search-graph/30.15-principal-mapping.template.yml}"
CHECKLIST_FILE="${CHECKLIST_FILE:-infrastructure/search-graph/30.15-acl-regression-checklist.template.md}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/search-graph/30.15-acl-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$README_FILE" ]] || { echo "missing readme: $README_FILE" >&2; exit 1; }
[[ -f "$POLICY_FILE" ]] || { echo "missing policy: $POLICY_FILE" >&2; exit 1; }
[[ -f "$MAPPING_FILE" ]] || { echo "missing mapping: $MAPPING_FILE" >&2; exit 1; }
[[ -f "$CHECKLIST_FILE" ]] || { echo "missing checklist: $CHECKLIST_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }

grep -q "ACL" "$DOC_FILE"
grep -q "deny-by-default" "$DOC_FILE"
grep -q "query-time" "$DOC_FILE"
grep -q "Mind-Map" "$DOC_FILE"
grep -q "drift" "$DOC_FILE"
grep -q "Verification" "$DOC_FILE"

grep -q "deny_by_default: true" "$POLICY_FILE"
grep -q "no_acl_no_index: true" "$POLICY_FILE"
grep -q "query_time_acl_filtering: true" "$POLICY_FILE"
grep -q "both_endpoints_required: true" "$POLICY_FILE"
grep -q "no_placeholder_nodes: true" "$POLICY_FILE"

grep -q "groups_claim_name: groups" "$MAPPING_FILE"
grep -q "canonical_project_pattern" "$MAPPING_FILE"
grep -q "external_guest_indexing_allowed: false" "$MAPPING_FILE"

grep -q "No-group user returns zero results" "$CHECKLIST_FILE"
grep -q "safe fields only" "$CHECKLIST_FILE"
grep -q "no placeholder nodes" "$CHECKLIST_FILE"

grep -q "^GROUPS_CLAIM_NAME=groups" "$INPUTS_FILE"
grep -q "^DENY_BY_DEFAULT=true" "$INPUTS_FILE"
grep -q "^NO_ACL_NO_INDEX=true" "$INPUTS_FILE"
grep -q "^GRAPH_NO_PLACEHOLDERS=true" "$INPUTS_FILE"

echo "30.15-search-graph-acl-inheritance: verification complete"
