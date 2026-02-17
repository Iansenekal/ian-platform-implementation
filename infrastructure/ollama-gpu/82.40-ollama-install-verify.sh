#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 --env-file <path>

Verifies 82.40 Ollama install controls on ai-llm01.
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

required=(LLM_IP ALLOWED_CALLER_IP OLLAMA_PORT OLLAMA_HOST_BIND OLLAMA_MODELS_PATH)
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

bind_host="${OLLAMA_HOST_BIND%%:*}"

check "ollama binary installed" "command -v ollama >/dev/null"
check "ollama version works" "ollama --version >/dev/null"
check "ollama service active" "systemctl is-active --quiet ollama"
check "ollama listening on configured port" "ss -tulpen | grep -Eq ':${OLLAMA_PORT}\\b'"

if [[ "${bind_host}" == "127.0.0.1" || "${bind_host}" == "localhost" ]]; then
  check "ollama loopback bind" "ss -tulpen | grep -Eq '127.0.0.1:${OLLAMA_PORT}\\b'"
fi

check "override file includes OLLAMA_HOST" "sudo grep -q '^Environment=\"OLLAMA_HOST=' /etc/systemd/system/ollama.service.d/override.conf"
check "override file includes OLLAMA_MODELS" "sudo grep -q '^Environment=\"OLLAMA_MODELS=' /etc/systemd/system/ollama.service.d/override.conf"
check "models path directory exists" "[[ -d '${OLLAMA_MODELS_PATH}' ]]"
check "models path owned by ollama" "stat -c '%U:%G' '${OLLAMA_MODELS_PATH}' | grep -q '^ollama:ollama$'"
check "local api tags returns json" "curl -fsS http://127.0.0.1:${OLLAMA_PORT}/api/tags | jq . >/dev/null"
check "ufw active" "sudo ufw status | grep -Eq '^Status: active'"
check "caller allow rule present" "sudo ufw status | grep -Eq '${ALLOWED_CALLER_IP}.*${OLLAMA_PORT}/tcp.*ALLOW'"

check "gpu present" "lspci | grep -Eqi 'vga|display'"
check "gpu driver binding listed" "lspci -k | grep -A3 -Eqi 'vga|display'"

if [[ -e /dev/dri ]]; then
  echo "[pass] /dev/dri present"
else
  echo "[fail] /dev/dri missing" >&2
  exit 1
fi

if [[ -e /dev/kfd ]]; then
  echo "[pass] /dev/kfd present"
else
  echo "[warn] /dev/kfd missing (ROCm may be incomplete)"
fi

if command -v rocm-smi >/dev/null 2>&1; then
  echo "[check] rocm-smi"
  rocm-smi || true
else
  echo "[info] rocm-smi not installed"
fi

echo "[evidence] ollama version"
ollama --version
echo "[evidence] service status"
systemctl status ollama --no-pager || true
echo "[evidence] listeners"
ss -tulpen | grep -E ":${OLLAMA_PORT}\\b|:22\\b" || true
echo "[evidence] local tags"
curl -fsS "http://127.0.0.1:${OLLAMA_PORT}/api/tags" | jq .
echo "[evidence] ufw verbose"
sudo ufw status verbose
echo "[evidence] lspci"
lspci -k | grep -A3 -Ei 'vga|display' || true

echo "82.40 ollama install verify: PASS"
