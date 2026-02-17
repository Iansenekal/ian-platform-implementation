#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/60-Voice-Transcription/60.00-Overview.md}"
README_FILE="${README_FILE:-infrastructure/voice-transcription/README.md}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/voice-transcription/60.00-overview-inputs.env.example}"
ROLE_FILE="${ROLE_FILE:-infrastructure/voice-transcription/60.00-role-map.yml}"
LIFECYCLE_FILE="${LIFECYCLE_FILE:-infrastructure/voice-transcription/60.00-data-lifecycle.template.yml}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$README_FILE" ]] || { echo "missing readme: $README_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }
[[ -f "$ROLE_FILE" ]] || { echo "missing role map: $ROLE_FILE" >&2; exit 1; }
[[ -f "$LIFECYCLE_FILE" ]] || { echo "missing lifecycle template: $LIFECYCLE_FILE" >&2; exit 1; }

grep -q "Whisper" "$DOC_FILE"
grep -q "POPIA" "$DOC_FILE"
grep -q "LAN-only" "$DOC_FILE"
grep -q "Nextcloud" "$DOC_FILE"
grep -q "Search" "$DOC_FILE"
grep -q "Knowledge Graph" "$DOC_FILE"
grep -q "Definition of Done" "$DOC_FILE"

grep -q "^ASR_ENGINE=whisper" "$INPUTS_FILE"
grep -q "^GROUP_CLAIM_NAME=groups" "$INPUTS_FILE"
grep -q "^MODEL_ORIGIN_POLICY=US_EU_ONLY" "$INPUTS_FILE"

grep -q "Voice-Admin" "$ROLE_FILE"
grep -q "Voice-Operator" "$ROLE_FILE"
grep -q "least_privilege_enforced: true" "$ROLE_FILE"

grep -q "stage: transcribe" "$LIFECYCLE_FILE"
grep -q "stage: index" "$LIFECYCLE_FILE"
grep -q "deny_by_default: true" "$LIFECYCLE_FILE"

echo "60.00-voice-transcription-overview: verification complete"
