#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 [--env-file path]

Runs 81.150 hardening verification checks on current VM.
Default env file:
  infrastructure/vm-provisioning/hardening/81.150-hardening-inputs.env
USAGE
}

ENV_FILE="infrastructure/vm-provisioning/hardening/81.150-hardening-inputs.env"
if [[ "${1:-}" == "--env-file" ]]; then
  ENV_FILE="${2:-}"
elif [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}" >&2
  echo "Copy infrastructure/vm-provisioning/hardening/81.150-hardening-inputs.env.example first." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

required=(
  ADMIN_SUBNET_CIDR
  SSH_PORT
  TIMEZONE
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

check "sshd config valid" "sshd -t"
check "permitrootlogin disabled" "sshd -T | grep -q '^permitrootlogin no$'"
check "pubkey auth enabled" "sshd -T | grep -q '^pubkeyauthentication yes$'"
check "ssh service active" "systemctl is-active --quiet ssh"
check "ufw active" "ufw status | grep -Eq '^Status: active'"
check "ufw deny incoming" "ufw status verbose | grep -Eq 'Default: deny \\(incoming\\)'"
check "ufw ssh allowlist rule present" "ufw status | grep -Eq '${ADMIN_SUBNET_CIDR}.*${SSH_PORT}/tcp.*ALLOW'"
check "fail2ban active" "systemctl is-active --quiet fail2ban"
check "fail2ban sshd jail enabled" "fail2ban-client status | grep -Eq 'sshd'"
check "timezone set" "timedatectl | grep -q 'Time zone: ${TIMEZONE}'"

echo "[check] unattended-upgrades dry run (first 50 lines)"
sudo unattended-upgrade --dry-run --debug 2>/dev/null | head -n 50 || true

echo "[evidence] sshd flags"
sshd -T | egrep 'port |passwordauthentication|permitrootlogin|pubkeyauthentication'
echo "[evidence] ufw status"
sudo ufw status verbose
echo "[evidence] ufw rules"
sudo ufw show added
echo "[evidence] fail2ban sshd"
sudo fail2ban-client status sshd
echo "[evidence] listeners"
ss -tulpen | head -n 80

echo "81.150 hardening verification: PASS"
