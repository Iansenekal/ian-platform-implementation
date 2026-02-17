#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/21-Nextcloud/21.80-Document-Lifecycle-Workflow-Integration.md}"
FOLDER_TEMPLATE_FILE="${FOLDER_TEMPLATE_FILE:-infrastructure/nextcloud/21.80-lifecycle-folder-template.txt}"
STATE_MODEL_FILE="${STATE_MODEL_FILE:-infrastructure/nextcloud/21.80-lifecycle-state-model.yml}"
MANIFEST_TEMPLATE_FILE="${MANIFEST_TEMPLATE_FILE:-infrastructure/nextcloud/21.80-evidence-pack-manifest.template.json}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/nextcloud/21.80-lifecycle-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$FOLDER_TEMPLATE_FILE" ]] || { echo "missing folder template: $FOLDER_TEMPLATE_FILE" >&2; exit 1; }
[[ -f "$STATE_MODEL_FILE" ]] || { echo "missing state model: $STATE_MODEL_FILE" >&2; exit 1; }
[[ -f "$MANIFEST_TEMPLATE_FILE" ]] || { echo "missing evidence manifest template: $MANIFEST_TEMPLATE_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs file: $INPUTS_FILE" >&2; exit 1; }

grep -q "Draft" "$DOC_FILE"
grep -q "In Review" "$DOC_FILE"
grep -q "Approved" "$DOC_FILE"
grep -q "Signed" "$DOC_FILE"
grep -q "Archived" "$DOC_FILE"
grep -q "Approve/Reject" "$DOC_FILE"
grep -q "Evidence-Pack" "$DOC_FILE"

grep -q "99-Evidence-Pack/" "$FOLDER_TEMPLATE_FILE"

grep -q "^lifecycle_states:" "$STATE_MODEL_FILE"
grep -q "Approve" "$STATE_MODEL_FILE"
grep -q "Reject" "$STATE_MODEL_FILE"
grep -q "approve_by_silence_allowed: false" "$STATE_MODEL_FILE"

grep -q '"hash_manifest"' "$MANIFEST_TEMPLATE_FILE"
grep -q '"signature_manifest"' "$MANIFEST_TEMPLATE_FILE"
grep -q '"sealed": true' "$MANIFEST_TEMPLATE_FILE"

grep -q "^EXPLICIT_APPROVAL_ACTIONS=Approve,Reject" "$INPUTS_FILE"
grep -q "^APPROVE_BY_SILENCE_ALLOWED=false" "$INPUTS_FILE"
grep -q "^HASH_ALGORITHM=SHA-256" "$INPUTS_FILE"

echo "21.80-nextcloud-lifecycle-workflow: verification complete"
