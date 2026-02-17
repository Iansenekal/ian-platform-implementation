#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/81-Proxmox-Host/81.110-Ubuntu-24.04-Minimal-Install-DataVM.md",
    "docs/81-Proxmox-Host/81.120-Ubuntu-24.04-Minimal-Install-FrontendVM.md",
    "infrastructure/vm-provisioning/install/README.md",
    "infrastructure/vm-provisioning/install/81.110-ai-data01-inputs.env.example",
    "infrastructure/vm-provisioning/install/81.110-ai-data01-verify.sh",
    "infrastructure/vm-provisioning/install/81.110-netplan-01-netcfg.yaml.example",
    "infrastructure/vm-provisioning/install/81.110-evidence-checklist.md",
    "infrastructure/vm-provisioning/install/81.120-ai-frontend01-inputs.env.example",
    "infrastructure/vm-provisioning/install/81.120-ai-frontend01-verify.sh",
    "infrastructure/vm-provisioning/install/81.120-netplan-01-netcfg.yaml.example",
    "infrastructure/vm-provisioning/install/81.120-evidence-checklist.md",
]

missing = [path for path in required_files if not Path(path).is_file()]
if missing:
    raise SystemExit(f"vm-install artifacts missing: {', '.join(missing)}")

blueprint = Path("infrastructure/vm-provisioning/blueprints/vm-blueprints.yml").read_text(encoding="utf-8")
for token in [
    "name: AI-DATA01",
    "name: AI-FRONTEND01",
    "qemu_guest_agent_required: true",
    "primary_bridge: vmbr0",
]:
    if token not in blueprint:
        raise SystemExit(f"vm-blueprint token missing for 81.110/81.120: {token}")

print("vm-install-artifacts: OK")
