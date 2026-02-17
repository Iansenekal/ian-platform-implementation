#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/21-Nextcloud/21.36-Group-Naming-Convention.md",
    "infrastructure/nextcloud/21.36-group-taxonomy.yml",
    "infrastructure/nextcloud/21.36-project-code-register.template.csv",
    "infrastructure/nextcloud/21.36-group-naming-inputs.env.example",
    "infrastructure/nextcloud/21.36-group-naming-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"21.36 nextcloud group naming artifacts missing: {', '.join(missing)}")

doc = Path("docs/21-Nextcloud/21.36-Group-Naming-Convention.md").read_text(encoding="utf-8")
for token in [
    "AI-NC-PROJ-<PROJECTCODE>-OWNER",
    "AI-NC-PROJ-<PROJECTCODE>-EDIT",
    "AI-NC-PROJ-<PROJECTCODE>-VIEW",
    "A-Z0-9",
    "AI-SVC-",
    "Search/KG",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"21.36 doc missing token: {token}")

taxonomy = Path("infrastructure/nextcloud/21.36-group-taxonomy.yml").read_text(encoding="utf-8")
for token in ["prefixes:", "platform_groups:", "project_group_pattern:", "optional_roles:", "project_code_rules:", "service_accounts:"]:
    if token not in taxonomy:
        raise SystemExit(f"21.36 taxonomy missing token: {token}")

register = Path("infrastructure/nextcloud/21.36-project-code-register.template.csv").read_text(encoding="utf-8")
for token in ["project_display_name,project_code,owner,status", "BANANAPEEL", "NIGHTPENG", "MCHUCK"]:
    if token not in register:
        raise SystemExit(f"21.36 project register missing token: {token}")

inputs = Path("infrastructure/nextcloud/21.36-group-naming-inputs.env.example").read_text(encoding="utf-8")
for token in ["GLOBAL_PREFIX=", "PROJECT_GROUP_PATTERN=", "PROJECT_CODE_ALLOWED_CHARSET=", "IDP_GROUP_CLAIM_NAME=groups", "SEARCH_KG_ACL_MATCH="]:
    if token not in inputs:
        raise SystemExit(f"21.36 inputs template missing token: {token}")

verify = Path("infrastructure/nextcloud/21.36-group-naming-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "TAXONOMY_FILE", "REGISTER_FILE", "INPUTS_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"21.36 verify script missing token: {token}")

print("nextcloud-group-naming-artifacts: OK")
