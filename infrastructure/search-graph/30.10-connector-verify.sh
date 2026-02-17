#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/30-Search-KnowledgeGraph/30.10-Sources-and-Connectors.md}"
README_FILE="${README_FILE:-infrastructure/search-graph/README.md}"
INVENTORY_FILE="${INVENTORY_FILE:-infrastructure/search-graph/30.10-connector-inventory.template.yml}"
CHECKLIST_FILE="${CHECKLIST_FILE:-infrastructure/search-graph/30.10-connector-onboarding-checklist.template.md}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/search-graph/30.10-connector-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$README_FILE" ]] || { echo "missing readme: $README_FILE" >&2; exit 1; }
[[ -f "$INVENTORY_FILE" ]] || { echo "missing inventory: $INVENTORY_FILE" >&2; exit 1; }
[[ -f "$CHECKLIST_FILE" ]] || { echo "missing checklist: $CHECKLIST_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }

grep -q "Connector" "$DOC_FILE"
grep -q "ACL" "$DOC_FILE"
grep -q "Nextcloud" "$DOC_FILE"
grep -q "SMB" "$DOC_FILE"
grep -q "Microsoft 365" "$DOC_FILE"
grep -q "minimization" "$DOC_FILE"

grep -q "source_type: nextcloud" "$INVENTORY_FILE"
grep -q "source_type: smb" "$INVENTORY_FILE"
grep -q "source_type: m365" "$INVENTORY_FILE"
grep -q "acl_required: true" "$INVENTORY_FILE"
grep -q "indexing_mode: metadata_default" "$INVENTORY_FILE"

grep -q "ACL deny tests" "$CHECKLIST_FILE"
grep -q "non-human service identity" "$CHECKLIST_FILE"
grep -q "change control" "$CHECKLIST_FILE"

grep -q "^ENABLED_CONNECTORS=" "$INPUTS_FILE"
grep -q "^METADATA_ONLY_DEFAULT=true" "$INPUTS_FILE"
grep -q "^GROUP_CLAIM_NAME=groups" "$INPUTS_FILE"
grep -q "^SECRETS_PATH=/opt/<stack>/secrets" "$INPUTS_FILE"

echo "30.10-search-graph-connectors: verification complete"
