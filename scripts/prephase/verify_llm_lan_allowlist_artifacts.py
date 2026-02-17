#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/82-LLM-Pointer-Server/82.60-Ollama-LAN-Only-Bind-and-UFW-Allowlist.md",
    "infrastructure/ollama-gpu/82.60-lan-allowlist-inputs.env.example",
    "infrastructure/ollama-gpu/82.60-lan-allowlist-apply.sh",
    "infrastructure/ollama-gpu/82.60-lan-allowlist-verify.sh",
    "infrastructure/ollama-gpu/82.60-evidence-checklist.md",
]

missing = [path for path in required_files if not Path(path).is_file()]
if missing:
    raise SystemExit(f"llm-lan-allowlist artifacts missing: {', '.join(missing)}")

apply_script = Path("infrastructure/ollama-gpu/82.60-lan-allowlist-apply.sh").read_text(encoding="utf-8")
for token in ["OLLAMA_HOST_BIND", "ufw --force reset", "AI_DATA01_IP", "ALLOW_FRONTEND_CALLER", "ALLOW_ADMIN_DIAG_ACCESS"]:
    if token not in apply_script:
        raise SystemExit(f"82.60 apply script missing token: {token}")

verify_script = Path("infrastructure/ollama-gpu/82.60-lan-allowlist-verify.sh").read_text(encoding="utf-8")
for token in ["ufw status verbose", "AI-DATA01 allow rule", "manual-check", "curl -fsS http://127.0.0.1"]:
    if token not in verify_script:
        raise SystemExit(f"82.60 verify script missing token: {token}")

print("llm-lan-allowlist-artifacts: OK")
