#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/21-Nextcloud/21.81-eSign-Integration-Options.md}"
MATRIX_FILE="${MATRIX_FILE:-infrastructure/nextcloud/21.81-esign-options-matrix.yml}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/nextcloud/21.81-esign-inputs.env.example}"
CHECKLIST_FILE="${CHECKLIST_FILE:-infrastructure/nextcloud/21.81-signature-verification-checklist.template.md}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$MATRIX_FILE" ]] || { echo "missing matrix file: $MATRIX_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs file: $INPUTS_FILE" >&2; exit 1; }
[[ -f "$CHECKLIST_FILE" ]] || { echo "missing checklist file: $CHECKLIST_FILE" >&2; exit 1; }

grep -q "Option A" "$DOC_FILE"
grep -q "Option B" "$DOC_FILE"
grep -q "Option C" "$DOC_FILE"
grep -q "Option D" "$DOC_FILE"
grep -q "SSO + MFA" "$DOC_FILE"
grep -q "Evidence-Pack" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "^options:" "$MATRIX_FILE"
grep -q "^  A:" "$MATRIX_FILE"
grep -q "^  B:" "$MATRIX_FILE"
grep -q "^  C:" "$MATRIX_FILE"
grep -q "^  D:" "$MATRIX_FILE"
grep -q "allowed_default: false" "$MATRIX_FILE"

grep -q "^MFA_STEP_UP_AT_SIGNING=true" "$INPUTS_FILE"
grep -q "^INTERNAL_PKI_PRESENT=" "$INPUTS_FILE"
grep -q "^SIGNED_FOLDER_SEALING=" "$INPUTS_FILE"

grep -q "explicit \`Approve\` or \`Reject\`" "$CHECKLIST_FILE"
grep -q "sealed read-only" "$CHECKLIST_FILE"

echo "21.81-nextcloud-esign-options: verification complete"
