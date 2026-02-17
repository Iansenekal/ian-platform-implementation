#!/usr/bin/env bash
set -euo pipefail

INPUT_FILE="${1:-./20.20-tls-inputs.env.example}"
if [[ ! -f "${INPUT_FILE}" ]]; then
  echo "ERROR: inputs file not found: ${INPUT_FILE}" >&2
  exit 1
fi
# shellcheck disable=SC1090
source "${INPUT_FILE}"

echo "[20.20] local file checks"
for p in "${CA_BUNDLE_PATH}" "${UI_CERT_PATH}" "${UI_KEY_PATH}"; do
  if [[ -e "$p" ]]; then
    stat -c '%a %U:%G %n' "$p"
  else
    echo "MISSING: $p"
  fi
done

echo "[20.20] certificate metadata"
if [[ -f "${UI_CERT_PATH}" ]] && command -v openssl >/dev/null 2>&1; then
  openssl x509 -in "${UI_CERT_PATH}" -noout -subject -issuer -dates
fi

echo "[20.20] endpoint checks"
if command -v openssl >/dev/null 2>&1; then
  openssl s_client -connect "${UI_FQDN}:443" -servername "${UI_FQDN}" </dev/null 2>/dev/null | grep -E "subject=|issuer=|Verify return code" || true
fi
if command -v curl >/dev/null 2>&1; then
  curl "https://${UI_FQDN}/" -I --max-time 10 | sed -n '1,20p' || true
fi

echo "[20.20] verification complete"
