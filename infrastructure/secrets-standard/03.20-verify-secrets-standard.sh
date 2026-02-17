#!/usr/bin/env bash
set -euo pipefail

INPUT_FILE="${1:-./03.20-stack-inputs.env}"
if [[ ! -f "${INPUT_FILE}" ]]; then
  echo "ERROR: inputs file not found: ${INPUT_FILE}" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${INPUT_FILE}"

: "${STACK_NAME:?STACK_NAME is required}"
STACK_PATH="${STACK_PATH:-/opt/${STACK_NAME}}"
SECRETS_PATH="${STACK_PATH}/secrets"

if [[ ! -d "${SECRETS_PATH}" ]]; then
  echo "ERROR: secrets path not found: ${SECRETS_PATH}" >&2
  exit 1
fi

echo "=== Secret file permissions ==="
find "${SECRETS_PATH}" -maxdepth 1 -type f -exec stat -c '%a %U:%G %n' {} \;

echo
echo "=== Hardcoded secret pattern scan (outside secrets dir) ==="
grep -RIn --exclude-dir=secrets -E 'password=|passwd|secret=|token=|BEGIN PRIVATE KEY' "${STACK_PATH}" || true

echo
echo "=== Layout checks ==="
for d in "${STACK_PATH}" "${STACK_PATH}/secrets" "${STACK_PATH}/env" "${STACK_PATH}/compose"; do
  if [[ ! -d "${d}" ]]; then
    echo "MISSING: ${d}" >&2
    exit 1
  fi
  stat -c '%a %U:%G %n' "${d}"
done

echo "03.20 secrets standard verification complete for ${STACK_NAME}"
