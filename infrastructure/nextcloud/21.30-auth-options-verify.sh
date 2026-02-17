#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/21-Nextcloud/21.30-Auth-Options-AD-vs-SSO.md}"
MATRIX_FILE="${MATRIX_FILE:-infrastructure/nextcloud/21.30-auth-decision-matrix.yml}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/nextcloud/21.30-auth-options-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$MATRIX_FILE" ]] || { echo "missing matrix file: $MATRIX_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs file: $INPUTS_FILE" >&2; exit 1; }

grep -q "SSO via platform IdP" "$DOC_FILE"
grep -q "AD/LDAPS" "$DOC_FILE"
grep -q "Local users" "$DOC_FILE"
grep -q "MFA" "$DOC_FILE"
grep -q "break-glass" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "^default_mode:" "$MATRIX_FILE"
grep -q "^  SSO:" "$MATRIX_FILE"
grep -q "^  AD_LDAPS:" "$MATRIX_FILE"
grep -q "^  LOCAL_USERS:" "$MATRIX_FILE"

grep -q "^SELECTED_AUTH_MODE=" "$INPUTS_FILE"
grep -q "^SSO_PROTOCOL=" "$INPUTS_FILE"
grep -q "^LDAPS_PORT=636" "$INPUTS_FILE"
grep -q "^PROJECT_GROUP_PATTERN=" "$INPUTS_FILE"

echo "21.30-nextcloud-auth-options: verification complete"
