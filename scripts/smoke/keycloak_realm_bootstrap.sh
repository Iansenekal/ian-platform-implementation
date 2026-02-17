#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
COMPOSE_FILE="${REPO_ROOT}/infrastructure/keycloak/docker-compose.yml"
PROJECT_NAME="keycloak_smoke"
KEYCLOAK_URL="http://127.0.0.1:8080"
KEYCLOAK_MGMT_URL="http://127.0.0.1:9000"
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
  echo "Install Docker Compose or enable Docker Desktop WSL integration for this distro." >&2
  exit 1
fi

cleanup() {
  "${COMPOSE_CMD[@]}" -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" down -v --remove-orphans >/dev/null 2>&1 || true
}
trap cleanup EXIT

cd "${REPO_ROOT}"

"${COMPOSE_CMD[@]}" -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" down -v --remove-orphans >/dev/null 2>&1 || true
"${COMPOSE_CMD[@]}" -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" up -d

echo "Waiting for Keycloak readiness..."
ready=0
for _ in $(seq 1 120); do
  mgmt_status="$(curl -s -o /dev/null -w "%{http_code}" "${KEYCLOAK_MGMT_URL}/health/ready" || true)"
  app_status="$(curl -s -o /dev/null -w "%{http_code}" "${KEYCLOAK_URL}/realms/master/.well-known/openid-configuration" || true)"
  if [[ "${mgmt_status}" == "200" && "${app_status}" == "200" ]]; then
    ready=1
    break
  fi
  sleep 2
done

if [[ "${ready}" != "1" ]]; then
  echo "Keycloak did not become ready" >&2
  echo "management readiness status: ${mgmt_status}" >&2
  echo "application readiness status: ${app_status}" >&2
  "${COMPOSE_CMD[@]}" -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" logs keycloak >&2 || true
  exit 1
fi

echo "Requesting admin access token..."
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
  echo "Failed to obtain admin token" >&2
  echo "Token response: ${token_response}" >&2
  exit 1
fi

echo "Verifying imported realm..."
realm_body=""
realm_code=""
for _ in $(seq 1 30); do
  realm_response="$(curl -sS -w "\n%{http_code}" "${KEYCLOAK_URL}/admin/realms/platform" \
    -H "Authorization: Bearer ${access_token}")"
  realm_body="$(echo "${realm_response}" | sed '$d')"
  realm_code="$(echo "${realm_response}" | tail -n1)"
  if [[ "${realm_code}" == "200" ]]; then
    break
  fi
  sleep 2
done

if [[ "${realm_code}" != "200" ]]; then
  echo "Realm verification failed with status ${realm_code}" >&2
  echo "Response: ${realm_body}" >&2
  "${COMPOSE_CMD[@]}" -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" logs keycloak >&2 || true
  exit 1
fi

python3 - <<'PY' "${realm_body}"
import json
import sys

realm = json.loads(sys.argv[1])
if realm.get("realm") != "platform":
    raise SystemExit("Imported realm name is not 'platform'")
if not realm.get("enabled"):
    raise SystemExit("Imported realm is not enabled")
print("realm-import: OK")
PY

echo "keycloak-smoke: OK"
