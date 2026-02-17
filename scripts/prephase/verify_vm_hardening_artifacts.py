#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/81-Proxmox-Host/81.150-VM-Base-Hardening-SSH-UFW-UnattendedUpgrades.md",
    "infrastructure/vm-provisioning/hardening/README.md",
    "infrastructure/vm-provisioning/hardening/81.150-hardening-inputs.env.example",
    "infrastructure/vm-provisioning/hardening/base-hardening.sh",
    "infrastructure/vm-provisioning/hardening/verify-hardening.sh",
    "infrastructure/vm-provisioning/hardening/sshd_config.baseline",
    "infrastructure/vm-provisioning/hardening/sshd.local.baseline",
    "infrastructure/vm-provisioning/hardening/50unattended-upgrades.baseline",
    "infrastructure/vm-provisioning/hardening/20auto-upgrades.baseline",
    "infrastructure/vm-provisioning/hardening/81.150-evidence-checklist.md",
]

missing = [path for path in required_files if not Path(path).is_file()]
if missing:
    raise SystemExit(f"vm-hardening artifacts missing: {', '.join(missing)}")

script = Path("infrastructure/vm-provisioning/hardening/base-hardening.sh").read_text(encoding="utf-8")
for token in [
    "PermitRootLogin no",
    "PasswordAuthentication",
    "ufw default",
    "fail2ban",
    "50unattended-upgrades",
]:
    if token not in script and token not in Path("infrastructure/vm-provisioning/hardening/sshd_config.baseline").read_text(encoding="utf-8"):
        raise SystemExit(f"81.150 token missing from hardening artifacts: {token}")

print("vm-hardening-artifacts: OK")
