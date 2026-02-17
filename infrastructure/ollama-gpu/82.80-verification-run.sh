#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 --env-file <path>

Runs 82.80 verification checks on ai-llm01.
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
  echo "Copy infrastructure/ollama-gpu/82.80-verification-inputs.env.example first." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

required=(
  LLM_IP
  AI_DATA01_IP
  ADMIN_WORKSTATION_IPS
  SSH_PORT
  OLLAMA_PORT
  ALLOWLIST_FILE
  MODEL_INVENTORY_DIR
  VERIFICATION_LOG_DIR
  TEST_MODEL
)
for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required variable in ${ENV_FILE}: ${var}" >&2
    exit 1
  fi
done

mkdir -p "${VERIFICATION_LOG_DIR}"
LOG_FILE="${VERIFICATION_LOG_DIR}/82.80-verify-$(date +%F_%H%M%S).log"

exec > >(tee -a "${LOG_FILE}") 2>&1

echo "[info] 82.80 verification log: ${LOG_FILE}"

action() {
  local title=$1
  shift
  echo
  echo "===== ${title} ====="
  "$@"
}

check_cmd() {
  local name=$1
  shift
  echo "[check] ${name}"
  if "$@"; then
    echo "[pass] ${name}"
  else
    echo "[fail] ${name}" >&2
    exit 1
  fi
}

# 1. Baseline host sanity
action "hostnamectl" hostnamectl
action "ip -br addr" ip -br addr
action "ip r" ip r
action "resolvectl status" bash -lc "resolvectl status | sed -n '1,160p'"

# 2. Security baseline proof
action "ufw verbose" sudo ufw status verbose
action "ufw numbered" sudo ufw status numbered
action "listeners" bash -lc "ss -tulpen | head -n 120"

# 3. Ollama service health
action "ollama version" ollama --version
check_cmd "ollama enabled" systemctl is-enabled --quiet ollama
check_cmd "ollama active" systemctl is-active --quiet ollama
action "ollama status" systemctl status ollama --no-pager
action "ollama journal" journalctl -u ollama -n 100 --no-pager

# 4. API health checks
check_cmd "local tags endpoint" bash -lc "curl -fsS http://127.0.0.1:${OLLAMA_PORT}/api/tags | jq . >/dev/null"
action "local tags output" bash -lc "curl -fsS http://127.0.0.1:${OLLAMA_PORT}/api/tags | jq ."

echo "[manual-check] From AI-DATA01 (${AI_DATA01_IP}) run: curl -s http://${LLM_IP}:${OLLAMA_PORT}/api/tags | jq . (must PASS)"
if [[ "${ALLOW_FRONTEND_CALLER:-false}" == "true" ]]; then
  echo "[manual-check] From AI-FRONTEND01 (${AI_FRONTEND01_IP}) run same curl (must PASS)"
else
  echo "[manual-check] From AI-FRONTEND01 (${AI_FRONTEND01_IP}) run same curl (must FAIL)"
fi
echo "[manual-check] From non-allowlisted host run same curl (must FAIL)"

# 5. Model presence and governance checks
action "installed models" ollama list
check_cmd "allowlist file exists" test -f "${ALLOWLIST_FILE}"
check_cmd "model inventory directory exists" test -d "${MODEL_INVENTORY_DIR}"

# 6. Model load test
action "model load sanity" ollama run "${TEST_MODEL}" "Reply with the single word OK."
action "remote generate sample command" bash -lc "echo curl -s http://${LLM_IP}:${OLLAMA_PORT}/api/generate -d '{\"model\":\"${TEST_MODEL}\",\"prompt\":\"Reply with the single word OK.\",\"stream\":false}' | jq .response"

# 7. Latency sanity checks
action "latency tags" bash -lc "time curl -s http://${LLM_IP}:${OLLAMA_PORT}/api/tags >/dev/null"
action "latency generate" bash -lc "time curl -s http://${LLM_IP}:${OLLAMA_PORT}/api/generate -d '{\"model\":\"${TEST_MODEL}\",\"prompt\":\"OK\",\"stream\":false}' >/dev/null"

# 8. GPU acceleration sanity
action "gpu lspci" bash -lc "lspci | grep -Ei 'vga|display'"
action "gpu modules" bash -lc "lsmod | grep -E 'amdgpu|kfd' || true"
action "dev dri" bash -lc "ls -la /dev/dri || true"
action "dev kfd" bash -lc "ls -la /dev/kfd || true"
action "rocm-smi" bash -lc "rocm-smi || true"

echo
check_cmd "ufw deny incoming" bash -lc "sudo ufw status verbose | grep -Eq 'Default: deny \\(incoming\\)'"
check_cmd "AI-DATA01 allowed on Ollama port" bash -lc "sudo ufw status | grep -Eq '${AI_DATA01_IP}.*${OLLAMA_PORT}/tcp.*ALLOW'"

echo "82.80 verification: PASS"
