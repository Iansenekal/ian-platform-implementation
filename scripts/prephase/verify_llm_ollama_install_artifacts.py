#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/82-LLM-Pointer-Server/82.40-Ollama-Install-AMD-GPU.md",
    "infrastructure/ollama-gpu/82.40-ollama-install-inputs.env.example",
    "infrastructure/ollama-gpu/82.40-ollama-override.conf.baseline",
    "infrastructure/ollama-gpu/82.40-ollama-install-apply.sh",
    "infrastructure/ollama-gpu/82.40-ollama-install-verify.sh",
    "infrastructure/ollama-gpu/82.40-evidence-checklist.md",
]

missing = [path for path in required_files if not Path(path).is_file()]
if missing:
    raise SystemExit(f"llm-ollama-install artifacts missing: {', '.join(missing)}")

apply_script = Path("infrastructure/ollama-gpu/82.40-ollama-install-apply.sh").read_text(encoding="utf-8")
for token in ["/opt/ollama", "OLLAMA_HOST_BIND", "curl -fsSL https://ollama.com/install.sh | sh", "ufw allow from", "systemctl restart ollama"]:
    if token not in apply_script:
        raise SystemExit(f"82.40 apply script missing token: {token}")

verify_script = Path("infrastructure/ollama-gpu/82.40-ollama-install-verify.sh").read_text(encoding="utf-8")
for token in ["ollama --version", "curl -fsS http://127.0.0.1", "ufw status", "lspci -k", "/dev/dri"]:
    if token not in verify_script:
        raise SystemExit(f"82.40 verify script missing token: {token}")

print("llm-ollama-install-artifacts: OK")
