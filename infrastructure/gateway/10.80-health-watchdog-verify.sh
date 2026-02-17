#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/10-Backend-Gateway/10.80-Healthchecks-Watchdog.md}"
HEALTHCHECK_FILE="${HEALTHCHECK_FILE:-infrastructure/gateway/10.80-healthcheck.sh}"
DEPS_FILE="${DEPS_FILE:-infrastructure/gateway/10.80-deps-check.sh}"
SUMMARY_FILE="${SUMMARY_FILE:-infrastructure/gateway/10.80-watchdog-log-summary.sh}"
COMPOSE_TEMPLATE="${COMPOSE_TEMPLATE:-infrastructure/gateway/10.80-compose-healthcheck.template.yml}"
SYSTEMD_TEMPLATE="${SYSTEMD_TEMPLATE:-infrastructure/gateway/10.80-systemd-watchdog.service.template}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$HEALTHCHECK_FILE" ]] || { echo "missing script: $HEALTHCHECK_FILE" >&2; exit 1; }
[[ -f "$DEPS_FILE" ]] || { echo "missing script: $DEPS_FILE" >&2; exit 1; }
[[ -f "$SUMMARY_FILE" ]] || { echo "missing script: $SUMMARY_FILE" >&2; exit 1; }
[[ -f "$COMPOSE_TEMPLATE" ]] || { echo "missing template: $COMPOSE_TEMPLATE" >&2; exit 1; }
[[ -f "$SYSTEMD_TEMPLATE" ]] || { echo "missing template: $SYSTEMD_TEMPLATE" >&2; exit 1; }

grep -q "/health" "$HEALTHCHECK_FILE"
grep -q "opensearch not reachable" "$DEPS_FILE"
grep -q "idp discovery not reachable" "$DEPS_FILE"
grep -q "systemctl status ai-gateway.service" "$SUMMARY_FILE"
grep -q "healthcheck:" "$COMPOSE_TEMPLATE"
grep -q "Restart=always" "$SYSTEMD_TEMPLATE"

echo "10.80-health-watchdog: verification complete"
