#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 [--env-file path]

Applies 81.150 baseline hardening controls on the current Ubuntu VM.
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

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root (sudo)." >&2
  exit 1
fi

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}" >&2
  echo "Copy infrastructure/vm-provisioning/hardening/81.150-hardening-inputs.env.example first." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
source "${ENV_FILE}"

required=(
  ADMIN_USER
  ADMIN_SUBNET_CIDR
  SSH_PORT
  ALLOW_PASSWORD_SSH
  TIMEZONE
  UFW_DEFAULT_INCOMING
  UFW_DEFAULT_OUTGOING
  FAIL2BAN_MAXRETRY
  FAIL2BAN_FINDTIME
  FAIL2BAN_BANTIME
  UNATTENDED_AUTO_REBOOT
)
for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required variable in ${ENV_FILE}: ${var}" >&2
    exit 1
  fi
done

if ! id "${ADMIN_USER}" >/dev/null 2>&1; then
  echo "Admin user does not exist on this VM: ${ADMIN_USER}" >&2
  exit 1
fi

password_auth="no"
if [[ "${ALLOW_PASSWORD_SSH}" == "true" ]]; then
  password_auth="yes"
fi

echo "[step] install baseline packages"
apt-get update -y
apt-get install -y --no-install-recommends \
  ufw fail2ban unattended-upgrades apt-listchanges \
  curl ca-certificates jq

echo "[step] ensure platform-admins group and admin membership"
groupadd -f platform-admins
usermod -aG platform-admins "${ADMIN_USER}"

echo "[step] apply sshd baseline"
sed \
  -e "s/__SSH_PORT__/${SSH_PORT}/g" \
  -e "s/__PASSWORD_AUTH__/${password_auth}/g" \
  "${SCRIPT_DIR}/sshd_config.baseline" > /etc/ssh/sshd_config
sshd -t
systemctl restart ssh
systemctl enable ssh

echo "[step] lock root account"
passwd -l root || true

echo "[step] apply ufw baseline"
ufw --force reset
ufw default "${UFW_DEFAULT_INCOMING}" incoming
ufw default "${UFW_DEFAULT_OUTGOING}" outgoing
ufw allow from "${ADMIN_SUBNET_CIDR}" to any port "${SSH_PORT}" proto tcp
ufw --force enable

echo "[step] apply fail2ban baseline"
mkdir -p /etc/fail2ban/jail.d
sed \
  -e "s/__MAXRETRY__/${FAIL2BAN_MAXRETRY}/g" \
  -e "s/__FINDTIME__/${FAIL2BAN_FINDTIME}/g" \
  -e "s/__BANTIME__/${FAIL2BAN_BANTIME}/g" \
  "${SCRIPT_DIR}/sshd.local.baseline" > /etc/fail2ban/jail.d/sshd.local
systemctl enable --now fail2ban
systemctl restart fail2ban

echo "[step] apply unattended-upgrades baseline"
sed "s/__AUTO_REBOOT__/${UNATTENDED_AUTO_REBOOT}/g" \
  "${SCRIPT_DIR}/50unattended-upgrades.baseline" > /etc/apt/apt.conf.d/50unattended-upgrades
cp "${SCRIPT_DIR}/20auto-upgrades.baseline" /etc/apt/apt.conf.d/20auto-upgrades
systemctl enable unattended-upgrades || true
systemctl restart unattended-upgrades || true

echo "[step] set timezone"
timedatectl set-timezone "${TIMEZONE}"

cat <<EOF2
81.150 base hardening applied.

Important:
- Keep current SSH session open and validate a second key-based SSH login before closing.
- Run verifier:
  bash infrastructure/vm-provisioning/hardening/verify-hardening.sh --env-file ${ENV_FILE}
EOF2
