#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 --env-file <path> [--mode baseline|trunk] [--output <path>]

Renders a Proxmox /etc/network/interfaces file from 81.50 variables.
This script does not modify host networking; it only writes rendered output.
USAGE
}

ENV_FILE="infrastructure/proxmox/networking/81.50-network-inputs.env"
MODE="baseline"
OUTPUT="/tmp/interfaces.generated"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file)
      ENV_FILE="${2:-}"
      shift 2
      ;;
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --output)
      OUTPUT="${2:-}"
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
  echo "Copy infrastructure/proxmox/networking/81.50-network-inputs.env.example first." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

required=(BRIDGE_NAME PHYSICAL_NIC PROXMOX_MANAGEMENT_IP_CIDR PROXMOX_GATEWAY)
for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required variable in ${ENV_FILE}: ${var}" >&2
    exit 1
  fi
done

mkdir -p "$(dirname "${OUTPUT}")"

{
  echo "auto lo"
  echo "iface lo inet loopback"
  echo
  echo "auto ${PHYSICAL_NIC}"
  echo "iface ${PHYSICAL_NIC} inet manual"
  echo
  echo "auto ${BRIDGE_NAME}"
  echo "iface ${BRIDGE_NAME} inet static"
  echo "    address ${PROXMOX_MANAGEMENT_IP_CIDR}"
  echo "    gateway ${PROXMOX_GATEWAY}"
  echo "    bridge-ports ${PHYSICAL_NIC}"
  echo "    bridge-stp off"
  echo "    bridge-fd 0"
  if [[ "${MODE}" == "trunk" || "${VLAN_ENABLED:-false}" == "true" ]]; then
    vids="${VLAN_IDS//,/ }"
    echo "    bridge-vlan-aware yes"
    echo "    bridge-vids ${vids}"
  fi
} > "${OUTPUT}"

echo "rendered-interfaces: ${OUTPUT}"
