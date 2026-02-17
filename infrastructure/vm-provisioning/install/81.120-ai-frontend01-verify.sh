#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 [--env-file path]

Runs 81.120 post-install verification checks for AI-FRONTEND01.
Default env file:
  infrastructure/vm-provisioning/install/81.120-ai-frontend01-inputs.env
USAGE
}

ENV_FILE="infrastructure/vm-provisioning/install/81.120-ai-frontend01-inputs.env"
if [[ "${1:-}" == "--env-file" ]]; then
  ENV_FILE="${2:-}"
elif [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}" >&2
  echo "Copy infrastructure/vm-provisioning/install/81.120-ai-frontend01-inputs.env.example first." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

required=(
  VM_HOST_SHORT
  VM_HOST_FQDN
  VM_IP_CIDR
  VM_GATEWAY
  VM_DNS
  VM_DOMAIN
  VM_TIMEZONE
  ADMIN_SUBNET_CIDR
)
for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required variable in ${ENV_FILE}: ${var}" >&2
    exit 1
  fi
done

vm_ip="${VM_IP_CIDR%%/*}"

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

check "hostname short" "hostnamectl --static | grep -qx '${VM_HOST_SHORT}'"
check "hostname fqdn resolves" "getent hosts '${VM_HOST_FQDN}' >/dev/null || getent hosts '${VM_HOST_SHORT}' >/dev/null"
check "static IP configured" "ip -br addr | grep -Eq '${vm_ip}/'"
check "default route configured" "ip r | grep -q 'default via ${VM_GATEWAY}'"
check "dns server configured" "resolvectl status | grep -Eq '${VM_DNS}'"
check "search domain configured" "resolvectl status | grep -Eq '${VM_DOMAIN}'"
check "timezone configured" "timedatectl | grep -q 'Time zone: ${VM_TIMEZONE}'"
check "ssh active" "systemctl is-active --quiet ssh"
check "chrony active" "systemctl is-active --quiet chrony"
check "qemu guest agent active" "systemctl is-active --quiet qemu-guest-agent"
check "fail2ban active" "systemctl is-active --quiet fail2ban"
check "ufw active" "ufw status | grep -Eq '^Status: active'"
check "ufw ssh allowlist rule present" "ufw status | grep -Eq '${ADMIN_SUBNET_CIDR}.*22/tcp.*ALLOW'"

cat <<EOF2
81.120 AI-FRONTEND01 verification completed successfully.

Manual UI checks required:
- Proxmox VM Options shows QEMU Guest Agent enabled.
- Proxmox VM Summary shows the expected VM IP.
EOF2
