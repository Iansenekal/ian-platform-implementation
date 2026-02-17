#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 [--allowlist <path>] [--inventory-dir <path>] [--report-dir <path>]

Audits installed Ollama models against 82.50 allowlist and evidence inventory.
USAGE
}

ALLOWLIST="/opt/ollama/config/model-allowlist.yaml"
INVENTORY_DIR="/opt/ollama/config/model-inventory"
REPORT_DIR="/opt/ollama/config/audit-reports"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --allowlist)
      ALLOWLIST="${2:-}"
      shift 2
      ;;
    --inventory-dir)
      INVENTORY_DIR="${2:-}"
      shift 2
      ;;
    --report-dir)
      REPORT_DIR="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ ! -f "${ALLOWLIST}" ]]; then
  echo "Allowlist not found: ${ALLOWLIST}" >&2
  exit 1
fi

mkdir -p "${REPORT_DIR}"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

allowed_refs="${tmp_dir}/allowed_refs.txt"
installed_refs="${tmp_dir}/installed_refs.txt"

awk '$1=="ollama_ref:" {ref=$2; gsub(/"/, "", ref); print ref}' "${ALLOWLIST}" | sort -u > "${allowed_refs}"

ollama list | awk 'NR>1 {print $1}' | sed '/^$/d' | sort -u > "${installed_refs}"

unexpected="${tmp_dir}/unexpected_models.txt"
missing="${tmp_dir}/missing_models.txt"

comm -13 "${allowed_refs}" "${installed_refs}" > "${unexpected}"
comm -23 "${allowed_refs}" "${installed_refs}" > "${missing}"

missing_inventory_count=0
while IFS= read -r ref; do
  [[ -z "${ref}" ]] && continue
  model_id="$(awk -v model="${ref}" '
    $1=="-" && $2=="model_id:" {mid=$3; gsub(/\"/, "", mid)}
    $1=="ollama_ref:" {r=$2; gsub(/\"/, "", r); if (r==model) {print mid; exit}}
  ' "${ALLOWLIST}")"
  if [[ -z "${model_id}" || ! -f "${INVENTORY_DIR}/${model_id}.json" ]]; then
    missing_inventory_count=$((missing_inventory_count + 1))
  fi
done < "${installed_refs}"

ts="$(date -u +"%Y%m%dT%H%M%SZ")"
report="${REPORT_DIR}/82.50-allowlist-audit-${ts}.md"

{
  echo "# 82.50 Allowlist Audit Report"
  echo
  echo "- Generated UTC: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "- Allowlist: ${ALLOWLIST}"
  echo "- Inventory dir: ${INVENTORY_DIR}"
  echo
  echo "## Installed Models"
  sed 's/^/- /' "${installed_refs}" || true
  echo
  echo "## Unexpected Installed (not allowlisted)"
  if [[ -s "${unexpected}" ]]; then
    sed 's/^/- /' "${unexpected}"
  else
    echo "- none"
  fi
  echo
  echo "## Allowlisted But Not Installed"
  if [[ -s "${missing}" ]]; then
    sed 's/^/- /' "${missing}"
  else
    echo "- none"
  fi
  echo
  echo "## Inventory Coverage"
  echo "- Installed models missing inventory records: ${missing_inventory_count}"
} > "${report}"

if [[ -s "${unexpected}" ]]; then
  echo "Audit failed: unexpected installed models detected" >&2
  echo "Report: ${report}"
  exit 1
fi

if [[ ${missing_inventory_count} -gt 0 ]]; then
  echo "Audit failed: missing inventory records" >&2
  echo "Report: ${report}"
  exit 1
fi

echo "82.50 allowlist audit: PASS"
echo "Report: ${report}"
