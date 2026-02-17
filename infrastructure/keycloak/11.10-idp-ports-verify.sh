#!/usr/bin/env bash
set -euo pipefail

IDP_INTERNAL_PORT="${IDP_INTERNAL_PORT:-8080}"
PROXY_IP="${PROXY_IP:-10.10.5.179}"

log() { printf '[11.10] %s\n' "$*"; }

log "UFW status"
sudo ufw status verbose

log "Listening sockets"
sudo ss -tulpn

log "Raw UFW rules"
sudo ufw show raw | sed -n '1,220p'

log "Expected guardrails"
log "- inbound ${IDP_INTERNAL_PORT}/tcp should only allow ${PROXY_IP}"
log "- inbound 22/tcp should only allow Zone E"
log "- direct LAN access to ${IDP_INTERNAL_PORT} should fail"

echo "11.10 verification completed"
