#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/vars.env"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "ERROR: run as root (sudo)." >&2
  exit 1
fi

if ! command -v ufw >/dev/null 2>&1; then
  apt-get update
  apt-get install -y ufw
fi

ufw --force reset
ufw default deny incoming
ufw default allow outgoing

# Backend ingress: allow only frontend host to backend HTTPS.
ufw allow in from "${FRONTEND_IP}/32" to any port 443 proto tcp comment "Frontend to backend HTTPS"

if [[ "${ENABLE_SSH}" == "yes" ]]; then
  for CIDR in ${ADMIN_ALLOWLIST}; do
    ufw limit in from "${CIDR}" to any port 22 proto tcp comment "Admin SSH (rate limited)"
  done
fi

if [[ "${ENABLE_MONITORING_COLLECTOR}" == "yes" ]]; then
  ufw allow in from "${MONITORING_COLLECTOR_IP}/32" to any port 9100 proto tcp comment "Collector to node_exporter"
  ufw allow in from "${MONITORING_COLLECTOR_IP}/32" to any port 9187 proto tcp comment "Collector to postgres_exporter"
  ufw allow in from "${MONITORING_COLLECTOR_IP}/32" to any port 9114 proto tcp comment "Collector to opensearch_exporter"
fi

ufw logging medium
ufw --force enable
systemctl enable ufw

ufw status verbose
