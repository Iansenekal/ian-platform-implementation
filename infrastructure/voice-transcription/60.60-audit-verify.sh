#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/60-Voice-Transcription/60.60-Audit-Events-Transcription.md}"
README_FILE="${README_FILE:-infrastructure/voice-transcription/README.md}"
TAXONOMY_FILE="${TAXONOMY_FILE:-infrastructure/voice-transcription/60.60-audit-event-taxonomy.yml}"
FIELDS_FILE="${FIELDS_FILE:-infrastructure/voice-transcription/60.60-audit-mandatory-fields.yml}"
ALERTS_FILE="${ALERTS_FILE:-infrastructure/voice-transcription/60.60-alert-rules.yml}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/voice-transcription/60.60-audit-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$README_FILE" ]] || { echo "missing readme: $README_FILE" >&2; exit 1; }
[[ -f "$TAXONOMY_FILE" ]] || { echo "missing taxonomy: $TAXONOMY_FILE" >&2; exit 1; }
[[ -f "$FIELDS_FILE" ]] || { echo "missing mandatory fields: $FIELDS_FILE" >&2; exit 1; }
[[ -f "$ALERTS_FILE" ]] || { echo "missing alert rules: $ALERTS_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }

grep -q "Audit Objectives" "$DOC_FILE"
grep -q "Event Taxonomy" "$DOC_FILE"
grep -q "VOICE_JOB_CREATED" "$DOC_FILE"
grep -q "VOICE_REVIEW_APPROVED" "$DOC_FILE"
grep -q "VOICE_PURGE_COMPLETED" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "VOICE_FILE_UPLOADED" "$TAXONOMY_FILE"
grep -q "VOICE_JOB_COMPLETED" "$TAXONOMY_FILE"
grep -q "VOICE_INDEX_SUCCEEDED" "$TAXONOMY_FILE"
grep -q "VOICE_EXPORT_COMPLETED" "$TAXONOMY_FILE"
grep -q "VOICE_PURGE_FAILED" "$TAXONOMY_FILE"

grep -q "mandatory_fields" "$FIELDS_FILE"
grep -q "event_id" "$FIELDS_FILE"
grep -q "correlation_id" "$FIELDS_FILE"
grep -q "content_logging_forbidden: true" "$FIELDS_FILE"

grep -q "voice_file_shared_external" "$ALERTS_FILE"
grep -q "voice_job_failed_repeated" "$ALERTS_FILE"
grep -q "voice_index_queued_without_gate" "$ALERTS_FILE"

grep -q "^AUDIT_LOG_RETENTION_DAYS=" "$INPUTS_FILE"
grep -q "^AUDIT_EVIDENCE_EVENTS=" "$INPUTS_FILE"
grep -q "^EXPORT_APPROVAL_CHAIN=" "$INPUTS_FILE"
grep -q "^RECLASSIFICATION_APPROVAL_REQUIRED=" "$INPUTS_FILE"

echo "60.60-voice-transcription-audit-events: verification complete"
