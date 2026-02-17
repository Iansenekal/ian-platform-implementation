#!/usr/bin/env bash
set -euo pipefail

OIDC_FILE="${1:-./10.40-oidc-validation.yaml.example}"
ENV_FILE="${2:-./10.40-gateway-env.template}"

if [[ ! -f "${OIDC_FILE}" ]]; then
  echo "ERROR: OIDC file not found: ${OIDC_FILE}" >&2
  exit 1
fi
if [[ ! -f "${ENV_FILE}" ]]; then
  echo "ERROR: env template not found: ${ENV_FILE}" >&2
  exit 1
fi

echo "[10.40] OIDC policy checks"
grep -q 'issuer_url: "https://id.<domain>"' "${OIDC_FILE}"
grep -q 'discovery_url:' "${OIDC_FILE}"
grep -q 'allowed_algs:' "${OIDC_FILE}"
grep -q '"RS256"' "${OIDC_FILE}"
grep -q 'required_claims:' "${OIDC_FILE}"
grep -q 'groups_claim: "groups"' "${OIDC_FILE}"
grep -q 'redact_bearer_token: true' "${OIDC_FILE}"

echo "[10.40] env template checks"
grep -q 'TRUSTED_PROXY_IP=' "${ENV_FILE}"
grep -q 'OIDC_CONFIG_PATH=' "${ENV_FILE}"
grep -q 'LOG_REDACT_TOKENS=true' "${ENV_FILE}"
grep -q 'CORRELATION_ID_HEADER=' "${ENV_FILE}"

echo "[10.40] verification complete"
