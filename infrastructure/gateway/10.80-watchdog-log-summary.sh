#!/usr/bin/env bash
# /opt/gateway/scripts/watchdog-log-summary.sh
# Safe log summary helper for operators (no secrets).

set -euo pipefail

echo "=== ai-gateway watchdog summary ==="
date
echo "UFW:"
sudo ufw status | sed -n '1,120p' || true
echo "Listening ports:"
sudo ss -tulpn | sed -n '1,120p' || true
echo "Systemd status (if present):"
sudo systemctl status ai-gateway.service --no-pager 2>/dev/null | sed -n '1,120p' || true
