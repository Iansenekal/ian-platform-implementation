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
: "${SERVICE_GROUP:?SERVICE_GROUP is required}"

STACK_ROOT="/opt/${STACK_NAME}"
SECRETS_DIR="${STACK_ROOT}/secrets"
ENV_DIR="${STACK_ROOT}/env"
COMPOSE_DIR="${STACK_ROOT}/compose"

mkdir -p "${SECRETS_DIR}" "${ENV_DIR}" "${COMPOSE_DIR}" "${STACK_ROOT}/config" "${STACK_ROOT}/scripts" "${STACK_ROOT}/systemd"

chown -R root:root "${STACK_ROOT}"
chmod 0750 "${STACK_ROOT}" "${SECRETS_DIR}" "${ENV_DIR}" "${COMPOSE_DIR}"

if ! getent group "${SERVICE_GROUP}" >/dev/null 2>&1; then
  echo "WARNING: service group '${SERVICE_GROUP}' not found; create it before assigning readers." >&2
else
  chgrp "${SERVICE_GROUP}" "${SECRETS_DIR}"
fi

# Seed no-secret templates
if [[ -f "./03.20-secrets-README.template.txt" ]]; then
  sed \
    -e "s/{{STACK_NAME}}/${STACK_NAME}/g" \
    -e "s/{{SERVICE_GROUP}}/${SERVICE_GROUP}/g" \
    -e "s/{{ROTATION_DAYS}}/${ROTATION_DAYS:-90}/g" \
    ./03.20-secrets-README.template.txt > "${SECRETS_DIR}/README.txt"
  chown root:root "${SECRETS_DIR}/README.txt"
  chmod 0640 "${SECRETS_DIR}/README.txt"
fi

if [[ -f "./03.20-env.template.example" ]]; then
  cp ./03.20-env.template.example "${ENV_DIR}/.env.template"
  chown root:root "${ENV_DIR}/.env.template"
  chmod 0640 "${ENV_DIR}/.env.template"
fi

echo "Initialized secrets standard layout for stack: ${STACK_NAME}"
