#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
COMPOSE_FILE="${REPO_ROOT}/infrastructure/gateway/docker-compose.yml"
PROJECT_NAME="gateway_jwt_smoke"
KEYCLOAK_URL="http://127.0.0.1:8080"
KEYCLOAK_MGMT_URL="http://127.0.0.1:9000"
GATEWAY_URL="http://127.0.0.1:8081"
ADMIN_USER="${KEYCLOAK_ADMIN_USER:-${KC_BOOTSTRAP_ADMIN_USERNAME:-admin}}"
ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD:-${KC_BOOTSTRAP_ADMIN_PASSWORD:-change-me-in-env}}"
COMPOSE_CMD=()

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required" >&2
  exit 1
fi

if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD=("docker" "compose")
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD=("docker-compose")
else
  echo "No usable Docker Compose command found in this shell." >&2
  exit 1
fi

cleanup() {
  "${COMPOSE_CMD[@]}" -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" down -v --remove-orphans >/dev/null 2>&1 || true
}
trap cleanup EXIT

cd "${REPO_ROOT}"

"${COMPOSE_CMD[@]}" -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" down -v --remove-orphans >/dev/null 2>&1 || true
"${COMPOSE_CMD[@]}" -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" up -d --build

echo "Waiting for Keycloak and gateway readiness..."
ready=0
for _ in $(seq 1 150); do
  mgmt_status="$(curl -s -o /dev/null -w "%{http_code}" "${KEYCLOAK_MGMT_URL}/health/ready" || true)"
  oidc_status="$(curl -s -o /dev/null -w "%{http_code}" "${KEYCLOAK_URL}/realms/master/.well-known/openid-configuration" || true)"
  gateway_status="$(curl -s -o /dev/null -w "%{http_code}" "${GATEWAY_URL}/health" || true)"
  if [[ "${mgmt_status}" == "200" && "${oidc_status}" == "200" && "${gateway_status}" == "200" ]]; then
    ready=1
    break
  fi
  sleep 2
done

if [[ "${ready}" != "1" ]]; then
  echo "Stack did not become ready" >&2
  "${COMPOSE_CMD[@]}" -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" logs >&2 || true
  exit 1
fi

echo "Requesting admin token from Keycloak master realm..."
token_response="$(curl -sS -X POST "${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=admin-cli" \
  -d "grant_type=password" \
  -d "username=${ADMIN_USER}" \
  -d "password=${ADMIN_PASSWORD}")"

access_token="$(python3 - <<'PY' "${token_response}"
import json
import sys
payload = json.loads(sys.argv[1])
print(payload.get("access_token", ""))
PY
)"

if [[ -z "${access_token}" ]]; then
  echo "Failed to obtain access token" >&2
  echo "Token response: ${token_response}" >&2
  exit 1
fi

echo "Checking invalid token is rejected..."
invalid_code="$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer invalid.token.value" \
  "${GATEWAY_URL}/api/protected/health" || true)"
if [[ "${invalid_code}" != "401" ]]; then
  echo "Expected 401 for invalid token, got ${invalid_code}" >&2
  exit 1
fi

echo "Checking tampered-payload token is rejected..."
IFS='.' read -r token_header token_payload token_signature <<< "${access_token}"
if [[ -z "${token_header}" || -z "${token_payload}" || -z "${token_signature}" ]]; then
  echo "Unable to split JWT into header.payload.signature segments" >&2
  exit 1
fi

first_payload_char="${token_payload:0:1}"
replacement_char="A"
if [[ "${first_payload_char}" == "A" ]]; then
  replacement_char="B"
fi

tampered_payload="${replacement_char}${token_payload:1}"
tampered_token="${token_header}.${tampered_payload}.${token_signature}"

tampered_code="$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer ${tampered_token}" \
  "${GATEWAY_URL}/api/protected/health" || true)"
if [[ "${tampered_code}" != "401" ]]; then
  echo "Expected 401 for tampered-payload token, got ${tampered_code}" >&2
  exit 1
fi

echo "Checking valid Keycloak token is accepted..."
valid_response="$(curl -sS -w "\n%{http_code}" \
  -H "Authorization: Bearer ${access_token}" \
  "${GATEWAY_URL}/api/protected/health")"

valid_body="$(echo "${valid_response}" | sed '$d')"
valid_code="$(echo "${valid_response}" | tail -n1)"

if [[ "${valid_code}" != "200" ]]; then
  echo "Expected 200 for valid token, got ${valid_code}" >&2
  echo "Response: ${valid_body}" >&2
  "${COMPOSE_CMD[@]}" -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" logs gateway >&2 || true
  exit 1
fi

python3 - <<'PY' "${valid_body}"
import json
import sys
body = json.loads(sys.argv[1])
if body.get("gateway_auth") != "success":
    raise SystemExit("gateway_auth is not success")
if body.get("upstream_status") != 200:
    raise SystemExit("upstream_status is not 200")
print("gateway-jwt-validation: OK")
PY

echo "gateway-jwt-smoke: OK"
