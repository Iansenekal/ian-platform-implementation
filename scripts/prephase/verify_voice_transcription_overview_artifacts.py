#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/60-Voice-Transcription/60.00-Overview.md",
    "infrastructure/voice-transcription/README.md",
    "infrastructure/voice-transcription/60.00-overview-inputs.env.example",
    "infrastructure/voice-transcription/60.00-role-map.yml",
    "infrastructure/voice-transcription/60.00-data-lifecycle.template.yml",
    "infrastructure/voice-transcription/60.00-overview-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"60.00 voice/transcription overview artifacts missing: {', '.join(missing)}")

doc = Path("docs/60-Voice-Transcription/60.00-Overview.md").read_text(encoding="utf-8")
for token in [
    "Whisper",
    "POPIA",
    "LAN-only",
    "Nextcloud",
    "Search",
    "Knowledge Graph",
    "Definition of Done",
]:
    if token not in doc:
        raise SystemExit(f"60.00 doc missing token: {token}")

inputs = Path("infrastructure/voice-transcription/60.00-overview-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "ASR_ENGINE=whisper",
    "GROUP_CLAIM_NAME=groups",
    "MODEL_ORIGIN_POLICY=US_EU_ONLY",
    "RETENTION_POLICY_REF=03.40",
]:
    if token not in inputs:
        raise SystemExit(f"60.00 inputs template missing token: {token}")

roles = Path("infrastructure/voice-transcription/60.00-role-map.yml").read_text(encoding="utf-8")
for token in ["Voice-Admin", "Voice-Operator", "Voice-Contributor", "least_privilege_enforced: true"]:
    if token not in roles:
        raise SystemExit(f"60.00 role map missing token: {token}")

lifecycle = Path("infrastructure/voice-transcription/60.00-data-lifecycle.template.yml").read_text(encoding="utf-8")
for token in ["stage: transcribe", "stage: index", "stage: retain_purge", "deny_by_default: true"]:
    if token not in lifecycle:
        raise SystemExit(f"60.00 lifecycle template missing token: {token}")

verify = Path("infrastructure/voice-transcription/60.00-overview-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "INPUTS_FILE", "ROLE_FILE", "LIFECYCLE_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"60.00 verify script missing token: {token}")

print("voice-transcription-overview-artifacts: OK")
