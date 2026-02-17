#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/60-Voice-Transcription/60.50-Retention-Policy-Voice-Transcripts.md}"
README_FILE="${README_FILE:-infrastructure/voice-transcription/README.md}"
CLASSES_FILE="${CLASSES_FILE:-infrastructure/voice-transcription/60.50-retention-classes.yml}"
MATRIX_FILE="${MATRIX_FILE:-infrastructure/voice-transcription/60.50-retention-decision-matrix.csv}"
HOLD_FILE="${HOLD_FILE:-infrastructure/voice-transcription/60.50-legal-hold-controls.yml}"
EVIDENCE_FILE="${EVIDENCE_FILE:-infrastructure/voice-transcription/60.50-purge-evidence.template.json}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/voice-transcription/60.50-retention-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$README_FILE" ]] || { echo "missing readme: $README_FILE" >&2; exit 1; }
[[ -f "$CLASSES_FILE" ]] || { echo "missing classes: $CLASSES_FILE" >&2; exit 1; }
[[ -f "$MATRIX_FILE" ]] || { echo "missing matrix: $MATRIX_FILE" >&2; exit 1; }
[[ -f "$HOLD_FILE" ]] || { echo "missing hold controls: $HOLD_FILE" >&2; exit 1; }
[[ -f "$EVIDENCE_FILE" ]] || { echo "missing purge evidence template: $EVIDENCE_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }

grep -q "Policy Objectives" "$DOC_FILE"
grep -q "POPIA" "$DOC_FILE"
grep -q "Retention Model" "$DOC_FILE"
grep -q "Legal Hold" "$DOC_FILE"
grep -q "Purge" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "VOICE-30D" "$CLASSES_FILE"
grep -q "VOICE-90D" "$CLASSES_FILE"
grep -q "VOICE-1Y" "$CLASSES_FILE"
grep -q "VOICE-3Y" "$CLASSES_FILE"
grep -q "VOICE-7Y" "$CLASSES_FILE"
grep -q "VOICE-LEGAL-HOLD" "$CLASSES_FILE"

grep -q "source_type,sensitivity,default_retention_class" "$MATRIX_FILE"
grep -q "incident_debrief" "$MATRIX_FILE"
grep -q "compliance_evidence_pack_recording" "$MATRIX_FILE"

grep -q "authorized_roles" "$HOLD_FILE"
grep -q "blocks_purge_until_release: true" "$HOLD_FILE"
grep -q "exception_record_required: true" "$HOLD_FILE"

grep -q '"recording_id"' "$EVIDENCE_FILE"
grep -q '"retention_class"' "$EVIDENCE_FILE"
grep -q '"deletion_status"' "$EVIDENCE_FILE"
grep -q '"opensearch"' "$EVIDENCE_FILE"

grep -q "^VOICE_30D_DAYS=30" "$INPUTS_FILE"
grep -q "^VOICE_90D_DAYS=90" "$INPUTS_FILE"
grep -q "^PURGE_SCHEDULE=daily" "$INPUTS_FILE"
grep -q "^RETENTION_START_EVENT=created_at" "$INPUTS_FILE"

echo "60.50-voice-transcription-retention: verification complete"
