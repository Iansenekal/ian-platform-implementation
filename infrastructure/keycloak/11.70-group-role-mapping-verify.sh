#!/usr/bin/env bash
set -euo pipefail

CLAIMS_FILE="${1:-./11.70-claims-standard.yaml.example}"
TAXONOMY_FILE="${2:-./11.70-group-taxonomy.yaml.example}"
PROJECT_FILE="${3:-./11.70-project-codes.yaml.example}"

for f in "${CLAIMS_FILE}" "${TAXONOMY_FILE}" "${PROJECT_FILE}"; do
  if [[ ! -f "${f}" ]]; then
    echo "ERROR: file not found: ${f}" >&2
    exit 1
  fi
done

echo "[11.70] claims checks"
grep -q 'groups_claim: "groups"' "${CLAIMS_FILE}"
grep -q 'signing_algorithm: "RS256"' "${CLAIMS_FILE}"
grep -q 'offline_jwks_validation: true' "${CLAIMS_FILE}"

echo "[11.70] taxonomy checks"
grep -q 'AI-PLATFORM-ADMINS' "${TAXONOMY_FILE}"
grep -q 'AI-SECURITY-AUDITORS' "${TAXONOMY_FILE}"
grep -q 'prefix: "AI-NC-PROJ-"' "${TAXONOMY_FILE}"
grep -q 'OWNER' "${TAXONOMY_FILE}"

echo "[11.70] project code checks"
grep -q 'BANANA-PEEL' "${PROJECT_FILE}"
grep -q 'NIGHT-PENGUIN' "${PROJECT_FILE}"
grep -q 'MASTER' "${PROJECT_FILE}"

echo "[11.70] verification complete"
