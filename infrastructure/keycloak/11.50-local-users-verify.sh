#!/usr/bin/env bash
set -euo pipefail

INPUT_FILE="${1:-./11.50-local-users-inputs.env.example}"
if [[ ! -f "${INPUT_FILE}" ]]; then
  echo "ERROR: inputs file not found: ${INPUT_FILE}" >&2
  exit 1
fi
# shellcheck disable=SC1090
source "${INPUT_FILE}"

echo "[11.50] Boundary checks"
if command -v nc >/dev/null 2>&1; then
  nc -vz "${FRONTEND_HOST}" 443 || true
  nc -vz "${IDP_HOST}" 8080 || true
fi

echo "[11.50] Required local-user artifacts"
for p in "/opt/idp/config/local-users.yaml" \
         "/opt/idp/secrets/local-admin-bootstrap-password" \
         "/opt/idp/secrets/break-glass-password"; do
  if [[ -e "$p" ]]; then
    stat -c '%a %U:%G %n' "$p"
  else
    echo "MISSING: $p"
  fi
done

echo "[11.50] Access review checklist"
echo "- monthly access review owners: ${ACCESS_REVIEW_OWNER_SECURITY}, ${ACCESS_REVIEW_OWNER_SYSTEM}"
echo "- verify dormant users disabled and admin/auditor MFA enforcement active"

echo "[11.50] verification complete"
