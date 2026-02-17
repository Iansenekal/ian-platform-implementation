#!/usr/bin/env python3
from pathlib import Path

plan = Path("infrastructure/proxmox/storage/storage-plan.yml").read_text(encoding="utf-8")
required_tokens = [
    "storage_decision:",
    "selected_mode:",
    "quick_pick:",
    "lvm_thin:",
    "zfs:",
    "datastores:",
    "iso_store:",
    "vm_disk_store:",
    "backup_store:",
    "verification_gate:",
    "restore_test_required: true",
    "evidence_integrity_checksums_required: true",
]
missing = [token for token in required_tokens if token not in plan]
if missing:
    raise SystemExit(f"storage-plan missing tokens: {', '.join(missing)}")
print("storage-plan: OK")
