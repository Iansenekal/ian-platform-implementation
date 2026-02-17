#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/60-Voice-Transcription/60.70-Search-Indexing-Integration.md",
    "infrastructure/voice-transcription/README.md",
    "infrastructure/voice-transcription/60.70-index-eligibility-rules.yml",
    "infrastructure/voice-transcription/60.70-index-field-mapping.csv",
    "infrastructure/voice-transcription/60.70-search-acl-policy.yml",
    "infrastructure/voice-transcription/60.70-graph-linking-policy.yml",
    "infrastructure/voice-transcription/60.70-search-indexing-inputs.env.example",
    "infrastructure/voice-transcription/60.70-search-indexing-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"60.70 voice/search-indexing artifacts missing: {', '.join(missing)}")

doc = Path("docs/60-Voice-Transcription/60.70-Search-Indexing-Integration.md").read_text(encoding="utf-8")
for token in [
    "Integration Goals",
    "Indexing Eligibility Rules",
    "ACL Inheritance Model",
    "Knowledge Graph Linkage Model",
    "Retention-Aware Indexing",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"60.70 doc missing token: {token}")

rules = Path("infrastructure/voice-transcription/60.70-index-eligibility-rules.yml").read_text(encoding="utf-8")
for token in [
    "default_indexable_folder: 40-Final",
    "30-PendingReview",
    "required_event: VOICE_REVIEW_APPROVED",
    "block_on_acl_compute_error: true",
]:
    if token not in rules:
        raise SystemExit(f"60.70 rules missing token: {token}")

mapping = Path("infrastructure/voice-transcription/60.70-index-field-mapping.csv").read_text(encoding="utf-8")
for token in [
    "index_field,source,purpose,notes",
    "recording_id",
    "transcript_text",
    "acl_subjects",
    "Never written to audit logs",
]:
    if token not in mapping:
        raise SystemExit(f"60.70 field mapping missing token: {token}")

acl = Path("infrastructure/voice-transcription/60.70-search-acl-policy.yml").read_text(encoding="utf-8")
for token in [
    "source_of_truth: nextcloud",
    "gateway_filter_required: true",
    "ui_only_filter_forbidden: true",
    "no_hint_on_acl_fail: true",
    "Restricted:",
]:
    if token not in acl:
        raise SystemExit(f"60.70 ACL policy missing token: {token}")

graph = Path("infrastructure/voice-transcription/60.70-graph-linking-policy.yml").read_text(encoding="utf-8")
for token in [
    "VoiceAsset",
    "Transcript",
    "hide_transcript_node_if_unauthorized: true",
    "no_hidden_placeholders: true",
    "explainable_weighting_required: true",
]:
    if token not in graph:
        raise SystemExit(f"60.70 graph policy missing token: {token}")

inputs = Path("infrastructure/voice-transcription/60.70-search-indexing-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "VOICE_SEARCH_INDEX=",
    "VOICE_INDEXABLE_FOLDER=40-Final",
    "RESTRICTED_APPROVAL_EVENT=VOICE_REVIEW_APPROVED",
    "ACL_SUBJECT_FORMAT=",
]:
    if token not in inputs:
        raise SystemExit(f"60.70 inputs missing token: {token}")

verify = Path("infrastructure/voice-transcription/60.70-search-indexing-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "RULES_FILE", "MAPPING_FILE", "ACL_FILE", "GRAPH_FILE", "INPUTS_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"60.70 verify script missing token: {token}")

print("voice-transcription-search-indexing-artifacts: OK")
