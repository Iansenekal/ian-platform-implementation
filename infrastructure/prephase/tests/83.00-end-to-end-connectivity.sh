#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 --env-file <path>

Runs 83.00 end-to-end connectivity checks across AI-FRONTEND01, AI-DATA01, and LLM pointer server.
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
  echo "Copy infrastructure/prephase/tests/83.00-connectivity-inputs.env.example first." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

required=(
  AI_DATA01_IP AI_FRONTEND01_IP LLM_IP DNS_SERVER SEARCH_DOMAIN
  AI_DATA01_SSH_USER AI_FRONTEND01_SSH_USER LLM_SSH_USER
  GATEWAY_HOST GATEWAY_PORT GATEWAY_HEALTH_PATH
  LLM_PORT ALLOW_FRONTEND_TO_LLM BLOCKED_DATA_PORTS
)
for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required variable in ${ENV_FILE}: ${var}" >&2
    exit 1
  fi
done

LOG_DIR="infrastructure/prephase/tests/logs"
mkdir -p "${LOG_DIR}"
LOG_FILE="${LOG_DIR}/83.00-connectivity-$(date +%F_%H%M%S).log"
exec > >(tee -a "${LOG_FILE}") 2>&1

echo "[info] log file: ${LOG_FILE}"

run_ssh() {
  local user=$1
  local host=$2
  local cmd=$3
  ssh -o BatchMode=yes -o ConnectTimeout=8 "${user}@${host}" "${cmd}"
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

# 1. DNS checks on all nodes
for node in frontend data llm; do
  case "${node}" in
    frontend)
      user="${AI_FRONTEND01_SSH_USER}"; host="${AI_FRONTEND01_IP}" ;;
    data)
      user="${AI_DATA01_SSH_USER}"; host="${AI_DATA01_IP}" ;;
    llm)
      user="${LLM_SSH_USER}"; host="${LLM_IP}" ;;
  esac
  echo "===== DNS checks on ${node} (${host}) ====="
  run_ssh "${user}" "${host}" "resolvectl status | sed -n '1,160p'"
  run_ssh "${user}" "${host}" "getent hosts ${GATEWAY_HOST} || true"
  run_ssh "${user}" "${host}" "getent hosts ${AI_FRONTEND01_HOST:-ai-frontend01.lab.local} || true"
  run_ssh "${user}" "${host}" "getent hosts ${AI_DATA01_HOST:-ai-data01.lab.local} || true"
  run_ssh "${user}" "${host}" "getent hosts ${LLM_HOST:-llm.lab.local} || true"
done

# 2. Basic route + reachability from frontend and data
for node in frontend data; do
  case "${node}" in
    frontend)
      user="${AI_FRONTEND01_SSH_USER}"; host="${AI_FRONTEND01_IP}" ;;
    data)
      user="${AI_DATA01_SSH_USER}"; host="${AI_DATA01_IP}" ;;
  esac
  echo "===== Route/reachability on ${node} (${host}) ====="
  run_ssh "${user}" "${host}" "ip r"
  run_ssh "${user}" "${host}" "ping -c 2 ${AI_DATA01_IP} >/dev/null"
  run_ssh "${user}" "${host}" "ping -c 2 ${AI_FRONTEND01_IP} >/dev/null"
  run_ssh "${user}" "${host}" "ping -c 2 ${LLM_IP} >/dev/null"
done

# 3. Port checks
check_cmd "frontend to gateway port open" run_ssh "${AI_FRONTEND01_SSH_USER}" "${AI_FRONTEND01_IP}" "nc -vz ${AI_DATA01_IP} ${GATEWAY_PORT}"
check_cmd "frontend gateway health over TLS" run_ssh "${AI_FRONTEND01_SSH_USER}" "${AI_FRONTEND01_IP}" "curl -ksf https://${GATEWAY_HOST}:${GATEWAY_PORT}${GATEWAY_HEALTH_PATH} >/dev/null"

IFS=',' read -r -a blocked_ports <<< "${BLOCKED_DATA_PORTS}"
for p in "${blocked_ports[@]}"; do
  p="$(echo "${p}" | xargs)"
  [[ -z "${p}" ]] && continue
  echo "[check] frontend cannot reach AI-DATA01 port ${p}"
  if run_ssh "${AI_FRONTEND01_SSH_USER}" "${AI_FRONTEND01_IP}" "nc -vz -w 2 ${AI_DATA01_IP} ${p}"; then
    echo "[fail] frontend unexpectedly reached blocked port ${p}" >&2
    exit 1
  fi
  echo "[pass] blocked port ${p} is not reachable"
done

check_cmd "data to llm port open" run_ssh "${AI_DATA01_SSH_USER}" "${AI_DATA01_IP}" "nc -vz ${LLM_IP} ${LLM_PORT}"
check_cmd "data to llm tags json" run_ssh "${AI_DATA01_SSH_USER}" "${AI_DATA01_IP}" "curl -fsS http://${LLM_IP}:${LLM_PORT}/api/tags | jq . >/dev/null"

echo "[check] frontend to llm policy behavior"
if [[ "${ALLOW_FRONTEND_TO_LLM}" == "true" ]]; then
  check_cmd "frontend to llm allowed" run_ssh "${AI_FRONTEND01_SSH_USER}" "${AI_FRONTEND01_IP}" "curl -fsS http://${LLM_IP}:${LLM_PORT}/api/tags | jq . >/dev/null"
else
  if run_ssh "${AI_FRONTEND01_SSH_USER}" "${AI_FRONTEND01_IP}" "curl -fsS --max-time 3 http://${LLM_IP}:${LLM_PORT}/api/tags >/dev/null"; then
    echo "[fail] frontend unexpectedly reached llm while policy is deny" >&2
    exit 1
  fi
  echo "[pass] frontend to llm blocked as expected"
fi

# 4. TLS certificate sanity
check_cmd "gateway cert details retrievable" run_ssh "${AI_FRONTEND01_SSH_USER}" "${AI_FRONTEND01_IP}" "echo | openssl s_client -connect ${GATEWAY_HOST}:${GATEWAY_PORT} -servername ${GATEWAY_HOST} 2>/dev/null | openssl x509 -noout -subject -issuer -dates"

# 5. Listener and UFW proof
for node in frontend data llm; do
  case "${node}" in
    frontend)
      user="${AI_FRONTEND01_SSH_USER}"; host="${AI_FRONTEND01_IP}" ;;
    data)
      user="${AI_DATA01_SSH_USER}"; host="${AI_DATA01_IP}" ;;
    llm)
      user="${LLM_SSH_USER}"; host="${LLM_IP}" ;;
  esac
  echo "===== Listener/UFW on ${node} (${host}) ====="
  run_ssh "${user}" "${host}" "ss -tulpen | head -n 120"
  run_ssh "${user}" "${host}" "sudo ufw status verbose"
  run_ssh "${user}" "${host}" "sudo ufw status numbered"
done

echo "83.00 end-to-end connectivity: PASS"
