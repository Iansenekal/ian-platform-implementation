#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 --env-file <path>

Verifies 82.30 hardening controls on ai-llm01.
USAGE
}

ENV_FILE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file)
      ENV_FILE="${2:-}"
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

if [[ -z "${ENV_FILE}" || ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

required=(ADMIN_WORKSTATION_IPS ALLOWED_OLLAMA_CALLER_IP SSH_PORT OLLAMA_PORT)
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

check "sshd config valid" "sudo sshd -t"
check "root login disabled" "sudo sshd -T | grep -q '^permitrootlogin no$'"
if [[ "${ALLOW_PASSWORD_SSH:-false}" == "false" ]]; then
  check "password ssh disabled" "sudo sshd -T | grep -q '^passwordauthentication no$'"
fi
check "ufw active" "sudo ufw status | grep -Eq '^Status: active'"
check "ufw deny incoming" "sudo ufw status verbose | grep -Eq 'Default: deny \\(incoming\\)'"

IFS=',' read -r -a admin_ips <<< "${ADMIN_WORKSTATION_IPS}"
for ip in "${admin_ips[@]}"; do
  ip="$(echo "${ip}" | xargs)"
  [[ -z "${ip}" ]] && continue
  check "ufw ssh rule for ${ip}" "sudo ufw status | grep -Eq '${ip}.*${SSH_PORT}/tcp.*ALLOW'"
done

check "ufw ollama caller rule present" "sudo ufw status | grep -Eq '${ALLOWED_OLLAMA_CALLER_IP}.*${OLLAMA_PORT}/tcp.*ALLOW'"
check "ssh service active" "systemctl is-active --quiet ssh"
check "fail2ban active" "systemctl is-active --quiet fail2ban"
check "fail2ban sshd jail enabled" "sudo fail2ban-client status sshd | grep -Eq 'Jail list|sshd'"
check "rsyslog active" "systemctl is-active --quiet rsyslog"

echo "[check] unattended upgrades dry run (first 50 lines)"
sudo unattended-upgrade --dry-run --debug 2>/dev/null | head -n 50 || true

echo "[evidence] sshd flags"
sudo sshd -T | egrep 'port |passwordauthentication|permitrootlogin|pubkeyauthentication'
echo "[evidence] ufw verbose"
sudo ufw status verbose
echo "[evidence] ufw numbered"
sudo ufw status numbered
echo "[evidence] fail2ban sshd"
sudo fail2ban-client status sshd
echo "[evidence] journald disk usage"
journalctl --disk-usage
echo "[evidence] listeners"
ss -tulpen | head -n 80

echo "82.30 hardening verify: PASS"
