#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 --env-file <path>

Applies 82.60 LAN-only bind and UFW allowlist controls for Ollama.
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
  echo "Copy infrastructure/ollama-gpu/82.60-lan-allowlist-inputs.env.example first." >&2
  exit 1
fi

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root (sudo)." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

required=(
  LLM_IP
  OLLAMA_HOST_BIND
  OLLAMA_MODELS_PATH
  AI_DATA01_IP
  ADMIN_WORKSTATION_IPS
  SSH_PORT
  OLLAMA_PORT
)
for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required variable in ${ENV_FILE}: ${var}" >&2
    exit 1
  fi
done

echo "[step] configure ollama bind override"
mkdir -p /etc/systemd/system/ollama.service.d
cat > /etc/systemd/system/ollama.service.d/override.conf <<CONF
[Service]
Environment="OLLAMA_HOST=${OLLAMA_HOST_BIND}"
Environment="OLLAMA_MODELS=${OLLAMA_MODELS_PATH}"
CONF

systemctl daemon-reload
systemctl restart ollama
systemctl enable ollama

echo "[step] apply deterministic UFW allowlist"
ufw --force reset
ufw default deny incoming
ufw default allow outgoing

IFS=',' read -r -a admin_ips <<< "${ADMIN_WORKSTATION_IPS}"
for ip in "${admin_ips[@]}"; do
  ip="$(echo "${ip}" | xargs)"
  [[ -z "${ip}" ]] && continue
  ufw allow from "${ip}" to any port "${SSH_PORT}" proto tcp
done

ufw allow from "${AI_DATA01_IP}" to any port "${OLLAMA_PORT}" proto tcp

if [[ "${ALLOW_FRONTEND_CALLER:-false}" == "true" ]]; then
  if [[ -z "${AI_FRONTEND01_IP:-}" ]]; then
    echo "ALLOW_FRONTEND_CALLER=true but AI_FRONTEND01_IP missing" >&2
    exit 1
  fi
  ufw allow from "${AI_FRONTEND01_IP}" to any port "${OLLAMA_PORT}" proto tcp
fi

if [[ "${ALLOW_ADMIN_DIAG_ACCESS:-false}" == "true" ]]; then
  for ip in "${admin_ips[@]}"; do
    ip="$(echo "${ip}" | xargs)"
    [[ -z "${ip}" ]] && continue
    ufw allow from "${ip}" to any port "${OLLAMA_PORT}" proto tcp
  done
fi

ufw --force enable

echo "82.60 lan-only bind + allowlist apply: COMPLETE"
echo "Run verifier: bash infrastructure/ollama-gpu/82.60-lan-allowlist-verify.sh --env-file ${ENV_FILE}"
