#!/usr/bin/env bash
set -euo pipefail

POLICY_FILE="${1:-./11.60-mfa-policy.yaml.example}"
CHECKLIST_FILE="${2:-./11.60-mfa-enrollment-checklist.template.md}"

if [[ ! -f "${POLICY_FILE}" ]]; then
  echo "ERROR: policy file not found: ${POLICY_FILE}" >&2
  exit 1
fi
if [[ ! -f "${CHECKLIST_FILE}" ]]; then
  echo "ERROR: checklist file not found: ${CHECKLIST_FILE}" >&2
  exit 1
fi

echo "[11.60] policy token checks"
grep -q 'totp:' "${POLICY_FILE}"
grep -q 'webauthn:' "${POLICY_FILE}"
grep -q 'recovery_codes:' "${POLICY_FILE}"
grep -q 'block_token_issuance_until_enrolled' "${POLICY_FILE}"
grep -q 'requires_identity_proofing' "${POLICY_FILE}"

echo "[11.60] checklist token checks"
grep -q 'Enroll TOTP' "${CHECKLIST_FILE}"
grep -q 'Enroll WebAuthn' "${CHECKLIST_FILE}"
grep -q 'Reset MFA methods' "${CHECKLIST_FILE}"
grep -q 'Identity proofing' "${CHECKLIST_FILE}"

echo "[11.60] verification complete"
