#!/usr/bin/env bash
# /opt/gateway/scripts/deps-check.sh
# Readiness dependency checks (minimal, safe). No secrets.

set -euo pipefail

fail() { echo "deps-check: $1" >&2; exit 1; }

# OpenSearch (critical)
curl -fsS --max-time 2 "http://127.0.0.1:9200" >/dev/null || fail "opensearch not reachable"

# Postgres (optional by default) target: 127.0.0.1:5432
if ! ( timeout 2 bash -c 'cat < /dev/null > /dev/tcp/127.0.0.1/5432' ) 2>/dev/null; then
  echo "deps-check: postgres not reachable (non-fatal by default)" >&2
fi

# Tika (optional by default) target: 127.0.0.1:9998
if ! curl -fsS --max-time 2 "http://127.0.0.1:9998" >/dev/null; then
  echo "deps-check: tika not reachable (non-fatal by default)" >&2
fi

# IdP discovery/JWKS (critical)
IDP_DISCOVERY_URL="${IDP_DISCOVERY_URL:-https://id.<domain>/.well-known/openid-configuration}"
curl -fsS --max-time 3 "${IDP_DISCOVERY_URL}" >/dev/null || fail "idp discovery not reachable"

exit 0
