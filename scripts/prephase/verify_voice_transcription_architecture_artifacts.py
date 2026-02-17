#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/60-Voice-Transcription/60.10-Architecture-DataFlow.md",
    "infrastructure/voice-transcription/README.md",
    "infrastructure/voice-transcription/60.10-topology-options.yml",
    "infrastructure/voice-transcription/60.10-trust-boundaries.yml",
    "infrastructure/voice-transcription/60.10-data-flows.template.md",
    "infrastructure/voice-transcription/60.10-failure-modes.csv",
    "infrastructure/voice-transcription/60.10-architecture-inputs.env.example",
    "infrastructure/voice-transcription/60.10-architecture-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"60.10 voice/transcription architecture artifacts missing: {', '.join(missing)}")

doc = Path("docs/60-Voice-Transcription/60.10-Architecture-DataFlow.md").read_text(encoding="utf-8")
for token in [
    "Architecture Goals",
    "Whisper",
    "Trust Boundaries",
    "End-to-End Flows",
    "Failure Modes",
    "Acceptance Criteria",
]:
    if token not in doc:
        raise SystemExit(f"60.10 doc missing token: {token}")

topology = Path("infrastructure/voice-transcription/60.10-topology-options.yml").read_text(encoding="utf-8")
for token in ["cpu_single_worker", "gpu_dedicated_worker", "hybrid_queue_workers", "lan_only: true"]:
    if token not in topology:
        raise SystemExit(f"60.10 topology missing token: {token}")

boundaries = Path("infrastructure/voice-transcription/60.10-trust-boundaries.yml").read_text(encoding="utf-8")
for token in ["id: A", "id: E", "required_fields", "sensitivity_label", "retention_class"]:
    if token not in boundaries:
        raise SystemExit(f"60.10 boundaries missing token: {token}")

flows = Path("infrastructure/voice-transcription/60.10-data-flows.template.md").read_text(encoding="utf-8")
for token in ["Flow 1", "Flow 2", "Flow 3", "Flow 4", "ACL-filtered"]:
    if token not in flows:
        raise SystemExit(f"60.10 flows template missing token: {token}")

failures = Path("infrastructure/voice-transcription/60.10-failure-modes.csv").read_text(encoding="utf-8")
for token in ["failure_mode,impact,detection,control", "acl_drift", "sensitive_premature_indexing"]:
    if token not in failures:
        raise SystemExit(f"60.10 failure modes missing token: {token}")

inputs = Path("infrastructure/voice-transcription/60.10-architecture-inputs.env.example").read_text(encoding="utf-8")
for token in ["WORKER_MODE=", "GROUP_CLAIM_NAME=groups", "REVIEW_GATE_ENABLED=true", "NO_PUBLIC_ENDPOINTS=true"]:
    if token not in inputs:
        raise SystemExit(f"60.10 inputs template missing token: {token}")

verify = Path("infrastructure/voice-transcription/60.10-architecture-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "TOPOLOGY_FILE", "BOUNDARIES_FILE", "FLOWS_FILE", "FAILURES_FILE", "INPUTS_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"60.10 verify script missing token: {token}")

print("voice-transcription-architecture-artifacts: OK")
