#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/60-Voice-Transcription/60.60-Audit-Events-Transcription.md",
    "infrastructure/voice-transcription/README.md",
    "infrastructure/voice-transcription/60.60-audit-event-taxonomy.yml",
    "infrastructure/voice-transcription/60.60-audit-mandatory-fields.yml",
    "infrastructure/voice-transcription/60.60-alert-rules.yml",
    "infrastructure/voice-transcription/60.60-audit-inputs.env.example",
    "infrastructure/voice-transcription/60.60-audit-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"60.60 voice/transcription audit-events artifacts missing: {', '.join(missing)}")

doc = Path("docs/60-Voice-Transcription/60.60-Audit-Events-Transcription.md").read_text(encoding="utf-8")
for token in [
    "Audit Objectives",
    "Event Taxonomy",
    "VOICE_JOB_CREATED",
    "VOICE_REVIEW_APPROVED",
    "VOICE_PURGE_COMPLETED",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"60.60 doc missing token: {token}")

taxonomy = Path("infrastructure/voice-transcription/60.60-audit-event-taxonomy.yml").read_text(encoding="utf-8")
for token in [
    "VOICE_FILE_UPLOADED",
    "VOICE_JOB_COMPLETED",
    "VOICE_REVIEW_REJECTED",
    "VOICE_INDEX_SUCCEEDED",
    "VOICE_EXPORT_COMPLETED",
    "VOICE_PURGE_FAILED",
]:
    if token not in taxonomy:
        raise SystemExit(f"60.60 taxonomy missing token: {token}")

fields = Path("infrastructure/voice-transcription/60.60-audit-mandatory-fields.yml").read_text(encoding="utf-8")
for token in ["mandatory_fields", "event_id", "correlation_id", "content_logging_forbidden: true"]:
    if token not in fields:
        raise SystemExit(f"60.60 mandatory fields file missing token: {token}")

alerts = Path("infrastructure/voice-transcription/60.60-alert-rules.yml").read_text(encoding="utf-8")
for token in ["voice_file_shared_external", "voice_job_failed_repeated", "voice_index_queued_without_gate"]:
    if token not in alerts:
        raise SystemExit(f"60.60 alert rules missing token: {token}")

inputs = Path("infrastructure/voice-transcription/60.60-audit-inputs.env.example").read_text(encoding="utf-8")
for token in ["AUDIT_LOG_RETENTION_DAYS=", "AUDIT_EVIDENCE_EVENTS=", "EXPORT_APPROVAL_CHAIN=", "RECLASSIFICATION_APPROVAL_REQUIRED="]:
    if token not in inputs:
        raise SystemExit(f"60.60 inputs missing token: {token}")

verify = Path("infrastructure/voice-transcription/60.60-audit-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "TAXONOMY_FILE", "FIELDS_FILE", "ALERTS_FILE", "INPUTS_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"60.60 verify script missing token: {token}")

print("voice-transcription-audit-events-artifacts: OK")
