# Proxmox Storage (81.70 / 81.80 / 81.90)

This directory contains storage planning, implementation helpers, and verification gates.

## Files
- `storage-plan.yml`: canonical storage decision artifact (LVM-thin vs ZFS).
- `81.70-storage-decision-inputs.env.example`: site decision inputs.
- `81.70-storage-decision-gate.sh`: validates decision inputs are complete.
- `81.80-storage-inputs.env.example`: implementation inputs (store IDs/paths/backend).
- `81.80-storage-verify.sh`: implementation verification checks.
- `81.80-evidence-checklist.md`: mandatory implementation evidence list.
- `81.90-storage-verify-inputs.env.example`: verification thresholds and VM proof inputs.
- `81.90-storage-verification.sh`: post-implementation storage verification collector.
- `81.90-evidence-checklist.md`: mandatory verification gate evidence list.

## Recommended Flow
1. Finalize storage decision:
   - `bash infrastructure/proxmox/storage/81.70-storage-decision-gate.sh --env-file infrastructure/proxmox/storage/81.70-storage-decision-inputs.env`
2. Implement storage objects in Proxmox UI (`iso-store`, `vm-disks`/`zfs-vm`, `backup-store`).
3. Run implementation checks:
   - `bash infrastructure/proxmox/storage/81.80-storage-verify.sh --env-file infrastructure/proxmox/storage/81.80-storage-inputs.env`
4. Run verification gate and collect evidence:
   - `bash infrastructure/proxmox/storage/81.90-storage-verification.sh --env-file infrastructure/proxmox/storage/81.90-storage-verify-inputs.env --evidence-dir artifacts/storage-verification`
