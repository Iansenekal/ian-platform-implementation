#!/usr/bin/env bash
set -euo pipefail

MATRIX_FILE="${1:-./04.60-sso-integration-matrix.yml}"
if [[ ! -f "${MATRIX_FILE}" ]]; then
  echo "ERROR: matrix file not found: ${MATRIX_FILE}" >&2
  exit 1
fi

echo "[04.60] matrix token checks"
grep -q 'idp_single_authority: true' "${MATRIX_FILE}"
grep -q 'default: oidc' "${MATRIX_FILE}"
grep -q 'fallback: saml' "${MATRIX_FILE}"
grep -q 'ui: "ui.<domain>"' "${MATRIX_FILE}"
grep -q 'groups_claim: groups' "${MATRIX_FILE}"
grep -q 'admin_step_up_required: true' "${MATRIX_FILE}"

echo "[04.60] verification complete"
