#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/81-Proxmox-Host/81.160-VM-Access-RemoteSSH-Keys-and-AdminWorkstations.md",
    "infrastructure/vm-provisioning/access/README.md",
    "infrastructure/vm-provisioning/access/81.160-access-inputs.env.example",
    "infrastructure/vm-provisioning/access/admin-workstation-inventory.csv",
    "infrastructure/vm-provisioning/access/admin-users-keys.example.csv",
    "infrastructure/vm-provisioning/access/vscode-ssh-config.example",
    "infrastructure/vm-provisioning/access/provision-admin-access.sh",
    "infrastructure/vm-provisioning/access/verify-admin-access.sh",
    "infrastructure/vm-provisioning/access/81.160-evidence-checklist.md",
]

missing = [path for path in required_files if not Path(path).is_file()]
if missing:
    raise SystemExit(f"vm-access artifacts missing: {', '.join(missing)}")

script = Path("infrastructure/vm-provisioning/access/provision-admin-access.sh").read_text(encoding="utf-8")
for token in ["platform-admins", "authorized_keys", "ufw allow from", "usermod -aG sudo"]:
    if token not in script:
        raise SystemExit(f"vm-access provision script missing token: {token}")

print("vm-access-artifacts: OK")
