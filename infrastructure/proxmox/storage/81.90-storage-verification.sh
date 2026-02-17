#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 [--env-file path] [--evidence-dir path]

Runs 81.90 storage verification checks and captures evidence.
Defaults:
  env-file: infrastructure/proxmox/storage/81.90-storage-verify-inputs.env
  evidence-dir: artifacts/storage-verification
USAGE
}

ENV_FILE="infrastructure/proxmox/storage/81.90-storage-verify-inputs.env"
EVIDENCE_DIR="artifacts/storage-verification"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file)
      ENV_FILE="${2:-}"
      shift 2
      ;;
    --evidence-dir)
      EVIDENCE_DIR="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}" >&2
  echo "Copy infrastructure/proxmox/storage/81.90-storage-verify-inputs.env.example first." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

required=(STORAGE_MODE PRIMARY_DATASTORE_ID BACKUP_DATASTORE_ID WARN_PERCENT CRITICAL_PERCENT)
for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required variable in ${ENV_FILE}: ${var}" >&2
    exit 1
  fi
done

mkdir -p "${EVIDENCE_DIR}"
SUMMARY="${EVIDENCE_DIR}/summary.txt"
: > "${SUMMARY}"

capture() {
  local name=$1
  shift
  {
    echo "# command: $*"
    echo "# timestamp: $(date -Iseconds)"
    "$@"
  } > "${EVIDENCE_DIR}/${name}.txt" 2>&1
}

capture "01-pvesm-status" pvesm status
capture "02-df-hT" df -hT
capture "03-lsblk" lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL
capture "04-mount-head" bash -lc "mount | head -n 50"
capture "05-dmesg-storage-tail" bash -lc "dmesg -T | tail -n 80"

if [[ "${STORAGE_MODE}" == "lvm_thin" ]]; then
  capture "10-lvs-a" lvs -a
  capture "11-vgs" vgs
  capture "12-pvs" pvs
elif [[ "${STORAGE_MODE}" == "zfs" ]]; then
  capture "10-zpool-status" zpool status
  capture "11-zpool-list" zpool list
  capture "12-zfs-list" zfs list
else
  echo "Unsupported STORAGE_MODE=${STORAGE_MODE}" >&2
  exit 1
fi

echo "81.90 storage verification captured to ${EVIDENCE_DIR}" | tee -a "${SUMMARY}"
echo "Manual required proofs:" | tee -a "${SUMMARY}"
echo "- Snapshot create/rollback test on representative VM" | tee -a "${SUMMARY}"
echo "- Proxmox Storage and Snapshot page screenshots" | tee -a "${SUMMARY}"
echo "- Backup-store visibility and content-type confirmation (VZDump)" | tee -a "${SUMMARY}"
