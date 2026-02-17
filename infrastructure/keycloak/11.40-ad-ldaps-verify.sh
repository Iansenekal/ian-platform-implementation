#!/usr/bin/env bash
set -euo pipefail

INPUT_FILE="${1:-./11.40-ad-ldaps-inputs.env.example}"
if [[ ! -f "${INPUT_FILE}" ]]; then
  echo "ERROR: inputs file not found: ${INPUT_FILE}" >&2
  exit 1
fi
# shellcheck disable=SC1090
source "${INPUT_FILE}"

echo "[11.40] DNS resolution"
getent hosts "${DC1_HOST}" || true
getent hosts "${DC2_HOST}" || true

echo "[11.40] TCP reachability"
if command -v nc >/dev/null 2>&1; then
  nc -vz "${DC1_IP}" "${LDAPS_PORT}" || true
  nc -vz "${DC2_IP}" "${LDAPS_PORT}" || true
fi

echo "[11.40] LDAPS certificate check"
if command -v openssl >/dev/null 2>&1; then
  openssl s_client -connect "${DC1_IP}:${LDAPS_PORT}" -servername "${DC1_HOST}" -showcerts </dev/null | sed -n '1,120p' || true
fi

echo "[11.40] IdP config path checks"
for p in "${BIND_DN_FILE}" "${BIND_PASSWORD_FILE}" "/opt/idp/config/ad-ldaps.yaml" "/opt/idp/config/group-mapping.yaml"; do
  if [[ -e "$p" ]]; then
    stat -c '%a %U:%G %n' "$p"
  else
    echo "MISSING: $p"
  fi
done

echo "[11.40] verification complete"
