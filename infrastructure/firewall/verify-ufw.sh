#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/vars.env"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "ERROR: run as root (sudo)." >&2
  exit 1
fi

echo "=== UFW Status (verbose) ==="
ufw status verbose

echo
echo "=== Listening TCP ports ==="
ss -lntp

echo
echo "=== Localhost-only checks (AI-DATA01 expected) ==="
ss -lntp | egrep '(:5432|:9200|:9998)' || true

echo
echo "=== Reminder checks ==="
echo "Users should reach only ${FRONTEND_IP}:443"
echo "Users should not reach ${BACKEND_IP}:443/5601/9200/5432"
