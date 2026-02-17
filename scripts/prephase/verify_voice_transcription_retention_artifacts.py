#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/60-Voice-Transcription/60.50-Retention-Policy-Voice-Transcripts.md",
    "infrastructure/voice-transcription/README.md",
    "infrastructure/voice-transcription/60.50-retention-classes.yml",
    "infrastructure/voice-transcription/60.50-retention-decision-matrix.csv",
    "infrastructure/voice-transcription/60.50-legal-hold-controls.yml",
    "infrastructure/voice-transcription/60.50-purge-evidence.template.json",
    "infrastructure/voice-transcription/60.50-retention-inputs.env.example",
    "infrastructure/voice-transcription/60.50-retention-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"60.50 voice/transcription retention artifacts missing: {', '.join(missing)}")

doc = Path("docs/60-Voice-Transcription/60.50-Retention-Policy-Voice-Transcripts.md").read_text(encoding="utf-8")
for token in ["Policy Objectives", "POPIA", "Retention Model", "Legal Hold", "Purge", "Verification Checklist"]:
    if token not in doc:
        raise SystemExit(f"60.50 doc missing token: {token}")

classes = Path("infrastructure/voice-transcription/60.50-retention-classes.yml").read_text(encoding="utf-8")
for token in ["VOICE-30D", "VOICE-90D", "VOICE-1Y", "VOICE-3Y", "VOICE-7Y", "VOICE-LEGAL-HOLD"]:
    if token not in classes:
        raise SystemExit(f"60.50 classes file missing token: {token}")

matrix = Path("infrastructure/voice-transcription/60.50-retention-decision-matrix.csv").read_text(encoding="utf-8")
for token in ["source_type,sensitivity,default_retention_class", "incident_debrief", "voice_note", "compliance_evidence_pack_recording"]:
    if token not in matrix:
        raise SystemExit(f"60.50 matrix missing token: {token}")

hold = Path("infrastructure/voice-transcription/60.50-legal-hold-controls.yml").read_text(encoding="utf-8")
for token in ["authorized_roles", "blocks_purge_until_release: true", "exception_record_required: true"]:
    if token not in hold:
        raise SystemExit(f"60.50 legal hold controls missing token: {token}")

evidence = Path("infrastructure/voice-transcription/60.50-purge-evidence.template.json").read_text(encoding="utf-8")
for token in ["recording_id", "retention_class", "deletion_status", "opensearch", "knowledge_graph"]:
    if token not in evidence:
        raise SystemExit(f"60.50 purge evidence template missing token: {token}")

inputs = Path("infrastructure/voice-transcription/60.50-retention-inputs.env.example").read_text(encoding="utf-8")
for token in ["VOICE_30D_DAYS=30", "VOICE_90D_DAYS=90", "PURGE_SCHEDULE=daily", "RETENTION_START_EVENT=created_at"]:
    if token not in inputs:
        raise SystemExit(f"60.50 inputs missing token: {token}")

verify = Path("infrastructure/voice-transcription/60.50-retention-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "CLASSES_FILE", "MATRIX_FILE", "HOLD_FILE", "EVIDENCE_FILE", "INPUTS_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"60.50 verify script missing token: {token}")

print("voice-transcription-retention-artifacts: OK")
