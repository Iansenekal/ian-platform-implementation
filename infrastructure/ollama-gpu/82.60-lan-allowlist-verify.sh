#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 --env-file <path>

Verifies 82.60 LAN-only bind and UFW allowlist controls for Ollama.
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

required=(LLM_IP OLLAMA_HOST_BIND OLLAMA_MODELS_PATH AI_DATA01_IP ADMIN_WORKSTATION_IPS SSH_PORT OLLAMA_PORT)
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

check "ollama service active" "systemctl is-active --quiet ollama"
check "override has OLLAMA_HOST" "sudo grep -q '^Environment=\"OLLAMA_HOST=${OLLAMA_HOST_BIND}\"$' /etc/systemd/system/ollama.service.d/override.conf"
check "override has OLLAMA_MODELS" "sudo grep -q '^Environment=\"OLLAMA_MODELS=${OLLAMA_MODELS_PATH}\"$' /etc/systemd/system/ollama.service.d/override.conf"
check "11434 listener present" "ss -tulpen | grep -Eq ':${OLLAMA_PORT}\\b'"
check "local tags endpoint" "curl -fsS http://127.0.0.1:${OLLAMA_PORT}/api/tags | jq . >/dev/null"

check "ufw active" "sudo ufw status | grep -Eq '^Status: active'"
check "ufw deny incoming" "sudo ufw status verbose | grep -Eq 'Default: deny \\(incoming\\)'"
check "AI-DATA01 allow rule" "sudo ufw status | grep -Eq '${AI_DATA01_IP}.*${OLLAMA_PORT}/tcp.*ALLOW'"

if [[ "${ALLOW_FRONTEND_CALLER:-false}" == "true" ]]; then
  check "AI-FRONTEND01 allow rule" "sudo ufw status | grep -Eq '${AI_FRONTEND01_IP}.*${OLLAMA_PORT}/tcp.*ALLOW'"
fi

IFS=',' read -r -a admin_ips <<< "${ADMIN_WORKSTATION_IPS}"
for ip in "${admin_ips[@]}"; do
  ip="$(echo "${ip}" | xargs)"
  [[ -z "${ip}" ]] && continue
  check "admin SSH allow rule for ${ip}" "sudo ufw status | grep -Eq '${ip}.*${SSH_PORT}/tcp.*ALLOW'"
  if [[ "${ALLOW_ADMIN_DIAG_ACCESS:-false}" == "true" ]]; then
    check "admin diagnostic 11434 allow rule for ${ip}" "sudo ufw status | grep -Eq '${ip}.*${OLLAMA_PORT}/tcp.*ALLOW'"
  fi
done

echo "[manual-check] from AI-DATA01: curl -s http://${LLM_IP}:${OLLAMA_PORT}/api/tags | jq ."
if [[ "${ALLOW_FRONTEND_CALLER:-false}" == "true" ]]; then
  echo "[manual-check] from AI-FRONTEND01: curl -s http://${LLM_IP}:${OLLAMA_PORT}/api/tags | jq . (must pass)"
else
  echo "[manual-check] from AI-FRONTEND01: curl -s http://${LLM_IP}:${OLLAMA_PORT}/api/tags | jq . (must fail)"
fi
echo "[manual-check] from non-allowlisted host: curl -s http://${LLM_IP}:${OLLAMA_PORT}/api/tags (must fail)"

echo "[evidence] service"
systemctl status ollama --no-pager || true
echo "[evidence] listeners"
ss -tulpen | grep -E ":${OLLAMA_PORT}\\b|:22\\b" || true
echo "[evidence] ufw verbose"
sudo ufw status verbose
echo "[evidence] ufw numbered"
sudo ufw status numbered
echo "[evidence] local tags"
curl -fsS "http://127.0.0.1:${OLLAMA_PORT}/api/tags" | jq .

echo "82.60 lan-only bind + allowlist verify: PASS"
