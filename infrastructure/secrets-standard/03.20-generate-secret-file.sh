#!/usr/bin/env bash
set -euo pipefail

INPUT_FILE="${1:-./03.20-stack-inputs.env}"
SECRET_FILE_NAME="${2:-}"
SECRET_KIND="${3:-base64-32}"

if [[ -z "${SECRET_FILE_NAME}" ]]; then
  echo "Usage: $0 <inputs.env> <secret-file-name> [base64-32|hex-64|rsa-4096]" >&2
  exit 1
fi

if [[ ! -f "${INPUT_FILE}" ]]; then
  echo "ERROR: inputs file not found: ${INPUT_FILE}" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${INPUT_FILE}"

: "${STACK_NAME:?STACK_NAME is required}"
: "${SERVICE_GROUP:?SERVICE_GROUP is required}"

TARGET_DIR="/opt/${STACK_NAME}/secrets"
TARGET_FILE="${TARGET_DIR}/${SECRET_FILE_NAME}"

mkdir -p "${TARGET_DIR}"

case "${SECRET_KIND}" in
  base64-32)
    umask 027
    openssl rand -base64 32 > "${TARGET_FILE}"
    chmod 0440 "${TARGET_FILE}"
    ;;
  hex-64)
    umask 027
    openssl rand -hex 64 > "${TARGET_FILE}"
    chmod 0440 "${TARGET_FILE}"
    ;;
  rsa-4096)
    umask 077
    openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out "${TARGET_FILE}"
    chmod 0400 "${TARGET_FILE}"
    ;;
  *)
    echo "ERROR: unsupported secret kind: ${SECRET_KIND}" >&2
    exit 1
    ;;
esac

chown root:"${SERVICE_GROUP}" "${TARGET_FILE}" || chown root:root "${TARGET_FILE}"

echo "Generated ${TARGET_FILE} with strict permissions (${SECRET_KIND})"
