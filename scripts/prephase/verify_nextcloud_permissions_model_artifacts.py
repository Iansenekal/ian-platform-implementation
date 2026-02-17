#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/21-Nextcloud/21.35-Permissions-Model-and-Roles.md",
    "infrastructure/nextcloud/21.35-role-catalog.yml",
    "infrastructure/nextcloud/21.35-permission-matrix.csv",
    "infrastructure/nextcloud/21.35-permissions-inputs.env.example",
    "infrastructure/nextcloud/21.35-permissions-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"21.35 nextcloud permissions artifacts missing: {', '.join(missing)}")

doc = Path("docs/21-Nextcloud/21.35-Permissions-Model-and-Roles.md").read_text(encoding="utf-8")
for token in [
    "deny-by-default",
    "Project-Owner",
    "Project-Editor",
    "Project-Viewer",
    "service accounts",
    "external sharing",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"21.35 doc missing token: {token}")

catalog = Path("infrastructure/nextcloud/21.35-role-catalog.yml").read_text(encoding="utf-8")
for token in ["default_stance: deny_by_default", "NC_PLATFORM_ADMIN", "PROJECT_OWNER", "PROJECT_VIEWER", "SEARCH_INDEXER_SERVICE"]:
    if token not in catalog:
        raise SystemExit(f"21.35 role catalog missing token: {token}")

matrix = Path("infrastructure/nextcloud/21.35-permission-matrix.csv").read_text(encoding="utf-8")
for token in ["action,platform_admin", "manage_nextcloud_settings_apps", "grant_revoke_project_access", "create_external_share_links", "index_search_content"]:
    if token not in matrix:
        raise SystemExit(f"21.35 permission matrix missing token: {token}")

inputs = Path("infrastructure/nextcloud/21.35-permissions-inputs.env.example").read_text(encoding="utf-8")
for token in ["PLATFORM_ADMIN_GROUP=", "PROJECT_GROUP_PATTERN=", "DEFAULT_EXTERNAL_SHARING=disabled", "ACCESS_REVIEW_CADENCE="]:
    if token not in inputs:
        raise SystemExit(f"21.35 inputs template missing token: {token}")

verify = Path("infrastructure/nextcloud/21.35-permissions-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "ROLE_CATALOG_FILE", "MATRIX_FILE", "INPUTS_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"21.35 verify script missing token: {token}")

print("nextcloud-permissions-model-artifacts: OK")
