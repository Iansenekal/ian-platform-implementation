#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 --model <ollama_ref> --approval-ref <CHG-...> --operator <name> [--allowlist <path>] [--inventory-dir <path>]

Enforces 82.50 policy by allowing pulls only for models listed in the allowlist.
USAGE
}

ALLOWLIST="/opt/ollama/config/model-allowlist.yaml"
INVENTORY_DIR="/opt/ollama/config/model-inventory"
MODEL=""
APPROVAL_REF=""
OPERATOR=""

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
    --model)
      MODEL="${2:-}"
      shift 2
      ;;
    --approval-ref)
      APPROVAL_REF="${2:-}"
      shift 2
      ;;
    --operator)
      OPERATOR="${2:-}"
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

if [[ -z "${MODEL}" || -z "${APPROVAL_REF}" || -z "${OPERATOR}" ]]; then
  usage
  exit 1
fi

if [[ ! -f "${ALLOWLIST}" ]]; then
  echo "Allowlist not found: ${ALLOWLIST}" >&2
  exit 1
fi

if ! [[ "${APPROVAL_REF}" =~ ^CHG-[0-9]{4}-[0-9]{4}$ ]]; then
  echo "approval-ref must match CHG-YYYY-####" >&2
  exit 1
fi

if ! grep -Eq "ollama_ref:[[:space:]]*\"?${MODEL//\//\/}\"?" "${ALLOWLIST}"; then
  echo "Model is not allowlisted: ${MODEL}" >&2
  exit 1
fi

model_id="$(awk -v model="${MODEL}" '
  $1=="-" && $2=="model_id:" {mid=$3; gsub(/\"/, "", mid)}
  $1=="ollama_ref:" {ref=$2; gsub(/\"/, "", ref); if (ref==model) {print mid; exit}}
' "${ALLOWLIST}")"

if [[ -z "${model_id}" ]]; then
  echo "Could not resolve model_id for allowlisted model: ${MODEL}" >&2
  exit 1
fi

mkdir -p "${INVENTORY_DIR}"

echo "[policy] allowlisted model confirmed: ${MODEL} (${model_id})"
echo "[action] running ollama pull ${MODEL}"
ollama pull "${MODEL}"

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
record_path="${INVENTORY_DIR}/${model_id}.json"

cat > "${record_path}" <<JSON
{
  "model_id": "${model_id}",
  "ollama_ref": "${MODEL}",
  "approval_ref": "${APPROVAL_REF}",
  "installed_by": "${OPERATOR}",
  "installed_at_utc": "${timestamp}",
  "notes": "Installed via 82.50 allowlist wrapper"
}
JSON

echo "[evidence] wrote inventory record: ${record_path}"
echo "82.50 allowlist-enforced pull: COMPLETE"
