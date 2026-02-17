#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 [--env-file path]

Runs 81.20 first-boot verification checks on a Proxmox host.
Defaults env file path to: infrastructure/proxmox/install-hardening/81.20-install-inputs.env
USAGE
}

ENV_FILE="infrastructure/proxmox/install-hardening/81.20-install-inputs.env"
if [[ "${1:-}" == "--env-file" ]]; then
  ENV_FILE="${2:-}"
elif [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}" >&2
  echo "Copy infrastructure/proxmox/install-hardening/81.20-install-inputs.env.example first." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

required=(
  PROXMOX_HOSTNAME
  PROXMOX_MANAGEMENT_IP
  PROXMOX_GATEWAY
  PROXMOX_DNS
  PROXMOX_TIMEZONE
)

for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required variable in ${ENV_FILE}: ${var}" >&2
    exit 1
  fi
done

expected_ip="${PROXMOX_MANAGEMENT_IP%%/*}"

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

check "timezone configured" "timedatectl | grep -q \"Time zone: ${PROXMOX_TIMEZONE}\""
check "management IP present" "ip -br a | grep -q \"${expected_ip}\""
check "default route set" "ip r | grep -q \"default via ${PROXMOX_GATEWAY}\""
check "dns nameserver configured" "grep -Eq \"^nameserver[[:space:]]+${PROXMOX_DNS}$\" /etc/resolv.conf"
check "gateway reachable" "ping -c 2 ${PROXMOX_GATEWAY} >/dev/null"
check "dns reachable" "ping -c 2 ${PROXMOX_DNS} >/dev/null"
check "hostname resolves in hosts file" "grep -Eq \"${expected_ip}.*${PROXMOX_HOSTNAME%%.*}\" /etc/hosts"

cat <<EOF2
81.20 verification completed successfully.

Next manual checks:
- Browser login to https://${expected_ip}:8006 from admin workstation.
- Dashboard screenshot captured.
EOF2
