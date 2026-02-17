#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/30-Search-KnowledgeGraph/30.90-Voice-Transcript-Indexing-and-Graph-Linking.md}"
README_FILE="${README_FILE:-infrastructure/search-graph/README.md}"
SCHEMA_FILE="${SCHEMA_FILE:-infrastructure/search-graph/30.90-transcript-index-schema.yml}"
RULES_FILE="${RULES_FILE:-infrastructure/search-graph/30.90-graph-linking-rules.yml}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/search-graph/30.90-voice-linking-inputs.env.example}"
CHECKLIST_FILE="${CHECKLIST_FILE:-infrastructure/search-graph/30.90-voice-linking-verification-checklist.template.md}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$README_FILE" ]] || { echo "missing readme: $README_FILE" >&2; exit 1; }
[[ -f "$SCHEMA_FILE" ]] || { echo "missing schema: $SCHEMA_FILE" >&2; exit 1; }
[[ -f "$RULES_FILE" ]] || { echo "missing graph rules: $RULES_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }
[[ -f "$CHECKLIST_FILE" ]] || { echo "missing checklist: $CHECKLIST_FILE" >&2; exit 1; }

grep -q "Purpose" "$DOC_FILE"
grep -q "ACL and Permissions" "$DOC_FILE"
grep -q "Transcript Indexing Data Model" "$DOC_FILE"
grep -q "Graph Linking Rules" "$DOC_FILE"
grep -q "Mind-Map UI Behaviors" "$DOC_FILE"
grep -q "Operational Verification Checklist" "$DOC_FILE"

grep -q "transcript_id" "$SCHEMA_FILE"
grep -q "project_id" "$SCHEMA_FILE"
grep -q "acl_groups" "$SCHEMA_FILE"
grep -q "retention_class" "$SCHEMA_FILE"
grep -q "raw_audio_indexing_forbidden: true" "$SCHEMA_FILE"

grep -q "belongs_to" "$RULES_FILE"
grep -q "references" "$RULES_FILE"
grep -q "discusses" "$RULES_FILE"
grep -q "session_filtered_graph: true" "$RULES_FILE"
grep -q "rescore_after_acl_filtering: true" "$RULES_FILE"

grep -q "^TRANSCRIPT_INDEX_NAME=" "$INPUTS_FILE"
grep -q "^TRANSCRIPT_INDEX_SCOPE=" "$INPUTS_FILE"
grep -q "^PERSON_NODES_ENABLED=" "$INPUTS_FILE"
grep -q "^STRONG_EDGE_THRESHOLD=" "$INPUTS_FILE"
grep -q "^INFERRED_EDGE_THRESHOLD=" "$INPUTS_FILE"

grep -q "Restricted transcript" "$CHECKLIST_FILE"
grep -q "Unauthorized user graph view" "$CHECKLIST_FILE"
grep -q "Retention purge removes transcript" "$CHECKLIST_FILE"

echo "30.90-search-voice-transcript-linking: verification complete"
