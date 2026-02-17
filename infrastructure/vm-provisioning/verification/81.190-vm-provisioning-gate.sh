#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 --env-file <path> [--evidence-dir <path>]

Runs 81.190 VM provisioning verification gate from an admin workstation.
USAGE
}

ENV_FILE=""
EVIDENCE_DIR="artifacts/vm-provisioning-gate"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file)
      ENV_FILE="${2:-}"
      shift 2
      ;;
    --evidence-dir)
      EVIDENCE_DIR="${2:-}"
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

required=(
  ADMIN_USER
  SSH_PORT
  GATEWAY
  DNS_SERVER
  SEARCH_DOMAIN
  TIMEZONE
  MAX_ROOT_USAGE_PERCENT
  REQUIRED_VMS
)
for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required variable in ${ENV_FILE}: ${var}" >&2
    exit 1
  fi
done

mkdir -p "${EVIDENCE_DIR}"
SUMMARY="${EVIDENCE_DIR}/summary.txt"
: > "${SUMMARY}"

run_local_capture() {
  local vm=$1
  local name=$2
  shift 2
  local out="${EVIDENCE_DIR}/${vm}_${name}.txt"
  {
    echo "# command: $*"
    echo "# timestamp: $(date -Iseconds)"
    "$@"
  } > "${out}" 2>&1
}

run_remote_capture() {
  local vm=$1
  local ip=$2
  local name=$3
  local cmd=$4
  local out="${EVIDENCE_DIR}/${vm}_${name}.txt"
  {
    echo "# remote: ${ADMIN_USER}@${ip}"
    echo "# command: ${cmd}"
    echo "# timestamp: $(date -Iseconds)"
    # shellcheck disable=SC2086
    ssh ${SSH_OPTIONS:-"-o BatchMode=yes -o ConnectTimeout=8 -o StrictHostKeyChecking=accept-new"} -p "${SSH_PORT}" "${ADMIN_USER}@${ip}" "${cmd}"
  } > "${out}" 2>&1
}

check_remote() {
  local vm=$1
  local ip=$2
  local label=$3
  local cmd=$4
  if ssh ${SSH_OPTIONS:-"-o BatchMode=yes -o ConnectTimeout=8 -o StrictHostKeyChecking=accept-new"} -p "${SSH_PORT}" "${ADMIN_USER}@${ip}" "${cmd}" >/dev/null 2>&1; then
    echo "[pass] ${vm}: ${label}" | tee -a "${SUMMARY}"
    return 0
  fi
  echo "[fail] ${vm}: ${label}" | tee -a "${SUMMARY}" >&2
  return 1
}

check_local() {
  local label=$1
  shift
  if "$@" >/dev/null 2>&1; then
    echo "[pass] ${label}" | tee -a "${SUMMARY}"
    return 0
  fi
  echo "[fail] ${label}" | tee -a "${SUMMARY}" >&2
  return 1
}

validate_vm() {
  local vm=$1
  local ip=$2
  local expected_host=$3
  local failures=0

  echo "== ${vm} (${ip}) ==" | tee -a "${SUMMARY}"

  run_local_capture "${vm}" "admin_ping" ping -c 2 "${ip}"
  if ! check_local "${vm}: ping from admin workstation" ping -c 2 "${ip}"; then
    failures=$((failures + 1))
  fi

  run_local_capture "${vm}" "admin_ssh_connect" bash -lc "ssh ${SSH_OPTIONS:-"-o BatchMode=yes -o ConnectTimeout=8 -o StrictHostKeyChecking=accept-new"} -p ${SSH_PORT} ${ADMIN_USER}@${ip} true"
  if ! check_local "${vm}: ssh connectivity" bash -lc "ssh ${SSH_OPTIONS:-"-o BatchMode=yes -o ConnectTimeout=8 -o StrictHostKeyChecking=accept-new"} -p ${SSH_PORT} ${ADMIN_USER}@${ip} true"; then
    failures=$((failures + 1))
    echo "[fail] ${vm}: cannot continue remote checks" | tee -a "${SUMMARY}" >&2
    return "${failures}"
  fi

  run_remote_capture "${vm}" "${ip}" "hostnamectl" "hostnamectl"
  run_remote_capture "${vm}" "${ip}" "os_release" "cat /etc/os-release | head -n 5"
  run_remote_capture "${vm}" "${ip}" "ip_br_addr" "ip -br addr"
  run_remote_capture "${vm}" "${ip}" "ip_routes" "ip r | head -n 20"
  run_remote_capture "${vm}" "${ip}" "resolvectl_status" "resolvectl status | sed -n '1,120p'"
  run_remote_capture "${vm}" "${ip}" "timedatectl" "timedatectl"
  run_remote_capture "${vm}" "${ip}" "chronyc_tracking" "chronyc tracking | head -n 20"
  run_remote_capture "${vm}" "${ip}" "ufw_status_verbose" "sudo ufw status verbose"
  run_remote_capture "${vm}" "${ip}" "ufw_show_added" "sudo ufw show added"
  run_remote_capture "${vm}" "${ip}" "sshd_flags" "sudo sshd -T | egrep 'permitrootlogin|passwordauthentication|port'"
  run_remote_capture "${vm}" "${ip}" "ssh_status" "systemctl status ssh --no-pager"
  run_remote_capture "${vm}" "${ip}" "lsblk" "lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT"
  run_remote_capture "${vm}" "${ip}" "df_h" "df -h"
  run_remote_capture "${vm}" "${ip}" "mount_head" "mount | head -n 30"
  run_remote_capture "${vm}" "${ip}" "qga_status" "systemctl status qemu-guest-agent --no-pager"
  run_remote_capture "${vm}" "${ip}" "ports" "ss -tulpen | sort -k5 | head -n 80"

  if ! check_remote "${vm}" "${ip}" "hostname matches expected" "hostnamectl --static | grep -qx '${expected_host}'"; then failures=$((failures + 1)); fi
  if ! check_remote "${vm}" "${ip}" "Ubuntu 24.04" "grep -q 'VERSION_ID=\"24.04\"' /etc/os-release"; then failures=$((failures + 1)); fi
  if ! check_remote "${vm}" "${ip}" "static IP present" "ip -br addr | grep -Eq '${ip}/'"; then failures=$((failures + 1)); fi
  if ! check_remote "${vm}" "${ip}" "default route via gateway" "ip r | grep -q 'default via ${GATEWAY}'"; then failures=$((failures + 1)); fi
  if ! check_remote "${vm}" "${ip}" "dns server configured" "resolvectl status | grep -Eq '${DNS_SERVER}'"; then failures=$((failures + 1)); fi
  if ! check_remote "${vm}" "${ip}" "search domain configured" "resolvectl status | grep -Eq '${SEARCH_DOMAIN}'"; then failures=$((failures + 1)); fi
  if ! check_remote "${vm}" "${ip}" "timezone configured" "timedatectl | grep -q 'Time zone: ${TIMEZONE}'"; then failures=$((failures + 1)); fi
  if ! check_remote "${vm}" "${ip}" "ntp synchronized" "timedatectl | grep -Eq 'System clock synchronized: yes|NTP service: active'"; then failures=$((failures + 1)); fi
  if ! check_remote "${vm}" "${ip}" "ufw active and deny incoming" "sudo ufw status verbose | grep -Eq 'Status: active' && sudo ufw status verbose | grep -Eq 'Default: deny \\(incoming\\)'"; then failures=$((failures + 1)); fi
  if ! check_remote "${vm}" "${ip}" "sshd permitrootlogin no" "sudo sshd -T | grep -q '^permitrootlogin no$'"; then failures=$((failures + 1)); fi
  if [[ "${ALLOW_PASSWORD_SSH:-false}" == "false" ]]; then
    if ! check_remote "${vm}" "${ip}" "sshd passwordauthentication no" "sudo sshd -T | grep -q '^passwordauthentication no$'"; then failures=$((failures + 1)); fi
  fi
  if ! check_remote "${vm}" "${ip}" "ssh service active" "systemctl is-active --quiet ssh"; then failures=$((failures + 1)); fi
  if ! check_remote "${vm}" "${ip}" "guest agent active" "systemctl is-active --quiet qemu-guest-agent"; then failures=$((failures + 1)); fi
  if ! check_remote "${vm}" "${ip}" "ssh port listening" "ss -tulpen | grep -Eq ':22\\b'"; then failures=$((failures + 1)); fi
  if ! check_remote "${vm}" "${ip}" "root filesystem under usage threshold" "df -P / | awk 'NR==2 {gsub(\"%\", \"\", \$5); exit (\$5 < ${MAX_ROOT_USAGE_PERCENT}) ? 0 : 1}'"; then failures=$((failures + 1)); fi
  if ! check_remote "${vm}" "${ip}" "gateway ping from vm" "ping -c 2 ${GATEWAY}"; then failures=$((failures + 1)); fi
  if ! check_remote "${vm}" "${ip}" "dns ping from vm" "ping -c 2 ${DNS_SERVER}"; then failures=$((failures + 1)); fi
  if [[ "${CHECK_EXTERNAL_DNS:-false}" == "true" ]]; then
    if ! check_remote "${vm}" "${ip}" "external dns query (optional)" "dig +short google.com | grep -Eq '.'"; then failures=$((failures + 1)); fi
  fi

  if [[ "${failures}" -eq 0 ]]; then
    echo "[pass] ${vm}: all 81.190 checks passed" | tee -a "${SUMMARY}"
  else
    echo "[fail] ${vm}: ${failures} check(s) failed" | tee -a "${SUMMARY}" >&2
  fi

  return "${failures}"
}

total_failures=0
echo "81.190 gate start: $(date -Iseconds)" | tee -a "${SUMMARY}"

IFS=',' read -r -a required_entries <<< "${REQUIRED_VMS}"
for entry in "${required_entries[@]}"; do
  entry="$(echo "${entry}" | xargs)"
  [[ -z "${entry}" ]] && continue
  vm_name="${entry%%:*}"
  vm_ip="${entry##*:}"
  vm_host="$(echo "${vm_name}" | tr '[:upper:]' '[:lower:]')"
  set +e
  validate_vm "${vm_name}" "${vm_ip}" "${vm_host}"
  vm_failures=$?
  set -e
  if [[ "${vm_failures}" -gt 0 ]]; then
    total_failures=$((total_failures + vm_failures))
  fi
done

if [[ -n "${OPTIONAL_VMS:-}" ]]; then
  IFS=',' read -r -a optional_entries <<< "${OPTIONAL_VMS}"
  for entry in "${optional_entries[@]}"; do
    entry="$(echo "${entry}" | xargs)"
    [[ -z "${entry}" ]] && continue
    vm_name="${entry%%:*}"
    vm_ip="${entry##*:}"
    vm_host="$(echo "${vm_name}" | tr '[:upper:]' '[:lower:]')"
    set +e
    validate_vm "${vm_name}" "${vm_ip}" "${vm_host}"
    vm_failures=$?
    set -e
    if [[ "${vm_failures}" -gt 0 ]]; then
      total_failures=$((total_failures + vm_failures))
    fi
  done
fi

cat <<EOF2 | tee -a "${SUMMARY}"
Manual required checks (Proxmox UI):
- Options -> QEMU Guest Agent enabled for each VM
- Summary shows expected IP for each VM
- NIC attached to vmbr0 and no public bridge usage
EOF2

if [[ "${total_failures}" -gt 0 ]]; then
  echo "81.190 gate: FAIL (${total_failures} total failed checks)" | tee -a "${SUMMARY}" >&2
  exit 1
fi

echo "81.190 gate: PASS" | tee -a "${SUMMARY}"
