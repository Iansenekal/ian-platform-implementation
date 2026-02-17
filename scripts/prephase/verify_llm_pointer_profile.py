#!/usr/bin/env python3
from pathlib import Path

content = Path("infrastructure/ollama-gpu/pointer-server-profile.yml").read_text(encoding="utf-8")
required_tokens = [
    "pointer_server:",
    "role: dedicated_ollama_runtime",
    "lan_only: true",
    "runtime_cloud_dependency: false",
    "approved_sources:",
    "gateway_mediated_calls_required: true",
    "model_origin_allowlist_regions:",
    "- US",
    "- EU",
    "model_auto_update_allowed: false",
    "model_pull_requires_approval: true",
    "checksum_record_required: true",
    "ollama_api_port: 11434",
    "ssh_port: 22",
    "inbound_wan_exposure_allowed: false",
    "internal_tls_preferred: true",
    "gpu_model:",
    "passthrough_required: true",
    "level: metadata_only",
    "content_redaction_required: true",
]
missing = [token for token in required_tokens if token not in content]
if missing:
    raise SystemExit(f"llm-pointer profile missing tokens: {', '.join(missing)}")
print("llm-pointer-profile: OK")
