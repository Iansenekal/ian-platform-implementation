#!/usr/bin/env bash
set -euo pipefail

INPUT_FILE="${1:-./20.30-ui-sso-inputs.env.example}"
CHECKLIST_FILE="${2:-./20.30-ui-sso-flow-checklist.template.md}"

if [[ ! -f "${INPUT_FILE}" ]]; then
  echo "ERROR: inputs file not found: ${INPUT_FILE}" >&2
  exit 1
fi
if [[ ! -f "${CHECKLIST_FILE}" ]]; then
  echo "ERROR: checklist file not found: ${CHECKLIST_FILE}" >&2
  exit 1
fi
# shellcheck disable=SC1090
source "${INPUT_FILE}"

echo "[20.30] discovery endpoint check"
if command -v curl >/dev/null 2>&1; then
  curl -k "https://${IDP_FQDN}${OIDC_DISCOVERY_PATH}" --max-time 10 | sed -n '1,20p' || true
fi

echo "[20.30] required token checks in inputs"
grep -q 'OIDC_FLOW="authorization_code_pkce"' "${INPUT_FILE}"
grep -q 'GROUPS_CLAIM_NAME="groups"' "${INPUT_FILE}"
grep -q 'COOKIE_SECURE="true"' "${INPUT_FILE}"
grep -q 'COOKIE_HTTPONLY="true"' "${INPUT_FILE}"

echo "[20.30] checklist token checks"
grep -q 'Authorization Code + PKCE' "${CHECKLIST_FILE}"
grep -q 'No access/refresh tokens in localStorage/sessionStorage' "${CHECKLIST_FILE}"
grep -q 'Gateway returns 403' "${CHECKLIST_FILE}"
grep -q 'Tier 0/1 users challenged for MFA' "${CHECKLIST_FILE}"

echo "[20.30] verification complete"
