#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/04-Identity-Access-MFA/04.40-RoleModel-RBAC-Groups.md",
    "infrastructure/keycloak/04.40-rbac-groups-matrix.yml",
    "infrastructure/keycloak/04.40-rbac-groups-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"04.40 RBAC artifacts missing: {', '.join(missing)}")

doc = Path("docs/04-Identity-Access-MFA/04.40-RoleModel-RBAC-Groups.md").read_text(encoding="utf-8")
for token in [
    "Deny-by-default",
    "AI-PLATFORM-ADMINS",
    "AI-NC-PROJ-<CODE>-VIEW",
    "AI-SEARCH-PROJ-<CODE>-QUERY",
    "Zone E",
    "Nextcloud",
]:
    if token not in doc:
        raise SystemExit(f"04.40 doc missing token: {token}")

matrix_text = Path("infrastructure/keycloak/04.40-rbac-groups-matrix.yml").read_text(encoding="utf-8")
for token in [
    "global_groups:",
    "project_group_templates:",
    "deny_by_default: true",
    "group_based_authorization_only: true",
    "search_acl_inheritance_required: true",
]:
    if token not in matrix_text:
        raise SystemExit(f"04.40 matrix missing token: {token}")

verify_script = Path("infrastructure/keycloak/04.40-rbac-groups-verify.sh").read_text(encoding="utf-8")
for token in ["MATRIX_FILE", "grep -q", "verification complete"]:
    if token not in verify_script:
        raise SystemExit(f"04.40 verify script missing token: {token}")

print("rbac-role-model-artifacts: OK")
