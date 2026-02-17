#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/21-Nextcloud/21.37-Project-Folder-ACL-Blueprint.md",
    "infrastructure/nextcloud/21.37-project-folder-template.txt",
    "infrastructure/nextcloud/21.37-acl-blueprint.csv",
    "infrastructure/nextcloud/21.37-onboarding-checklist.template.md",
    "infrastructure/nextcloud/21.37-project-acl-inputs.env.example",
    "infrastructure/nextcloud/21.37-project-acl-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"21.37 nextcloud project-acl blueprint artifacts missing: {', '.join(missing)}")

doc = Path("docs/21-Nextcloud/21.37-Project-Folder-ACL-Blueprint.md").read_text(encoding="utf-8")
for token in [
    "deny-by-default",
    "/Projects",
    "AI-NC-PROJ-<PROJECTCODE>-OWNER",
    "inheritance",
    "07-Finance",
    "Search/KG",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"21.37 doc missing token: {token}")

tree = Path("infrastructure/nextcloud/21.37-project-folder-template.txt").read_text(encoding="utf-8")
for token in ["/Projects/<PROJECTCODE>/", "00-Project-Home/", "05.30-Audit-Evidence/", "06-Archive/"]:
    if token not in tree:
        raise SystemExit(f"21.37 project folder template missing token: {token}")

acl = Path("infrastructure/nextcloud/21.37-acl-blueprint.csv").read_text(encoding="utf-8")
for token in ["path,group,access", "AI-NC-PROJ-<PROJECTCODE>-OWNER", "AI-NC-PROJ-<PROJECTCODE>-VIEW", "break_inheritance_optional"]:
    if token not in acl:
        raise SystemExit(f"21.37 acl blueprint missing token: {token}")

checklist = Path("infrastructure/nextcloud/21.37-onboarding-checklist.template.md").read_text(encoding="utf-8")
for token in ["PROJECTCODE", "Root groups applied", "Inheritance remains enabled", "External sharing default remains disabled"]:
    if token not in checklist:
        raise SystemExit(f"21.37 onboarding checklist missing token: {token}")

inputs = Path("infrastructure/nextcloud/21.37-project-acl-inputs.env.example").read_text(encoding="utf-8")
for token in ["PROJECTS_ROOT=/Projects", "DEFAULT_INHERITANCE=on", "EXTERNAL_SHARING_DEFAULT=disabled", "SEARCH_INDEXER_SERVICE_ACCOUNT=AI-SVC-SEARCH-NC-INDEXER"]:
    if token not in inputs:
        raise SystemExit(f"21.37 inputs template missing token: {token}")

verify = Path("infrastructure/nextcloud/21.37-project-acl-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "TREE_FILE", "ACL_FILE", "CHECKLIST_FILE", "INPUTS_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"21.37 verify script missing token: {token}")

print("nextcloud-project-acl-blueprint-artifacts: OK")
