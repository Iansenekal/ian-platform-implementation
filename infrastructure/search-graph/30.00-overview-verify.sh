#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/30-Search-KnowledgeGraph/30.00-Overview.md}"
README_FILE="${README_FILE:-infrastructure/search-graph/README.md}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/search-graph/30.00-overview-inputs.env.example}"
CATALOG_FILE="${CATALOG_FILE:-infrastructure/search-graph/30.00-source-catalog.template.yml}"
ACL_POLICY_FILE="${ACL_POLICY_FILE:-infrastructure/search-graph/30.00-acl-enforcement-policy.yml}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$README_FILE" ]] || { echo "missing readme: $README_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }
[[ -f "$CATALOG_FILE" ]] || { echo "missing source catalog: $CATALOG_FILE" >&2; exit 1; }
[[ -f "$ACL_POLICY_FILE" ]] || { echo "missing acl policy: $ACL_POLICY_FILE" >&2; exit 1; }

grep -q "OpenSearch" "$DOC_FILE"
grep -q "Knowledge Graph" "$DOC_FILE"
grep -q "mind-map" "$DOC_FILE"
grep -q "ACL" "$DOC_FILE"
grep -q "Anti-leakage" "$DOC_FILE"
grep -q "POPIA" "$DOC_FILE"

grep -q "^OPENSEARCH_URL=" "$INPUTS_FILE"
grep -q "^GROUP_CLAIM_NAME=groups" "$INPUTS_FILE"
grep -q "^MINDMAP_ENABLED=" "$INPUTS_FILE"

grep -q "type: nextcloud" "$CATALOG_FILE"
grep -q "type: smb" "$CATALOG_FILE"
grep -q "type: m365" "$CATALOG_FILE"
grep -q "allowed_file_types" "$CATALOG_FILE"

grep -q "index_time_acl_tagging: true" "$ACL_POLICY_FILE"
grep -q "query_time_filtering: true" "$ACL_POLICY_FILE"
grep -q "hide_unauthorized_existence: true" "$ACL_POLICY_FILE"
grep -q "group_claim_name: groups" "$ACL_POLICY_FILE"

echo "30.00-search-graph-overview: verification complete"
