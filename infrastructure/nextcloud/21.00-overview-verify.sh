#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/21-Nextcloud/21.00-Overview-RoleInPlatform.md}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/nextcloud/21.00-overview-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs file: $INPUTS_FILE" >&2; exit 1; }

grep -q "AI-DATA01" "$DOC_FILE"
grep -q "AI-FRONTEND01" "$DOC_FILE"
grep -q "Search" "$DOC_FILE"
grep -q "Knowledge Graph" "$DOC_FILE"
grep -q "RBAC" "$DOC_FILE"
grep -q "POPIA" "$DOC_FILE"

grep -q "^NEXTCLOUD_HOSTNAME=" "$INPUTS_FILE"
grep -q "^AUTH_MODE=" "$INPUTS_FILE"
grep -q "^PROJECT_GROUP_PATTERN=" "$INPUTS_FILE"

echo "21.00-nextcloud-overview: verification complete"
