#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/82-LLM-Pointer-Server/82.80-Verification-Checklist.md",
    "infrastructure/ollama-gpu/82.80-verification-inputs.env.example",
    "infrastructure/ollama-gpu/82.80-verification-run.sh",
    "infrastructure/ollama-gpu/82.80-evidence-checklist.md",
]

missing = [path for path in required_files if not Path(path).is_file()]
if missing:
    raise SystemExit(f"llm-verification-checklist artifacts missing: {', '.join(missing)}")

run_script = Path("infrastructure/ollama-gpu/82.80-verification-run.sh").read_text(encoding="utf-8")
for token in ["ollama --version", "ufw status verbose", "/api/tags", "ollama list", "lspci"]:
    if token not in run_script:
        raise SystemExit(f"82.80 run script missing token: {token}")

doc = Path("docs/82-LLM-Pointer-Server/82.80-Verification-Checklist.md").read_text(encoding="utf-8")
for token in ["Mandatory", "Latency", "Firewall", "Evidence"]:
    if token not in doc:
        raise SystemExit(f"82.80 checklist doc missing token: {token}")

print("llm-verification-checklist-artifacts: OK")
