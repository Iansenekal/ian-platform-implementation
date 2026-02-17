#!/usr/bin/env bash
# /opt/gateway/scripts/healthcheck.sh
# Liveness check for the Gateway (minimal). No secrets.

set -euo pipefail

HOST="${GATEWAY_HEALTH_HOST:-127.0.0.1}"
PORT="${GATEWAY_HEALTH_PORT:-8443}"
PATH_="${GATEWAY_HEALTH_PATH:-/health}"
SCHEME="${GATEWAY_HEALTH_SCHEME:-http}"

curl -fsS --max-time 3 "${SCHEME}://${HOST}:${PORT}${PATH_}" >/dev/null
