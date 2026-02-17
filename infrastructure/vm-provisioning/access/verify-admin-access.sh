#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 --env-file <path> --keys-file <path>

Verifies 81.160 admin access baseline on current VM.
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

if [[ ! -f "${ENV_FILE}" || ! -f "${KEYS_FILE}" ]]; then
  echo "Missing env or keys file." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

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

check "root ssh login disabled" "sshd -T | grep -q '^permitrootlogin no$'"
if [[ "${ALLOW_PASSWORD_SSH:-false}" == "false" ]]; then
  check "password ssh disabled" "sshd -T | grep -q '^passwordauthentication no$'"
fi
check "ufw active" "sudo ufw status | grep -Eq '^Status: active'"

IFS=',' read -r -a admin_ips <<< "${ADMIN_WORKSTATION_IPS}"
for ip in "${admin_ips[@]}"; do
  ip="$(echo "${ip}" | xargs)"
  if [[ -n "${ip}" ]]; then
    check "ufw ssh allow for ${ip}" "sudo ufw status | grep -Eq '${ip}.*${SSH_PORT}/tcp.*ALLOW'"
  fi
done

tail -n +2 "${KEYS_FILE}" | while IFS=, read -r username public_key; do
  if [[ -z "${username}" || -z "${public_key}" ]]; then
    continue
  fi
  check "user exists ${username}" "id '${username}' >/dev/null"
  check "authorized key present for ${username}" "sudo grep -Fqx '${public_key}' /home/${username}/.ssh/authorized_keys"
done

echo "[evidence] ufw status numbered"
sudo ufw status numbered
echo "[evidence] sshd flags"
sshd -T | egrep 'port |passwordauthentication|permitrootlogin|pubkeyauthentication'

echo "81.160 admin access verification: PASS"
