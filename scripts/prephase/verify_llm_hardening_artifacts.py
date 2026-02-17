#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/82-LLM-Pointer-Server/82.30-Base-Hardening-SSH-UFW-UnattendedUpgrades.md",
    "infrastructure/ollama-gpu/82.30-hardening-inputs.env.example",
    "infrastructure/ollama-gpu/82.30-hardening-apply.sh",
    "infrastructure/ollama-gpu/82.30-hardening-verify.sh",
    "infrastructure/ollama-gpu/82.30-evidence-checklist.md",
    "infrastructure/ollama-gpu/82.30-sshd_config.baseline",
    "infrastructure/ollama-gpu/82.30-jail.local.baseline",
    "infrastructure/ollama-gpu/82.30-journald-override.conf",
    "infrastructure/ollama-gpu/82.30-50unattended-upgrades.baseline",
    "infrastructure/ollama-gpu/82.30-20auto-upgrades.baseline",
]

missing = [path for path in required_files if not Path(path).is_file()]
if missing:
    raise SystemExit(f"llm-hardening artifacts missing: {', '.join(missing)}")

apply_script = Path("infrastructure/ollama-gpu/82.30-hardening-apply.sh").read_text(encoding="utf-8")
for token in ["ufw default deny incoming", "fail2ban", "unattended-upgrades", "ALLOWED_OLLAMA_CALLER_IP", "sshd -t"]:
    if token not in apply_script:
        raise SystemExit(f"82.30 apply script missing token: {token}")

verify_script = Path("infrastructure/ollama-gpu/82.30-hardening-verify.sh").read_text(encoding="utf-8")
for token in ["ufw status verbose", "fail2ban-client status sshd", "unattended-upgrade --dry-run --debug"]:
    if token not in verify_script:
        raise SystemExit(f"82.30 verify script missing token: {token}")

print("llm-hardening-artifacts: OK")
