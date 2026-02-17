#!/usr/bin/env bash
set -euo pipefail

INPUT_FILE="${1:-./03.30-audit-inputs.env.example}"
if [[ ! -f "${INPUT_FILE}" ]]; then
  echo "ERROR: inputs file not found: ${INPUT_FILE}" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${INPUT_FILE}"

echo "=== Time Sync ==="
timedatectl status | sed -n '1,40p'
chronyc tracking 2>/dev/null | sed -n '1,40p' || true

echo
echo "=== System Audit Logs ==="
sudo journalctl -u ufw --no-pager | tail -n 50 || true
sudo journalctl -u ssh --no-pager | tail -n 50 || true
sudo journalctl --no-pager -n 50

echo
echo "=== Container Runtime Check ==="
docker ps --format 'table {{.Names}}\t{{.Status}}' || true

echo
echo "=== Correlation-ID Spot Check ==="
if command -v rg >/dev/null 2>&1; then
  rg -n "correlation_id|request_id" /opt 2>/dev/null | head -n 20 || true
else
  grep -RIn "correlation_id\|request_id" /opt 2>/dev/null | head -n 20 || true
fi

echo
echo "=== Expected Audit Indexes ==="
printf '%s\n' "${AUDIT_INDICES}" | tr ',' '\n'

echo
echo "03.30 audit verification complete"
