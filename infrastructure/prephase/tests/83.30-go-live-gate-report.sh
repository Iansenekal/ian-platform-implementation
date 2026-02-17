#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 --env-file <path>

Generates 83.30 go-live gate summary report from filled inputs.
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
  echo "Copy infrastructure/prephase/tests/83.30-go-live-gate-inputs.env.example first." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

required=(
  CLIENT_SITE CHANGE_TICKET LAN_CIDR DNS_DOMAIN AI_DATA01 AI_FRONTEND01 LLM_NODE
  SECTION_1 SECTION_2 SECTION_3 SECTION_4 SECTION_5 SECTION_6 SECTION_7 SECTION_8
  BOOTSTRAP_RELEASE_REF MAINTENANCE_WINDOW_APPROVED
)
for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required variable in ${ENV_FILE}: ${var}" >&2
    exit 1
  fi
done

is_pass() {
  [[ "$1" == "PASS" ]]
}

decision="GO"
for s in "$SECTION_1" "$SECTION_2" "$SECTION_3" "$SECTION_4" "$SECTION_5" "$SECTION_6" "$SECTION_7" "$SECTION_8"; do
  if ! is_pass "$s"; then
    decision="NO-GO"
    break
  fi
done

if [[ "${MAINTENANCE_WINDOW_APPROVED}" != "true" ]]; then
  decision="NO-GO"
fi

REPORT_DIR="infrastructure/prephase/tests/logs"
mkdir -p "${REPORT_DIR}"
REPORT_FILE="${REPORT_DIR}/83.30-go-live-gate-$(date +%F_%H%M%S).md"

cat > "${REPORT_FILE}" <<MD
# 83.30 Pre-Bootstrap Go-Live Gate Report

- Client/Site: ${CLIENT_SITE}
- Change/Ticket: ${CHANGE_TICKET}
- LAN CIDR: ${LAN_CIDR}
- DNS Domain: ${DNS_DOMAIN}
- AI-DATA01: ${AI_DATA01}
- AI-FRONTEND01: ${AI_FRONTEND01}
- LLM Node: ${LLM_NODE}
- Bootstrap Release Ref: ${BOOTSTRAP_RELEASE_REF}

## Section Status
- 1 Environment identification: ${SECTION_1}
- 2 Proxmox readiness: ${SECTION_2}
- 3 VM base readiness: ${SECTION_3}
- 4 DNS readiness: ${SECTION_4}
- 5 LLM readiness: ${SECTION_5}
- 6 Integration tests readiness: ${SECTION_6}
- 7 Backup/evidence readiness: ${SECTION_7}
- 8 Change control/rollback readiness: ${SECTION_8}
- Maintenance window approved: ${MAINTENANCE_WINDOW_APPROVED}

## Evidence References
- 81.*: ${EVIDENCE_81_PATH:-<not set>}
- 82.*: ${EVIDENCE_82_PATH:-<not set>}
- 83.00: ${EVIDENCE_83_00_PATH:-<not set>}
- 83.10: ${EVIDENCE_83_10_PATH:-<not set>}
- 83.20: ${EVIDENCE_83_20_PATH:-<not set>}
- 06.*: ${EVIDENCE_06_PATH:-<not set>}

## Final Decision
- ${decision}
MD

echo "83.30 go-live gate report: ${REPORT_FILE}"
echo "decision: ${decision}"

if [[ "${decision}" == "NO-GO" ]]; then
  exit 2
fi
