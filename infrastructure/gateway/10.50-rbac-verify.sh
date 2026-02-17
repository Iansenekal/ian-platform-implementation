#!/usr/bin/env bash
set -euo pipefail

RBAC_FILE="${1:-./10.50-rbac.yaml.example}"
PROJECTS_FILE="${2:-./10.50-projects.yaml.example}"
POLICY_FILE="${3:-./10.50-policy-matrix.yaml.example}"

for f in "${RBAC_FILE}" "${PROJECTS_FILE}" "${POLICY_FILE}"; do
  if [[ ! -f "${f}" ]]; then
    echo "ERROR: file not found: ${f}" >&2
    exit 1
  fi
done

echo "[10.50] RBAC checks"
grep -q 'groups_claim: "groups"' "${RBAC_FILE}"
grep -q 'AI-PLATFORM-ADMINS' "${RBAC_FILE}"
grep -q 'AI-SECURITY-AUDITORS' "${RBAC_FILE}"
grep -q 'global_bypass_for_platform_admin: false' "${RBAC_FILE}"

echo "[10.50] projects checks"
grep -q 'project_group_prefix: "AI-NC-PROJ-"' "${PROJECTS_FILE}"
grep -q 'BANANA-PEEL' "${PROJECTS_FILE}"
grep -q 'MASTER' "${PROJECTS_FILE}"

echo "[10.50] policy matrix checks"
grep -q 'deny_by_default: true' "${POLICY_FILE}"
grep -q 'enforce_source_acl: true' "${POLICY_FILE}"
grep -q 'both_side_visibility: true' "${POLICY_FILE}"
grep -q 'leak_metadata: false' "${POLICY_FILE}"
grep -q 'admin_allowlist_required: true' "${POLICY_FILE}"

echo "[10.50] verification complete"
