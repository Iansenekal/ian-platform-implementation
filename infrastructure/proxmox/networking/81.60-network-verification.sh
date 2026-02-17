#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 [--env-file path] [--evidence-dir path]

Runs 81.60 Proxmox network verification checks and stores command output
as an evidence pack.
Defaults:
  env-file: infrastructure/proxmox/networking/81.60-verify-inputs.env
  evidence-dir: artifacts/network-verification
USAGE
}

ENV_FILE="infrastructure/proxmox/networking/81.60-verify-inputs.env"
EVIDENCE_DIR="artifacts/network-verification"

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
  echo "Copy infrastructure/proxmox/networking/81.60-verify-inputs.env.example first." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

required=(
  PROXMOX_MANAGEMENT_IP
  PROXMOX_GATEWAY
  PROXMOX_DNS
  BRIDGE_NAME
  PHYSICAL_NIC
)
for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required variable in ${ENV_FILE}: ${var}" >&2
    exit 1
  fi
done

mkdir -p "${EVIDENCE_DIR}"
SUMMARY="${EVIDENCE_DIR}/summary.txt"
: > "${SUMMARY}"

run_capture() {
  local name=$1
  shift
  local outfile="${EVIDENCE_DIR}/${name}.txt"
  {
    echo "# command: $*"
    echo "# timestamp: $(date -Iseconds)"
    "$@"
  } > "${outfile}" 2>&1
}

check_cmd() {
  local name=$1
  shift
  if "$@" > /dev/null 2>&1; then
    echo "[pass] ${name}" | tee -a "${SUMMARY}"
  else
    echo "[fail] ${name}" | tee -a "${SUMMARY}" >&2
    return 1
  fi
}

echo "81.60 network verification start: $(date -Iseconds)" | tee -a "${SUMMARY}"

# Section 1: Current state
run_capture "01-hostname-fqdn" hostname -f
run_capture "02-ip-br-addr" ip -br addr
run_capture "03-ip-routes" ip r
run_capture "04-ip-br-link" ip -br link
run_capture "05-resolv-conf" cat /etc/resolv.conf
run_capture "06-interfaces" cat /etc/network/interfaces

# Section 2: Ping tests
run_capture "10-ping-gateway" ping -c 3 "${PROXMOX_GATEWAY}"
run_capture "11-ping-dns" ping -c 3 "${PROXMOX_DNS}"
run_capture "12-ping-known-lan-host" ping -c 3 "${KNOWN_LAN_HOST}"

# Section 3: DNS tests
run_capture "20-getent-dns01" getent hosts "dns01.${PROXMOX_DOMAIN}"
run_capture "21-getent-proxmox-fqdn" bash -lc 'getent hosts "$(hostname -f)"'
run_capture "22-getent-reverse-dns" getent hosts "${PROXMOX_DNS}"

# Section 4: MAC/IP sanity + listeners
run_capture "30-bridge-ip-check" bash -lc "ip -br addr | grep -E \"${BRIDGE_NAME}\""
run_capture "31-bridge-link" bridge link
run_capture "32-ip-link-bridge" ip link show "${BRIDGE_NAME}"
run_capture "33-ip-link-physical" ip link show "${PHYSICAL_NIC}"
run_capture "34-listeners-management" bash -lc "ss -tulpen | grep -E ':8006\\b|:22\\b'"
run_capture "35-default-route" bash -lc "ip r | grep default"

failures=0
check_cmd "host can ping gateway" ping -c 3 "${PROXMOX_GATEWAY}" || failures=$((failures + 1))
check_cmd "host can ping dns" ping -c 3 "${PROXMOX_DNS}" || failures=$((failures + 1))
check_cmd "host can ping known lan host" ping -c 3 "${KNOWN_LAN_HOST}" || failures=$((failures + 1))
check_cmd "bridge exists" bash -lc "ip -br link | grep -Eq '^${BRIDGE_NAME}[[:space:]]'" || failures=$((failures + 1))
check_cmd "bridge has management ip" bash -lc "ip -br addr | grep -Eq '^${BRIDGE_NAME}[[:space:]].*${PROXMOX_MANAGEMENT_IP}'" || failures=$((failures + 1))
check_cmd "physical nic enslaved to bridge" bash -lc "bridge link | grep -Eq '${PHYSICAL_NIC}.*master ${BRIDGE_NAME}'" || failures=$((failures + 1))
check_cmd "management listeners present" bash -lc "ss -tulpen | grep -Eq ':8006\\b|:22\\b'" || failures=$((failures + 1))

if [[ -n "${REPRESENTATIVE_VM_IP:-}" && -n "${REPRESENTATIVE_VM_SSH_USER:-}" ]]; then
  vm_target="${REPRESENTATIVE_VM_SSH_USER}@${REPRESENTATIVE_VM_IP}"
  run_capture "40-vm-ip-br-addr" ssh -o BatchMode=yes -o ConnectTimeout=10 "${vm_target}" "ip -br addr"
  run_capture "41-vm-routes" ssh -o BatchMode=yes -o ConnectTimeout=10 "${vm_target}" "ip r | head"
  run_capture "42-vm-ping-gateway" ssh -o BatchMode=yes -o ConnectTimeout=10 "${vm_target}" "ping -c 3 ${PROXMOX_GATEWAY}"
  run_capture "43-vm-ping-dns" ssh -o BatchMode=yes -o ConnectTimeout=10 "${vm_target}" "ping -c 3 ${PROXMOX_DNS}"
  run_capture "44-vm-getent-dns01" ssh -o BatchMode=yes -o ConnectTimeout=10 "${vm_target}" "getent hosts dns01.${PROXMOX_DOMAIN} || true"
  check_cmd "vm can ping gateway" ssh -o BatchMode=yes -o ConnectTimeout=10 "${vm_target}" "ping -c 3 ${PROXMOX_GATEWAY}" || failures=$((failures + 1))
  check_cmd "vm can ping dns" ssh -o BatchMode=yes -o ConnectTimeout=10 "${vm_target}" "ping -c 3 ${PROXMOX_DNS}" || failures=$((failures + 1))
else
  echo "[warn] representative VM SSH not configured; VM checks skipped" | tee -a "${SUMMARY}"
fi

cat <<EOF2 | tee -a "${SUMMARY}"
Evidence directory: ${EVIDENCE_DIR}
Manual checks still required:
- Proxmox UI network screenshot showing ${BRIDGE_NAME}
- VM MAC uniqueness check in Proxmox UI
- Perimeter firewall/NAT proof of no WAN exposure
EOF2

if [[ "${failures}" -gt 0 ]]; then
  echo "81.60 verification failed: ${failures} check(s) failed" >&2
  exit 1
fi

echo "81.60 verification passed" | tee -a "${SUMMARY}"
