#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/60-Voice-Transcription/60.30-Storage-Model-Nextcloud-Folders.md}"
README_FILE="${README_FILE:-infrastructure/voice-transcription/README.md}"
BLUEPRINT_FILE="${BLUEPRINT_FILE:-infrastructure/voice-transcription/60.30-folder-blueprint.txt}"
STATE_FILE="${STATE_FILE:-infrastructure/voice-transcription/60.30-state-transitions.yml}"
SCHEMA_FILE="${SCHEMA_FILE:-infrastructure/voice-transcription/60.30-metadata-schema.template.json}"
NAMING_FILE="${NAMING_FILE:-infrastructure/voice-transcription/60.30-naming-convention.md}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/voice-transcription/60.30-storage-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$README_FILE" ]] || { echo "missing readme: $README_FILE" >&2; exit 1; }
[[ -f "$BLUEPRINT_FILE" ]] || { echo "missing blueprint: $BLUEPRINT_FILE" >&2; exit 1; }
[[ -f "$STATE_FILE" ]] || { echo "missing state model: $STATE_FILE" >&2; exit 1; }
[[ -f "$SCHEMA_FILE" ]] || { echo "missing schema: $SCHEMA_FILE" >&2; exit 1; }
[[ -f "$NAMING_FILE" ]] || { echo "missing naming: $NAMING_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }

grep -q "Nextcloud is the single source of truth" "$DOC_FILE"
grep -q "folder" "$DOC_FILE"
grep -q "Naming Conventions" "$DOC_FILE"
grep -q "metadata sidecar" "$DOC_FILE"
grep -q "State Model" "$DOC_FILE"
grep -q "Search/Graph" "$DOC_FILE"

grep -q "10-Intake" "$BLUEPRINT_FILE"
grep -q "30-PendingReview" "$BLUEPRINT_FILE"
grep -q "40-Final" "$BLUEPRINT_FILE"
grep -q "50-Evidence-Pack" "$BLUEPRINT_FILE"

grep -q "to: Work-InProgress" "$STATE_FILE"
grep -q "condition: review_required=true" "$STATE_FILE"
grep -q "default_folder: Final" "$STATE_FILE"
grep -q "audit_required: true" "$STATE_FILE"

grep -q '"recording_id"' "$SCHEMA_FILE"
grep -q '"retention_class"' "$SCHEMA_FILE"
grep -q '"indexing_mode"' "$SCHEMA_FILE"
grep -q '"allowed_groups"' "$SCHEMA_FILE"

grep -q "Audio:" "$NAMING_FILE"
grep -q "Transcript:" "$NAMING_FILE"
grep -q "Metadata:" "$NAMING_FILE"

grep -q "^INDEX_FROM_FOLDER=40-Final" "$INPUTS_FILE"
grep -q "^REVIEW_REQUIRED_DEFAULT=true" "$INPUTS_FILE"
grep -q "^WORK_IN_PROGRESS_BACKUP=true" "$INPUTS_FILE"

echo "60.30-voice-transcription-storage: verification complete"
