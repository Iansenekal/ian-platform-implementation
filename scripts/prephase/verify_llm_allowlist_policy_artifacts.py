#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/82-LLM-Pointer-Server/82.50-US-EU-Model-Allowlist-Policy.md",
    "infrastructure/ollama-gpu/82.50-model-allowlist.yaml.example",
    "infrastructure/ollama-gpu/82.50-model-inventory-record.example.json",
    "infrastructure/ollama-gpu/82.50-allowlist-enforced-pull.sh",
    "infrastructure/ollama-gpu/82.50-allowlist-audit.sh",
    "infrastructure/ollama-gpu/82.50-evidence-checklist.md",
]

missing = [path for path in required_files if not Path(path).is_file()]
if missing:
    raise SystemExit(f"llm-allowlist-policy artifacts missing: {', '.join(missing)}")

policy_doc = Path("docs/82-LLM-Pointer-Server/82.50-US-EU-Model-Allowlist-Policy.md").read_text(encoding="utf-8")
for token in ["US/EU", "allowlist", "approval_ref", "weekly"]:
    if token not in policy_doc:
        raise SystemExit(f"82.50 policy doc missing token: {token}")

pull_script = Path("infrastructure/ollama-gpu/82.50-allowlist-enforced-pull.sh").read_text(encoding="utf-8")
for token in ["ollama pull", "model-allowlist", "CHG-", "model-inventory"]:
    if token not in pull_script:
        raise SystemExit(f"82.50 pull wrapper missing token: {token}")

audit_script = Path("infrastructure/ollama-gpu/82.50-allowlist-audit.sh").read_text(encoding="utf-8")
for token in ["ollama list", "comm -13", "unexpected", "82.50-allowlist-audit"]:
    if token not in audit_script:
        raise SystemExit(f"82.50 audit script missing token: {token}")

print("llm-allowlist-policy-artifacts: OK")
