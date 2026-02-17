#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/82-LLM-Pointer-Server/82.90-Client-Rollout-Variables.md",
    "infrastructure/ollama-gpu/82.90-client-rollout-variables.yaml",
]

missing = [path for path in required_files if not Path(path).is_file()]
if missing:
    raise SystemExit(f"llm-client-rollout-vars artifacts missing: {', '.join(missing)}")

rollout_path = Path("infrastructure/ollama-gpu/82.90-client-rollout-variables.yaml")
text = rollout_path.read_text(encoding="utf-8")

required_top = [
    "client",
    "llm_pointer",
    "access_control",
    "bind_policy",
    "storage",
    "allowed_models",
    "procurement",
    "logging_retention",
    "verification",
    "signoff",
]
for key in required_top:
    if f"\n{key}:" not in text:
        raise SystemExit(f"82.90 rollout yaml missing key: {key}")

if "admin_ssh_ips:" not in text:
    raise SystemExit("82.90 rollout yaml missing admin_ssh_ips")

if "allowed_models:" not in text or "  - model_id:" not in text:
    raise SystemExit("82.90 rollout yaml allowed_models list entries missing")

if "ollama_port: 11434" not in text:
    raise SystemExit("82.90 rollout yaml ollama_port must be 11434 by default")

doc = Path("docs/82-LLM-Pointer-Server/82.90-Client-Rollout-Variables.md").read_text(encoding="utf-8")
for token in ["REQUIRED", "Allowed Models", "Sign-Off", "82.80"]:
    if token not in doc:
        raise SystemExit(f"82.90 document missing token: {token}")

print("llm-client-rollout-vars-artifacts: OK")
