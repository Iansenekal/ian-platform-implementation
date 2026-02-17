#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 --env-file <path>

Runs 83.20 security smoke tests across data/frontend/llm nodes.
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
  echo "Copy infrastructure/prephase/tests/83.20-security-smoke-inputs.env.example first." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

required=(
  AI_DATA01_IP AI_DATA01_SSH_USER
  AI_FRONTEND01_IP AI_FRONTEND01_SSH_USER
  LLM_IP LLM_SSH_USER
  ADMIN_SSH_USER LLM_PORT ALLOW_FRONTEND_TO_LLM BLOCKED_DATA_PORTS NMAP_TARGET_PORTS
)
for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required variable in ${ENV_FILE}: ${var}" >&2
    exit 1
  fi
done

LOG_DIR="infrastructure/prephase/tests/logs"
mkdir -p "${LOG_DIR}"
LOG_FILE="${LOG_DIR}/83.20-security-smoke-$(date +%F_%H%M%S).log"
exec > >(tee -a "${LOG_FILE}") 2>&1

echo "[info] log file: ${LOG_FILE}"

run_ssh() {
  local user=$1 host=$2 cmd=$3
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

check_ufw_host() {
  local user=$1 host=$2 name=$3
  echo "===== UFW/listeners on ${name} (${host}) ====="
  out="$(run_ssh "${user}" "${host}" "sudo ufw status verbose")"
  echo "${out}"
  if [[ "${out}" != *"Status: active"* || "${out}" != *"Default: deny (incoming)"* ]]; then
    echo "[fail] ${name} ufw baseline not enforced" >&2
    exit 1
  fi
  run_ssh "${user}" "${host}" "sudo ufw status numbered"
  run_ssh "${user}" "${host}" "ss -tulpen | head -n 160"
}

# 1) UFW + listener checks
check_ufw_host "${AI_DATA01_SSH_USER}" "${AI_DATA01_IP}" "AI-DATA01"
check_ufw_host "${AI_FRONTEND01_SSH_USER}" "${AI_FRONTEND01_IP}" "AI-FRONTEND01"
check_ufw_host "${LLM_SSH_USER}" "${LLM_IP}" "LLM"

# 2) SSH allowed from this admin source
check_cmd "ssh to AI-DATA01 from allowlisted admin" run_ssh "${ADMIN_SSH_USER}" "${AI_DATA01_IP}" "echo OK"
check_cmd "ssh to AI-FRONTEND01 from allowlisted admin" run_ssh "${ADMIN_SSH_USER}" "${AI_FRONTEND01_IP}" "echo OK"
check_cmd "ssh to LLM from allowlisted admin" run_ssh "${ADMIN_SSH_USER}" "${LLM_IP}" "echo OK"

# 3) Service restriction checks
check_cmd "AI-DATA01 to LLM /api/tags allowed" run_ssh "${AI_DATA01_SSH_USER}" "${AI_DATA01_IP}" "curl -fsS http://${LLM_IP}:${LLM_PORT}/api/tags | jq . >/dev/null"

IFS=',' read -r -a blocked_ports <<< "${BLOCKED_DATA_PORTS}"
for p in "${blocked_ports[@]}"; do
  p="$(echo "${p}" | xargs)"
  [[ -z "${p}" ]] && continue
  echo "[check] AI-FRONTEND01 cannot reach AI-DATA01:${p}"
  if run_ssh "${AI_FRONTEND01_SSH_USER}" "${AI_FRONTEND01_IP}" "nc -vz -w 2 ${AI_DATA01_IP} ${p}"; then
    echo "[fail] AI-FRONTEND01 unexpectedly reached blocked AI-DATA01 port ${p}" >&2
    exit 1
  fi
  echo "[pass] blocked AI-DATA01 port ${p} not reachable"
done

if [[ "${ALLOW_FRONTEND_TO_LLM}" == "true" ]]; then
  check_cmd "AI-FRONTEND01 allowed to LLM /api/tags" run_ssh "${AI_FRONTEND01_SSH_USER}" "${AI_FRONTEND01_IP}" "curl -fsS http://${LLM_IP}:${LLM_PORT}/api/tags | jq . >/dev/null"
else
  echo "[check] AI-FRONTEND01 blocked from LLM /api/tags"
  if run_ssh "${AI_FRONTEND01_SSH_USER}" "${AI_FRONTEND01_IP}" "curl -fsS --max-time 3 http://${LLM_IP}:${LLM_PORT}/api/tags >/dev/null"; then
    echo "[fail] AI-FRONTEND01 unexpectedly reached LLM while policy is deny" >&2
    exit 1
  fi
  echo "[pass] AI-FRONTEND01 blocked from LLM as expected"
fi

# 4) Non-allowlisted host tests (optional automation)
if [[ -n "${NON_ALLOWED_HOST_IP:-}" && -n "${NON_ALLOWED_HOST_SSH_USER:-}" ]]; then
  echo "===== Non-allowlisted host automated checks (${NON_ALLOWED_HOST_IP}) ====="
  check_cmd "nmap AI-DATA01 targeted" run_ssh "${NON_ALLOWED_HOST_SSH_USER}" "${NON_ALLOWED_HOST_IP}" "nmap -Pn -p ${NMAP_TARGET_PORTS} ${AI_DATA01_IP}"
  check_cmd "nmap AI-FRONTEND01 targeted" run_ssh "${NON_ALLOWED_HOST_SSH_USER}" "${NON_ALLOWED_HOST_IP}" "nmap -Pn -p ${NMAP_TARGET_PORTS} ${AI_FRONTEND01_IP}"
  check_cmd "nmap LLM targeted" run_ssh "${NON_ALLOWED_HOST_SSH_USER}" "${NON_ALLOWED_HOST_IP}" "nmap -Pn -p ${NMAP_TARGET_PORTS} ${LLM_IP}"

  echo "[check] SSH from non-allowlisted host to AI-DATA01 must fail"
  if run_ssh "${NON_ALLOWED_HOST_SSH_USER}" "${NON_ALLOWED_HOST_IP}" "ssh -o BatchMode=yes -o ConnectTimeout=3 ${ADMIN_SSH_USER}@${AI_DATA01_IP} 'echo SHOULD_NOT_PASS'"; then
    echo "[fail] non-allowlisted host unexpectedly SSH'd to AI-DATA01" >&2
    exit 1
  fi
  echo "[pass] non-allowlisted SSH blocked (AI-DATA01)"

  echo "[check] non-allowlisted host blocked from LLM tags"
  if run_ssh "${NON_ALLOWED_HOST_SSH_USER}" "${NON_ALLOWED_HOST_IP}" "curl -fsS --max-time 3 http://${LLM_IP}:${LLM_PORT}/api/tags >/dev/null"; then
    echo "[fail] non-allowlisted host unexpectedly reached LLM /api/tags" >&2
    exit 1
  fi
  echo "[pass] non-allowlisted host blocked from LLM /api/tags"
else
  echo "[manual-check] Non-allowlisted host details not set; run these manually:"
  echo "  nmap -Pn -p ${NMAP_TARGET_PORTS} ${AI_DATA01_IP}"
  echo "  nmap -Pn -p ${NMAP_TARGET_PORTS} ${AI_FRONTEND01_IP}"
  echo "  nmap -Pn -p ${NMAP_TARGET_PORTS} ${LLM_IP}"
  echo "  ssh ${ADMIN_SSH_USER}@${AI_DATA01_IP}  # must fail"
  echo "  curl -m 3 -v http://${LLM_IP}:${LLM_PORT}/api/tags  # must fail"
fi

echo "83.20 security smoke tests: PASS"
