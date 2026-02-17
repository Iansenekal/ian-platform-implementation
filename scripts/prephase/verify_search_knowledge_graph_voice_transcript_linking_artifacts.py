#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/30-Search-KnowledgeGraph/30.90-Voice-Transcript-Indexing-and-Graph-Linking.md",
    "infrastructure/search-graph/README.md",
    "infrastructure/search-graph/30.90-transcript-index-schema.yml",
    "infrastructure/search-graph/30.90-graph-linking-rules.yml",
    "infrastructure/search-graph/30.90-voice-linking-inputs.env.example",
    "infrastructure/search-graph/30.90-voice-linking-verification-checklist.template.md",
    "infrastructure/search-graph/30.90-voice-transcript-linking-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"30.90 search/graph voice-transcript-linking artifacts missing: {', '.join(missing)}")

doc = Path("docs/30-Search-KnowledgeGraph/30.90-Voice-Transcript-Indexing-and-Graph-Linking.md").read_text(encoding="utf-8")
for token in [
    "Purpose",
    "ACL and Permissions",
    "Transcript Indexing Data Model",
    "Graph Linking Rules",
    "Mind-Map UI Behaviors",
    "Operational Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"30.90 doc missing token: {token}")

schema = Path("infrastructure/search-graph/30.90-transcript-index-schema.yml").read_text(encoding="utf-8")
for token in ["transcript_id", "project_id", "acl_groups", "retention_class", "raw_audio_indexing_forbidden: true"]:
    if token not in schema:
        raise SystemExit(f"30.90 schema missing token: {token}")

rules = Path("infrastructure/search-graph/30.90-graph-linking-rules.yml").read_text(encoding="utf-8")
for token in [
    "belongs_to",
    "references",
    "discusses",
    "session_filtered_graph: true",
    "rescore_after_acl_filtering: true",
]:
    if token not in rules:
        raise SystemExit(f"30.90 graph rules missing token: {token}")

inputs = Path("infrastructure/search-graph/30.90-voice-linking-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "TRANSCRIPT_INDEX_NAME=",
    "TRANSCRIPT_INDEX_SCOPE=",
    "PERSON_NODES_ENABLED=",
    "STRONG_EDGE_THRESHOLD=",
    "INFERRED_EDGE_THRESHOLD=",
]:
    if token not in inputs:
        raise SystemExit(f"30.90 inputs missing token: {token}")

checklist = Path("infrastructure/search-graph/30.90-voice-linking-verification-checklist.template.md").read_text(encoding="utf-8")
for token in [
    "Restricted transcript",
    "Unauthorized user graph view",
    "Retention purge removes transcript",
]:
    if token not in checklist:
        raise SystemExit(f"30.90 checklist missing token: {token}")

verify = Path("infrastructure/search-graph/30.90-voice-transcript-linking-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "SCHEMA_FILE", "RULES_FILE", "INPUTS_FILE", "CHECKLIST_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"30.90 verify script missing token: {token}")

print("search-knowledge-graph-voice-transcript-linking-artifacts: OK")
