#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 --env-file <path>

Installs and configures Ollama for runbook 82.40 on ai-llm01.
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
  echo "Copy infrastructure/ollama-gpu/82.40-ollama-install-inputs.env.example first." >&2
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
  LLM_HOSTNAME
  LLM_IP
  ALLOWED_CALLER_IP
  ADMIN_WORKSTATION_IPS
  SSH_PORT
  OLLAMA_PORT
  OLLAMA_HOST_BIND
  OLLAMA_MODELS_PATH
)
for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required variable in ${ENV_FILE}: ${var}" >&2
    exit 1
  fi
done

echo "[step] install dependencies"
apt update
apt -y install ca-certificates curl jq

echo "[step] create deterministic filesystem layout"
mkdir -p /opt/ollama/{bin,config,models,logs,run,health,secrets}
chown -R root:root /opt/ollama
chmod -R 0750 /opt/ollama

if ! id ollama >/dev/null 2>&1; then
  useradd --system --home /opt/ollama --shell /usr/sbin/nologin ollama
fi

chown -R ollama:ollama /opt/ollama/{models,logs,run}
chmod -R 0750 /opt/ollama/{models,logs,run}

if [[ "${OLLAMA_MODELS_PATH}" != "/opt/ollama/models" ]]; then
  mkdir -p "${OLLAMA_MODELS_PATH}"
  chown -R ollama:ollama "${OLLAMA_MODELS_PATH}"
  chmod -R 0750 "${OLLAMA_MODELS_PATH}"
fi

echo "[step] install ollama"
curl -fsSL https://ollama.com/install.sh | sh

echo "[step] configure systemd override"
mkdir -p /etc/systemd/system/ollama.service.d
sed \
  -e "s|__OLLAMA_HOST_BIND__|${OLLAMA_HOST_BIND}|g" \
  "${SCRIPT_DIR}/82.40-ollama-override.conf.baseline" > /etc/systemd/system/ollama.service.d/override.conf

systemctl daemon-reload
systemctl enable ollama
systemctl restart ollama

echo "[step] apply ufw allowlist"
ufw default deny incoming
ufw default allow outgoing

IFS=',' read -r -a admin_ips <<< "${ADMIN_WORKSTATION_IPS}"
for ip in "${admin_ips[@]}"; do
  ip="$(echo "${ip}" | xargs)"
  [[ -z "${ip}" ]] && continue
  ufw allow from "${ip}" to any port "${SSH_PORT}" proto tcp
done

ufw allow from "${ALLOWED_CALLER_IP}" to any port "${OLLAMA_PORT}" proto tcp

if [[ "${ALLOW_LAN_ICMP:-true}" == "true" ]]; then
  ufw allow proto icmp from 10.10.5.0/24
fi

ufw --force enable

echo "82.40 ollama install apply: COMPLETE"
echo "Run verifier: bash infrastructure/ollama-gpu/82.40-ollama-install-verify.sh --env-file ${ENV_FILE}"
