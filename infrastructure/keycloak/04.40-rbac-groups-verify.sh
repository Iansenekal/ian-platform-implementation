#!/usr/bin/env bash
set -euo pipefail

MATRIX_FILE="${1:-./04.40-rbac-groups-matrix.yml}"
if [[ ! -f "${MATRIX_FILE}" ]]; then
  echo "ERROR: matrix file not found: ${MATRIX_FILE}" >&2
  exit 1
fi

echo "[04.40] RBAC group matrix token checks"
grep -q 'AI-PLATFORM-ADMINS' "${MATRIX_FILE}"
grep -q 'AI-SECURITY-AUDITORS' "${MATRIX_FILE}"
grep -q 'AI-NC-PROJ-<CODE>-VIEW' "${MATRIX_FILE}"
grep -q 'AI-SEARCH-PROJ-<CODE>-QUERY' "${MATRIX_FILE}"
grep -q 'deny_by_default: true' "${MATRIX_FILE}"
grep -q 'search_acl_inheritance_required: true' "${MATRIX_FILE}"

echo "[04.40] verification complete"
