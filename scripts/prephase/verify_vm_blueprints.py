#!/usr/bin/env python3
from pathlib import Path

content = Path("infrastructure/vm-provisioning/blueprints/vm-blueprints.yml").read_text(encoding="utf-8")
required_tokens = [
    "vm_blueprints:",
    "name: AI-DATA01",
    "name: AI-FRONTEND01",
    "name: DNS01",
    "qemu_guest_agent_required: true",
    "primary_bridge: vmbr0",
    "bios: ovmf",
    "machine_type: q35",
    "backup_datastore: backup-store",
]
missing = [token for token in required_tokens if token not in content]
if missing:
    raise SystemExit(f"vm-blueprints missing tokens: {', '.join(missing)}")
print("vm-blueprints: OK")
