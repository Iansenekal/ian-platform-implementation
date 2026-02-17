#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/60-Voice-Transcription/60.40-RBAC-Access-Controls.md}"
README_FILE="${README_FILE:-infrastructure/voice-transcription/README.md}"
MATRIX_FILE="${MATRIX_FILE:-infrastructure/voice-transcription/60.40-role-permission-matrix.csv}"
GROUPS_FILE="${GROUPS_FILE:-infrastructure/voice-transcription/60.40-group-mapping.template.yml}"
ACL_FILE="${ACL_FILE:-infrastructure/voice-transcription/60.40-nextcloud-acl-map.csv}"
RULES_FILE="${RULES_FILE:-infrastructure/voice-transcription/60.40-api-authz-rules.yml}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/voice-transcription/60.40-rbac-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$README_FILE" ]] || { echo "missing readme: $README_FILE" >&2; exit 1; }
[[ -f "$MATRIX_FILE" ]] || { echo "missing matrix: $MATRIX_FILE" >&2; exit 1; }
[[ -f "$GROUPS_FILE" ]] || { echo "missing group mapping: $GROUPS_FILE" >&2; exit 1; }
[[ -f "$ACL_FILE" ]] || { echo "missing nextcloud acl map: $ACL_FILE" >&2; exit 1; }
[[ -f "$RULES_FILE" ]] || { echo "missing api authz rules: $RULES_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }

grep -q "Least privilege" "$DOC_FILE"
grep -q "Voice-Admin" "$DOC_FILE"
grep -q "Permission Matrix" "$DOC_FILE"
grep -q "Nextcloud Folder ACL" "$DOC_FILE"
grep -q "Gateway/API" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "capability,voice_admin" "$MATRIX_FILE"
grep -q "approve_reject_transcript" "$MATRIX_FILE"
grep -q "export_transcript" "$MATRIX_FILE"

grep -q "Voice-Admin" "$GROUPS_FILE"
grep -q "project_scope_pattern" "$GROUPS_FILE"
grep -q "mfa_required_roles" "$GROUPS_FILE"

grep -q "30-PendingReview" "$ACL_FILE"
grep -q "40-Final" "$ACL_FILE"
grep -q "90-System-Internal" "$ACL_FILE"

grep -q "require_role_and_project_scope: true" "$RULES_FILE"
grep -q "forbid_index_from_pending_review: true" "$RULES_FILE"
grep -q "export_requires_approval_event: true" "$RULES_FILE"

grep -q "^GROUPS_CLAIM_NAME=groups" "$INPUTS_FILE"
grep -q "^ROLE_GROUP_PREFIX=VOICE-ROLE-" "$INPUTS_FILE"
grep -q "^MFA_REQUIRED_ROLES=" "$INPUTS_FILE"

echo "60.40-voice-transcription-rbac: verification complete"
