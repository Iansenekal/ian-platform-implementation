#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/60-Voice-Transcription/60.10-Architecture-DataFlow.md}"
README_FILE="${README_FILE:-infrastructure/voice-transcription/README.md}"
TOPOLOGY_FILE="${TOPOLOGY_FILE:-infrastructure/voice-transcription/60.10-topology-options.yml}"
BOUNDARIES_FILE="${BOUNDARIES_FILE:-infrastructure/voice-transcription/60.10-trust-boundaries.yml}"
FLOWS_FILE="${FLOWS_FILE:-infrastructure/voice-transcription/60.10-data-flows.template.md}"
FAILURES_FILE="${FAILURES_FILE:-infrastructure/voice-transcription/60.10-failure-modes.csv}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/voice-transcription/60.10-architecture-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$README_FILE" ]] || { echo "missing readme: $README_FILE" >&2; exit 1; }
[[ -f "$TOPOLOGY_FILE" ]] || { echo "missing topology file: $TOPOLOGY_FILE" >&2; exit 1; }
[[ -f "$BOUNDARIES_FILE" ]] || { echo "missing boundaries file: $BOUNDARIES_FILE" >&2; exit 1; }
[[ -f "$FLOWS_FILE" ]] || { echo "missing flows file: $FLOWS_FILE" >&2; exit 1; }
[[ -f "$FAILURES_FILE" ]] || { echo "missing failures file: $FAILURES_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs file: $INPUTS_FILE" >&2; exit 1; }

grep -q "Architecture Goals" "$DOC_FILE"
grep -q "Whisper" "$DOC_FILE"
grep -q "Trust Boundaries" "$DOC_FILE"
grep -q "End-to-End Flows" "$DOC_FILE"
grep -q "Failure Modes" "$DOC_FILE"
grep -q "Acceptance Criteria" "$DOC_FILE"

grep -q "cpu_single_worker" "$TOPOLOGY_FILE"
grep -q "gpu_dedicated_worker" "$TOPOLOGY_FILE"
grep -q "hybrid_queue_workers" "$TOPOLOGY_FILE"
grep -q "lan_only: true" "$TOPOLOGY_FILE"

grep -q "id: A" "$BOUNDARIES_FILE"
grep -q "id: E" "$BOUNDARIES_FILE"
grep -q "required_fields" "$BOUNDARIES_FILE"

grep -q "Flow 1" "$FLOWS_FILE"
grep -q "Flow 2" "$FLOWS_FILE"
grep -q "Flow 3" "$FLOWS_FILE"
grep -q "Flow 4" "$FLOWS_FILE"

grep -q "failure_mode,impact,detection,control" "$FAILURES_FILE"
grep -q "acl_drift" "$FAILURES_FILE"
grep -q "sensitive_premature_indexing" "$FAILURES_FILE"

grep -q "^WORKER_MODE=" "$INPUTS_FILE"
grep -q "^GROUP_CLAIM_NAME=groups" "$INPUTS_FILE"
grep -q "^NO_PUBLIC_ENDPOINTS=true" "$INPUTS_FILE"

echo "60.10-voice-transcription-architecture: verification complete"
