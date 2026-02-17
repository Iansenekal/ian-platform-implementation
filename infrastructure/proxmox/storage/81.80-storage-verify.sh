#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 [--env-file path]

Runs 81.80 storage implementation checks on a Proxmox host.
Default env file:
  infrastructure/proxmox/storage/81.80-storage-inputs.env
USAGE
}

ENV_FILE="infrastructure/proxmox/storage/81.80-storage-inputs.env"
if [[ "${1:-}" == "--env-file" ]]; then
  ENV_FILE="${2:-}"
elif [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}" >&2
  echo "Copy infrastructure/proxmox/storage/81.80-storage-inputs.env.example first." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

required=(
  STORAGE_MODE
  ISO_STORAGE_ID
  VM_STORAGE_ID
  BACKUP_STORAGE_ID
)
for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required variable in ${ENV_FILE}: ${var}" >&2
    exit 1
  fi
done

check() {
  local name=$1
  local cmd=$2
  echo "[check] ${name}"
  if ! eval "${cmd}"; then
    echo "[fail] ${name}" >&2
    exit 1
  fi
  echo "[pass] ${name}"
}

check "disk inventory visible" "lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL,SERIAL >/dev/null"
check "filesystem usage visible" "df -hT >/dev/null"
check "storage manager shows datastores" "pvesm status >/dev/null"
check "iso storage id present" "pvesm status | awk '{print \$1}' | grep -qx '${ISO_STORAGE_ID}'"
check "vm storage id present" "pvesm status | awk '{print \$1}' | grep -qx '${VM_STORAGE_ID}'"
check "backup storage id present" "pvesm status | awk '{print \$1}' | grep -qx '${BACKUP_STORAGE_ID}'"

if [[ "${STORAGE_MODE}" == "lvm_thin" ]]; then
  check "lvm thin objects visible" "lvs >/dev/null"
  check "volume groups visible" "vgs >/dev/null"
elif [[ "${STORAGE_MODE}" == "zfs" ]]; then
  check "zpool healthy" "zpool status >/dev/null"
  check "zfs datasets visible" "zfs list >/dev/null"
else
  echo "Unsupported STORAGE_MODE=${STORAGE_MODE}" >&2
  exit 1
fi

echo "81.80 storage implementation verification: PASS"
