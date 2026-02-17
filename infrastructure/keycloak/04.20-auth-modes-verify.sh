#!/usr/bin/env bash
set -euo pipefail

MODE="${MODE:-ad}" # ad|local
IDP_HOST="${IDP_HOST:-10.10.5.178}"
FRONTEND_HOST="${FRONTEND_HOST:-10.10.5.179}"
DC_HOST="${DC_HOST:-10.10.5.160}"

log() { printf '[04.20] %s\n' "$*"; }

log "Verifying shared boundary checks"
if command -v nc >/dev/null 2>&1; then
  nc -vz "${FRONTEND_HOST}" 443 || true
fi

if [[ "${MODE}" == "ad" ]]; then
  log "Mode A (AD) checks"
  if command -v nc >/dev/null 2>&1; then
    nc -vz "${DC_HOST}" 636 || true
  fi
  if command -v openssl >/dev/null 2>&1; then
    echo | openssl s_client -connect "${DC_HOST}:636" -showcerts 2>/dev/null | openssl x509 -noout -issuer -subject -dates || true
  fi
else
  log "Mode B (Local users) checks"
  log "Confirm local user lifecycle + monthly access review evidence is present"
fi

log "Time sync check"
timedatectl status | sed -n '1,40p' || true

log "Identity mode verification complete (${MODE})"
