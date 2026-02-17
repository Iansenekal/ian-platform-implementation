#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/81-Proxmox-Host/81.190-VM-Provisioning-Verification-Checklist.md",
    "infrastructure/vm-provisioning/verification/README.md",
    "infrastructure/vm-provisioning/verification/81.190-gate-inputs.env.example",
    "infrastructure/vm-provisioning/verification/81.190-vm-provisioning-gate.sh",
    "infrastructure/vm-provisioning/verification/81.190-evidence-checklist.md",
    "infrastructure/vm-provisioning/verification/verification-gate.md",
]

missing = [path for path in required_files if not Path(path).is_file()]
if missing:
    raise SystemExit(f"vm-provisioning-gate artifacts missing: {', '.join(missing)}")

script = Path("infrastructure/vm-provisioning/verification/81.190-vm-provisioning-gate.sh").read_text(encoding="utf-8")
for token in ["REQUIRED_VMS", "ufw status verbose", "qemu-guest-agent", "sshd -T", "timedatectl"]:
    if token not in script:
        raise SystemExit(f"81.190 gate script missing token: {token}")

print("vm-provisioning-gate-artifacts: OK")
