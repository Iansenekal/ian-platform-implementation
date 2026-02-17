#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/21-Nextcloud/21.35-Permissions-Model-and-Roles.md}"
ROLE_CATALOG_FILE="${ROLE_CATALOG_FILE:-infrastructure/nextcloud/21.35-role-catalog.yml}"
MATRIX_FILE="${MATRIX_FILE:-infrastructure/nextcloud/21.35-permission-matrix.csv}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/nextcloud/21.35-permissions-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$ROLE_CATALOG_FILE" ]] || { echo "missing role catalog: $ROLE_CATALOG_FILE" >&2; exit 1; }
[[ -f "$MATRIX_FILE" ]] || { echo "missing permission matrix: $MATRIX_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs file: $INPUTS_FILE" >&2; exit 1; }

grep -q "deny-by-default" "$DOC_FILE"
grep -q "Project-Viewer" "$DOC_FILE"
grep -q "service accounts" "$DOC_FILE"
grep -q "external sharing disabled" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "default_stance: deny_by_default" "$ROLE_CATALOG_FILE"
grep -q "NC_PLATFORM_ADMIN" "$ROLE_CATALOG_FILE"
grep -q "PROJECT_OWNER" "$ROLE_CATALOG_FILE"
grep -q "SEARCH_INDEXER_SERVICE" "$ROLE_CATALOG_FILE"

grep -q "^action,platform_admin" "$MATRIX_FILE"
grep -q "^manage_nextcloud_settings_apps,yes" "$MATRIX_FILE"
grep -q "^grant_revoke_project_access,no,no,no,yes" "$MATRIX_FILE"
grep -q "^create_external_share_links,no,no,no,exception_only" "$MATRIX_FILE"

grep -q "^PLATFORM_ADMIN_GROUP=" "$INPUTS_FILE"
grep -q "^PROJECT_GROUP_PATTERN=" "$INPUTS_FILE"
grep -q "^DEFAULT_EXTERNAL_SHARING=disabled" "$INPUTS_FILE"
grep -q "^ACCESS_REVIEW_CADENCE=" "$INPUTS_FILE"

echo "21.35-nextcloud-permissions: verification complete"
