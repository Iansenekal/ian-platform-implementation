#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 --env-file <path>

Validates that required 82.10 BIOS/UEFI precheck decisions are documented.
USAGE
}

ENV_FILE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file)
      ENV_FILE="${2:-}"
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

if [[ -z "${ENV_FILE}" || ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}" >&2
  echo "Copy infrastructure/ollama-gpu/82.10-bios-precheck-inputs.env.example first." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

required=(
  MOTHERBOARD_MODEL
  BIOS_VERSION
  CPU_MODEL
  GPU_MODEL
  RAM_SIZE_GB
  PSU_WATTAGE
  VT_X_ENABLED
  VT_D_OR_IOMMU_ENABLED
  ABOVE_4G_DECODING_ENABLED
  REBAR_ENABLED
  PCIE_GEN_POLICY
  SECURE_BOOT_POLICY
  SECURE_BOOT_ENABLED
)
for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required variable in ${ENV_FILE}: ${var}" >&2
    exit 1
  fi
done

if [[ "${SECURE_BOOT_POLICY}" != "A" && "${SECURE_BOOT_POLICY}" != "B" ]]; then
  echo "SECURE_BOOT_POLICY must be A or B (got ${SECURE_BOOT_POLICY})" >&2
  exit 1
fi

if [[ "${PCIE_GEN_POLICY}" != "auto" && "${PCIE_GEN_POLICY}" != "gen4" && "${PCIE_GEN_POLICY}" != "gen5" ]]; then
  echo "PCIE_GEN_POLICY must be one of auto/gen4/gen5" >&2
  exit 1
fi

if [[ "${VT_X_ENABLED}" != "true" || "${VT_D_OR_IOMMU_ENABLED}" != "true" ]]; then
  echo "Virtualization/IOMMU settings must be enabled for baseline policy." >&2
  exit 1
fi

if [[ "${ABOVE_4G_DECODING_ENABLED}" != "true" ]]; then
  echo "Above 4G Decoding must be enabled." >&2
  exit 1
fi

echo "82.10 bios-precheck gate: PASS"
