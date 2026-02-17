#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 --env-file <path> --keys-file <path>

Applies 81.160 admin access baseline on current VM:
- creates/updates admin users
- installs authorized_keys
- enforces UFW SSH allowlist from approved admin IPs
USAGE
}

ENV_FILE=""
KEYS_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file)
      ENV_FILE="${2:-}"
      shift 2
      ;;
    --keys-file)
      KEYS_FILE="${2:-}"
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

if [[ -z "${ENV_FILE}" || -z "${KEYS_FILE}" ]]; then
  usage
  exit 1
fi

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root (sudo)." >&2
  exit 1
fi

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}" >&2
  exit 1
fi

if [[ ! -f "${KEYS_FILE}" ]]; then
  echo "Missing keys file: ${KEYS_FILE}" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

required=(SSH_PORT ADMIN_WORKSTATION_IPS ADMIN_USERS)
for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required variable in ${ENV_FILE}: ${var}" >&2
    exit 1
  fi
done

groupadd -f platform-admins

tail -n +2 "${KEYS_FILE}" | while IFS=, read -r username public_key; do
  if [[ -z "${username}" || -z "${public_key}" ]]; then
    continue
  fi
  if [[ "${public_key}" != ssh-ed25519* && "${public_key}" != ssh-rsa* && "${public_key}" != ecdsa-* ]]; then
    echo "Invalid public key format for ${username}" >&2
    exit 1
  fi

  if ! id "${username}" >/dev/null 2>&1; then
    useradd --create-home --shell /bin/bash "${username}"
    passwd -l "${username}" >/dev/null 2>&1 || true
  fi

  usermod -aG sudo "${username}"
  usermod -aG platform-admins "${username}"

  install -d -m 700 -o "${username}" -g "${username}" "/home/${username}/.ssh"
  auth_file="/home/${username}/.ssh/authorized_keys"
  touch "${auth_file}"
  chown "${username}:${username}" "${auth_file}"
  chmod 600 "${auth_file}"

  if ! grep -Fqx "${public_key}" "${auth_file}"; then
    echo "${public_key}" >> "${auth_file}"
  fi
done

if [[ "${REMOVE_BROAD_SSH_RULE:-false}" == "true" && -n "${BROAD_SSH_SUBNET:-}" ]]; then
  mapfile -t lines < <(ufw status numbered | grep "${BROAD_SSH_SUBNET}" || true)
  if [[ "${#lines[@]}" -gt 0 ]]; then
    mapfile -t numbers < <(printf '%s\n' "${lines[@]}" | sed -E 's/^\[([0-9]+)\].*/\1/' | sort -rn)
    for n in "${numbers[@]}"; do
      ufw --force delete "${n}" || true
    done
  fi
fi

IFS=',' read -r -a admin_ips <<< "${ADMIN_WORKSTATION_IPS}"
for ip in "${admin_ips[@]}"; do
  ip="$(echo "${ip}" | xargs)"
  if [[ -n "${ip}" ]]; then
    ufw allow from "${ip}" to any port "${SSH_PORT}" proto tcp >/dev/null
  fi
done

echo "81.160 admin access provisioning complete."
echo "Keep existing SSH session open and test key login from each approved admin workstation."
