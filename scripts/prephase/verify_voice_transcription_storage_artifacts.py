#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/60-Voice-Transcription/60.30-Storage-Model-Nextcloud-Folders.md",
    "infrastructure/voice-transcription/README.md",
    "infrastructure/voice-transcription/60.30-folder-blueprint.txt",
    "infrastructure/voice-transcription/60.30-state-transitions.yml",
    "infrastructure/voice-transcription/60.30-metadata-schema.template.json",
    "infrastructure/voice-transcription/60.30-naming-convention.md",
    "infrastructure/voice-transcription/60.30-storage-inputs.env.example",
    "infrastructure/voice-transcription/60.30-storage-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"60.30 voice/transcription storage artifacts missing: {', '.join(missing)}")

doc = Path("docs/60-Voice-Transcription/60.30-Storage-Model-Nextcloud-Folders.md").read_text(encoding="utf-8")
for token in [
    "Nextcloud is the single source of truth",
    "State Model",
    "Naming Conventions",
    "metadata sidecar",
    "Search/Graph",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"60.30 doc missing token: {token}")

blueprint = Path("infrastructure/voice-transcription/60.30-folder-blueprint.txt").read_text(encoding="utf-8")
for token in ["10-Intake", "20-Work-InProgress", "30-PendingReview", "40-Final", "50-Evidence-Pack", "90-System-Internal"]:
    if token not in blueprint:
        raise SystemExit(f"60.30 folder blueprint missing token: {token}")

state = Path("infrastructure/voice-transcription/60.30-state-transitions.yml").read_text(encoding="utf-8")
for token in ["to: Work-InProgress", "condition: review_required=true", "default_folder: Final", "audit_required: true"]:
    if token not in state:
        raise SystemExit(f"60.30 state transitions missing token: {token}")

schema = Path("infrastructure/voice-transcription/60.30-metadata-schema.template.json").read_text(encoding="utf-8")
for token in ["recording_id", "retention_class", "indexing_mode", "allowed_groups", "language"]:
    if token not in schema:
        raise SystemExit(f"60.30 metadata schema missing token: {token}")

naming = Path("infrastructure/voice-transcription/60.30-naming-convention.md").read_text(encoding="utf-8")
for token in ["Audio:", "Transcript:", "Metadata:", "Job Receipt:"]:
    if token not in naming:
        raise SystemExit(f"60.30 naming convention missing token: {token}")

inputs = Path("infrastructure/voice-transcription/60.30-storage-inputs.env.example").read_text(encoding="utf-8")
for token in ["INDEX_FROM_FOLDER=40-Final", "REVIEW_REQUIRED_DEFAULT=true", "WORK_IN_PROGRESS_BACKUP=true", "EVIDENCE_PACK_BACKUP_PRIORITY=high"]:
    if token not in inputs:
        raise SystemExit(f"60.30 storage inputs missing token: {token}")

verify = Path("infrastructure/voice-transcription/60.30-storage-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "BLUEPRINT_FILE", "STATE_FILE", "SCHEMA_FILE", "NAMING_FILE", "INPUTS_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"60.30 verify script missing token: {token}")

print("voice-transcription-storage-artifacts: OK")
