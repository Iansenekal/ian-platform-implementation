#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 [--env-file path]

Runs 81.50 network checks on a Proxmox host after applying bridge/VLAN configuration.
Defaults env file to: infrastructure/proxmox/networking/81.50-network-inputs.env
USAGE
}

ENV_FILE="infrastructure/proxmox/networking/81.50-network-inputs.env"
if [[ "${1:-}" == "--env-file" ]]; then
  ENV_FILE="${2:-}"
elif [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}" >&2
  echo "Copy infrastructure/proxmox/networking/81.50-network-inputs.env.example first." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

required=(
  BRIDGE_NAME
  PHYSICAL_NIC
  PROXMOX_MANAGEMENT_IP_CIDR
  PROXMOX_GATEWAY
  PROXMOX_DNS
)
for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required variable in ${ENV_FILE}: ${var}" >&2
    exit 1
  fi
done

expected_ip="${PROXMOX_MANAGEMENT_IP_CIDR%%/*}"

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

check "bridge exists" "ip -br link | grep -Eq \"^${BRIDGE_NAME}[[:space:]]\""
check "management IP on bridge" "ip -br addr | grep -Eq \"^${BRIDGE_NAME}[[:space:]].*${expected_ip}\""
check "physical NIC enslaved to bridge" "bridge link | grep -Eq \"${PHYSICAL_NIC}.*master ${BRIDGE_NAME}\""
check "default route configured" "ip r | grep -q \"default via ${PROXMOX_GATEWAY}\""
check "gateway reachable" "ping -c 2 ${PROXMOX_GATEWAY} >/dev/null"
check "dns reachable" "ping -c 2 ${PROXMOX_DNS} >/dev/null"
check "proxmox ui listener present" "ss -tulpen | grep -Eq \":8006\\b\""

if [[ "${VLAN_ENABLED:-false}" == "true" ]]; then
  ids="${VLAN_IDS//,/ }"
  for id in ${ids}; do
    check "vlan ${id} declared on bridge" "bridge vlan show | awk 'NR>1 {print \$0}' | grep -Eq \"${BRIDGE_NAME}|${PHYSICAL_NIC}.*\\b${id}\\b\""
  done
fi

cat <<EOF2
81.50 verification completed successfully.

Manual follow-up:
- Confirm vmbr0/VM NIC mapping in Proxmox UI.
- Validate at least one VM can reach gateway and DNS.
- Capture evidence listed in 81.50-evidence-checklist.md.
EOF2
