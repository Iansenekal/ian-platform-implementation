#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"
PATTERN='(-----BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY-----|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|xox[baprs]-[A-Za-z0-9-]{10,}|(api[_-]?key|access[_-]?token|secret)[[:space:]]*[:=][[:space:]]*["'"'"'A-Za-z0-9_\-]{20,})'

if [[ "$MODE" == "--ci" ]]; then
  files=$(git ls-files)
else
  files=$(git diff --cached --name-only)
fi

if [[ -z "${files}" ]]; then
  echo "secrets-scan: no files to scan"
  exit 0
fi

if echo "${files}" | xargs -r rg -n -E "$PATTERN" -- >/tmp/secrets_scan_hits.txt 2>/dev/null; then
  echo "Potential secrets detected:" >&2
  cat /tmp/secrets_scan_hits.txt >&2
  exit 1
fi

echo "secrets-scan: OK"
