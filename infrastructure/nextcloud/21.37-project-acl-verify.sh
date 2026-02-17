#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/21-Nextcloud/21.37-Project-Folder-ACL-Blueprint.md}"
TREE_FILE="${TREE_FILE:-infrastructure/nextcloud/21.37-project-folder-template.txt}"
ACL_FILE="${ACL_FILE:-infrastructure/nextcloud/21.37-acl-blueprint.csv}"
CHECKLIST_FILE="${CHECKLIST_FILE:-infrastructure/nextcloud/21.37-onboarding-checklist.template.md}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/nextcloud/21.37-project-acl-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$TREE_FILE" ]] || { echo "missing template tree: $TREE_FILE" >&2; exit 1; }
[[ -f "$ACL_FILE" ]] || { echo "missing acl blueprint: $ACL_FILE" >&2; exit 1; }
[[ -f "$CHECKLIST_FILE" ]] || { echo "missing onboarding checklist: $CHECKLIST_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs file: $INPUTS_FILE" >&2; exit 1; }

grep -q "deny-by-default" "$DOC_FILE"
grep -q "/Projects" "$DOC_FILE"
grep -q "AI-NC-PROJ-<PROJECTCODE>-OWNER" "$DOC_FILE"
grep -q "inheritance" "$DOC_FILE"
grep -q "Search/KG" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "^/Projects/<PROJECTCODE>/$" "$TREE_FILE"
grep -q "05.30-Audit-Evidence/" "$TREE_FILE"

grep -q "^path,group,access" "$ACL_FILE"
grep -q "AI-NC-PROJ-<PROJECTCODE>-OWNER" "$ACL_FILE"
grep -q "AI-NC-PROJ-<PROJECTCODE>-VIEW" "$ACL_FILE"
grep -q "break_inheritance_optional" "$ACL_FILE"

grep -q "PROJECTCODE assigned" "$CHECKLIST_FILE"
grep -q "External sharing default remains disabled" "$CHECKLIST_FILE"

grep -q "^PROJECTS_ROOT=/Projects" "$INPUTS_FILE"
grep -q "^DEFAULT_INHERITANCE=on" "$INPUTS_FILE"
grep -q "^EXTERNAL_SHARING_DEFAULT=disabled" "$INPUTS_FILE"

echo "21.37-nextcloud-project-acl: verification complete"
