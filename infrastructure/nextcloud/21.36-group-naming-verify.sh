#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/21-Nextcloud/21.36-Group-Naming-Convention.md}"
TAXONOMY_FILE="${TAXONOMY_FILE:-infrastructure/nextcloud/21.36-group-taxonomy.yml}"
REGISTER_FILE="${REGISTER_FILE:-infrastructure/nextcloud/21.36-project-code-register.template.csv}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/nextcloud/21.36-group-naming-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$TAXONOMY_FILE" ]] || { echo "missing taxonomy file: $TAXONOMY_FILE" >&2; exit 1; }
[[ -f "$REGISTER_FILE" ]] || { echo "missing register file: $REGISTER_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs file: $INPUTS_FILE" >&2; exit 1; }

grep -q "AI-NC-PROJ-<PROJECTCODE>-OWNER" "$DOC_FILE"
grep -q "A-Z0-9" "$DOC_FILE"
grep -q "AI-SVC-" "$DOC_FILE"
grep -q "Search/KG" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "^prefixes:" "$TAXONOMY_FILE"
grep -q "AI-NC-PROJ-<PROJECTCODE>-<ROLE>" "$TAXONOMY_FILE"
grep -q "optional_roles:" "$TAXONOMY_FILE"
grep -q "service_accounts:" "$TAXONOMY_FILE"

grep -q "^project_display_name,project_code,owner,status$" "$REGISTER_FILE"
grep -q ",BANANAPEEL," "$REGISTER_FILE"

grep -q "^GLOBAL_PREFIX=" "$INPUTS_FILE"
grep -q "^PROJECT_GROUP_PATTERN=" "$INPUTS_FILE"
grep -q "^IDP_GROUP_CLAIM_NAME=groups" "$INPUTS_FILE"

echo "21.36-nextcloud-group-naming: verification complete"
