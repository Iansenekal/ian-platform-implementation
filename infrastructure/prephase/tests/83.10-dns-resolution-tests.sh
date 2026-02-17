#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 --env-file <path>

Runs 83.10 DNS and naming resolution checks across AI-DATA01, AI-FRONTEND01, and LLM.
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
  echo "Copy infrastructure/prephase/tests/83.10-dns-inputs.env.example first." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

required=(
  DNS_SERVER SEARCH_DOMAIN
  AI_DATA01_IP AI_DATA01_FQDN AI_DATA01_SSH_USER
  AI_FRONTEND01_IP AI_FRONTEND01_FQDN AI_FRONTEND01_SSH_USER
  LLM_IP LLM_FQDN LLM_SSH_USER
  GATEWAY_FQDN FRONTEND_FQDN PTR_REQUIRED_IPS
)
for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required variable in ${ENV_FILE}: ${var}" >&2
    exit 1
  fi
done

LOG_DIR="infrastructure/prephase/tests/logs"
mkdir -p "${LOG_DIR}"
LOG_FILE="${LOG_DIR}/83.10-dns-$(date +%F_%H%M%S).log"
exec > >(tee -a "${LOG_FILE}") 2>&1

echo "[info] log file: ${LOG_FILE}"

run_ssh() {
  local user=$1
  local host=$2
  local cmd=$3
  ssh -o BatchMode=yes -o ConnectTimeout=8 "${user}@${host}" "${cmd}"
}

check_contains() {
  local name=$1
  local haystack=$2
  local needle=$3
  echo "[check] ${name}"
  if [[ "${haystack}" == *"${needle}"* ]]; then
    echo "[pass] ${name}"
  else
    echo "[fail] ${name} (missing: ${needle})" >&2
    exit 1
  fi
}

check_host_forward() {
  local user=$1 host=$2 fqdn=$3 expected_ip=$4
  echo "[check] forward lookup ${fqdn} on ${host}"
  out="$(run_ssh "${user}" "${host}" "getent hosts ${fqdn} || true")"
  echo "${out}"
  check_contains "${fqdn} resolves to ${expected_ip}" "${out}" "${expected_ip}"
}

# 1. Resolver configuration per node
for node in data frontend llm; do
  case "${node}" in
    data)
      user="${AI_DATA01_SSH_USER}"; host="${AI_DATA01_IP}" ;;
    frontend)
      user="${AI_FRONTEND01_SSH_USER}"; host="${AI_FRONTEND01_IP}" ;;
    llm)
      user="${LLM_SSH_USER}"; host="${LLM_IP}" ;;
  esac
  echo "===== Resolver status on ${node} (${host}) ====="
  resolv_out="$(run_ssh "${user}" "${host}" "resolvectl status | sed -n '1,220p'")"
  echo "${resolv_out}"
  check_contains "${node} uses DNS ${DNS_SERVER}" "${resolv_out}" "${DNS_SERVER}"
  check_contains "${node} has search domain ${SEARCH_DOMAIN}" "${resolv_out}" "${SEARCH_DOMAIN}"
done

# 2. Forward lookup tests from each node
for node in data frontend llm; do
  case "${node}" in
    data)
      user="${AI_DATA01_SSH_USER}"; host="${AI_DATA01_IP}" ;;
    frontend)
      user="${AI_FRONTEND01_SSH_USER}"; host="${AI_FRONTEND01_IP}" ;;
    llm)
      user="${LLM_SSH_USER}"; host="${LLM_IP}" ;;
  esac
  echo "===== Forward lookups on ${node} (${host}) ====="
  check_host_forward "${user}" "${host}" "${AI_DATA01_FQDN}" "${AI_DATA01_IP}"
  check_host_forward "${user}" "${host}" "${AI_FRONTEND01_FQDN}" "${AI_FRONTEND01_IP}"
  check_host_forward "${user}" "${host}" "${LLM_FQDN}" "${LLM_IP}"
  run_ssh "${user}" "${host}" "dig +short ${GATEWAY_FQDN}"
  run_ssh "${user}" "${host}" "dig +short ${FRONTEND_FQDN}"
done

# 3. Reverse lookup tests from AI-DATA01
echo "===== Reverse lookups from AI-DATA01 ====="
IFS=',' read -r -a ptr_ips <<< "${PTR_REQUIRED_IPS}"
for ip in "${ptr_ips[@]}"; do
  ip="$(echo "${ip}" | xargs)"
  [[ -z "${ip}" ]] && continue
  ptr_out="$(run_ssh "${AI_DATA01_SSH_USER}" "${AI_DATA01_IP}" "dig -x ${ip} +short || true")"
  echo "${ip} -> ${ptr_out}"
  if [[ -z "${ptr_out}" ]]; then
    echo "[fail] PTR missing for ${ip}" >&2
    exit 1
  fi
done

# 4. DNS server targeted query check from AI-DATA01
echo "===== Targeted DNS server query check ====="
run_ssh "${AI_DATA01_SSH_USER}" "${AI_DATA01_IP}" "dig @${DNS_SERVER} +short ${AI_DATA01_FQDN}"
run_ssh "${AI_DATA01_SSH_USER}" "${AI_DATA01_IP}" "dig @${DNS_SERVER} +short ${GATEWAY_FQDN}"

# 5. Manual Windows-specific checks reminder
echo "[manual-check] On Windows DNS host run:"
echo "  Resolve-DnsName ${AI_DATA01_FQDN}"
echo "  Resolve-DnsName ${GATEWAY_FQDN}"
echo "  Resolve-DnsName ${AI_DATA01_IP} -Type PTR"
echo "  Verify DNS Forwarders tab and recursion policy"

echo "83.10 dns and naming resolution tests: PASS"
