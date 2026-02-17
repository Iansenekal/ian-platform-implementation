#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/60-Voice-Transcription/60.70-Search-Indexing-Integration.md}"
README_FILE="${README_FILE:-infrastructure/voice-transcription/README.md}"
RULES_FILE="${RULES_FILE:-infrastructure/voice-transcription/60.70-index-eligibility-rules.yml}"
MAPPING_FILE="${MAPPING_FILE:-infrastructure/voice-transcription/60.70-index-field-mapping.csv}"
ACL_FILE="${ACL_FILE:-infrastructure/voice-transcription/60.70-search-acl-policy.yml}"
GRAPH_FILE="${GRAPH_FILE:-infrastructure/voice-transcription/60.70-graph-linking-policy.yml}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/voice-transcription/60.70-search-indexing-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$README_FILE" ]] || { echo "missing readme: $README_FILE" >&2; exit 1; }
[[ -f "$RULES_FILE" ]] || { echo "missing rules: $RULES_FILE" >&2; exit 1; }
[[ -f "$MAPPING_FILE" ]] || { echo "missing mapping: $MAPPING_FILE" >&2; exit 1; }
[[ -f "$ACL_FILE" ]] || { echo "missing acl policy: $ACL_FILE" >&2; exit 1; }
[[ -f "$GRAPH_FILE" ]] || { echo "missing graph policy: $GRAPH_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }

grep -q "Indexing Eligibility Rules" "$DOC_FILE"
grep -q "ACL Inheritance Model" "$DOC_FILE"
grep -q "Knowledge Graph Linkage" "$DOC_FILE"
grep -q "Retention-Aware Indexing" "$DOC_FILE"
grep -q "Failure Handling and Reindex Strategy" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "default_indexable_folder: 40-Final" "$RULES_FILE"
grep -q "30-PendingReview" "$RULES_FILE"
grep -q "required_event: VOICE_REVIEW_APPROVED" "$RULES_FILE"
grep -q "block_on_acl_compute_error: true" "$RULES_FILE"

grep -q "recording_id" "$MAPPING_FILE"
grep -q "acl_subjects" "$MAPPING_FILE"
grep -q "transcript_text" "$MAPPING_FILE"
grep -q "Never written to audit logs" "$MAPPING_FILE"

grep -q "source_of_truth: nextcloud" "$ACL_FILE"
grep -q "gateway_filter_required: true" "$ACL_FILE"
grep -q "ui_only_filter_forbidden: true" "$ACL_FILE"
grep -q "Restricted:" "$ACL_FILE"
grep -q "enabled: false" "$ACL_FILE"

grep -q "VoiceAsset" "$GRAPH_FILE"
grep -q "Transcript" "$GRAPH_FILE"
grep -q "hide_transcript_node_if_unauthorized: true" "$GRAPH_FILE"
grep -q "no_hidden_placeholders: true" "$GRAPH_FILE"

grep -q "^VOICE_SEARCH_INDEX=" "$INPUTS_FILE"
grep -q "^VOICE_INDEXABLE_FOLDER=40-Final" "$INPUTS_FILE"
grep -q "^RESTRICTED_APPROVAL_EVENT=VOICE_REVIEW_APPROVED" "$INPUTS_FILE"
grep -q "^ACL_SUBJECT_FORMAT=" "$INPUTS_FILE"

echo "60.70-voice-search-indexing-integration: verification complete"
