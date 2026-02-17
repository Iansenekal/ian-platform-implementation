#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 --env-file <path>

Applies 82.30 hardening baseline on ai-llm01.
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
  echo "Copy infrastructure/ollama-gpu/82.30-hardening-inputs.env.example first." >&2
  exit 1
fi

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root (sudo)." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
source "${ENV_FILE}"

required=(
  ADMIN_WORKSTATION_IPS
  ALLOWED_OLLAMA_CALLER_IP
  SSH_PORT
  OLLAMA_PORT
  ALLOW_PASSWORD_SSH
  ALLOW_USERS
  JOURNAL_SYSTEM_MAX_USE
  JOURNAL_RUNTIME_MAX_USE
  JOURNAL_MAX_RETENTION
  FAIL2BAN_BANTIME
  FAIL2BAN_FINDTIME
  FAIL2BAN_MAXRETRY
  UNATTENDED_AUTO_REBOOT
)
for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required variable in ${ENV_FILE}: ${var}" >&2
    exit 1
  fi
done

password_auth="no"
if [[ "${ALLOW_PASSWORD_SSH}" == "true" ]]; then
  password_auth="yes"
fi

echo "[step] install baseline packages"
apt update
apt -y install ufw fail2ban unattended-upgrades apt-listchanges rsyslog logrotate ca-certificates curl jq

echo "[step] apply sshd config"
sed \
  -e "s/__SSH_PORT__/${SSH_PORT}/g" \
  -e "s/__PASSWORD_AUTH__/${password_auth}/g" \
  -e "s/__ALLOW_USERS__/${ALLOW_USERS}/g" \
  "${SCRIPT_DIR}/82.30-sshd_config.baseline" > /etc/ssh/sshd_config
sshd -t
systemctl restart ssh

echo "[step] apply ufw rules"
ufw --force reset
ufw default deny incoming
ufw default allow outgoing

IFS=',' read -r -a admin_ips <<< "${ADMIN_WORKSTATION_IPS}"
for ip in "${admin_ips[@]}"; do
  ip="$(echo "${ip}" | xargs)"
  [[ -z "${ip}" ]] && continue
  ufw allow from "${ip}" to any port "${SSH_PORT}" proto tcp
done

ufw allow from "${ALLOWED_OLLAMA_CALLER_IP}" to any port "${OLLAMA_PORT}" proto tcp
ufw --force enable

echo "[step] apply fail2ban config"
mkdir -p /etc/fail2ban
sed \
  -e "s/__BANTIME__/${FAIL2BAN_BANTIME}/g" \
  -e "s/__FINDTIME__/${FAIL2BAN_FINDTIME}/g" \
  -e "s/__MAXRETRY__/${FAIL2BAN_MAXRETRY}/g" \
  -e "s/__SSH_PORT__/${SSH_PORT}/g" \
  "${SCRIPT_DIR}/82.30-jail.local.baseline" > /etc/fail2ban/jail.local
systemctl enable --now fail2ban
systemctl restart fail2ban

echo "[step] apply journald bounds"
mkdir -p /etc/systemd/journald.conf.d
sed \
  -e "s/__SYSTEM_MAX_USE__/${JOURNAL_SYSTEM_MAX_USE}/g" \
  -e "s/__RUNTIME_MAX_USE__/${JOURNAL_RUNTIME_MAX_USE}/g" \
  -e "s/__MAX_RETENTION__/${JOURNAL_MAX_RETENTION}/g" \
  "${SCRIPT_DIR}/82.30-journald-override.conf" > /etc/systemd/journald.conf.d/82.30.conf
systemctl restart systemd-journald

echo "[step] apply unattended-upgrades config"
sed "s/__AUTO_REBOOT__/${UNATTENDED_AUTO_REBOOT}/g" \
  "${SCRIPT_DIR}/82.30-50unattended-upgrades.baseline" > /etc/apt/apt.conf.d/50unattended-upgrades
cp "${SCRIPT_DIR}/82.30-20auto-upgrades.baseline" /etc/apt/apt.conf.d/20auto-upgrades
systemctl enable unattended-upgrades || true
systemctl restart unattended-upgrades || true

echo "82.30 hardening apply: COMPLETE"
echo "Run verifier: bash infrastructure/ollama-gpu/82.30-hardening-verify.sh --env-file ${ENV_FILE}"
