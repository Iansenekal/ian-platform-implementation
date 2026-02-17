#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 [--env-file path]

Validates required 81.70 storage decision inputs are documented.
Default env file:
  infrastructure/proxmox/storage/81.70-storage-decision-inputs.env
USAGE
}

ENV_FILE="infrastructure/proxmox/storage/81.70-storage-decision-inputs.env"
if [[ "${1:-}" == "--env-file" ]]; then
  ENV_FILE="${2:-}"
elif [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}" >&2
  echo "Copy infrastructure/proxmox/storage/81.70-storage-decision-inputs.env.example first." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

required=(
  STORAGE_MODE
  DISK_INVENTORY
  BACKUP_TARGET_REFERENCE
  EVIDENCE_PRESERVATION_REFERENCE
)
for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required variable in ${ENV_FILE}: ${var}" >&2
    exit 1
  fi
done

if [[ "${STORAGE_MODE}" != "lvm_thin" && "${STORAGE_MODE}" != "zfs" ]]; then
  echo "STORAGE_MODE must be lvm_thin or zfs (got: ${STORAGE_MODE})" >&2
  exit 1
fi

if [[ "${STORAGE_MODE}" == "zfs" && -z "${ZFS_LAYOUT:-}" ]]; then
  echo "ZFS_LAYOUT is required when STORAGE_MODE=zfs" >&2
  exit 1
fi

if [[ "${STORAGE_MODE}" == "lvm_thin" && -z "${LVM_THIN_POLICY:-}" ]]; then
  echo "LVM_THIN_POLICY is required when STORAGE_MODE=lvm_thin" >&2
  exit 1
fi

echo "81.70 storage-decision gate: PASS"
