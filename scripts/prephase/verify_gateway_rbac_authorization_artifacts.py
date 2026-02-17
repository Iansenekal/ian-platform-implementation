#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/10-Backend-Gateway/10.50-RBAC-Authorization.md",
    "infrastructure/gateway/10.50-rbac.yaml.example",
    "infrastructure/gateway/10.50-projects.yaml.example",
    "infrastructure/gateway/10.50-policy-matrix.yaml.example",
    "infrastructure/gateway/10.50-rbac-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"10.50 gateway RBAC artifacts missing: {', '.join(missing)}")

doc = Path("docs/10-Backend-Gateway/10.50-RBAC-Authorization.md").read_text(encoding="utf-8")
for token in [
    "Deny-by-default",
    "groups",
    "project",
    "403",
    "source ACL",
    "both-side",
    "Zone E",
]:
    if token not in doc:
        raise SystemExit(f"10.50 doc missing token: {token}")

rbac = Path("infrastructure/gateway/10.50-rbac.yaml.example").read_text(encoding="utf-8")
for token in ['groups_claim: "groups"', "AI-PLATFORM-ADMINS", "AI-SECURITY-AUDITORS", "global_bypass_for_platform_admin: false"]:
    if token not in rbac:
        raise SystemExit(f"10.50 rbac template missing token: {token}")

projects = Path("infrastructure/gateway/10.50-projects.yaml.example").read_text(encoding="utf-8")
for token in ['project_group_prefix: "AI-NC-PROJ-"', "BANANA-PEEL", "MASTER"]:
    if token not in projects:
        raise SystemExit(f"10.50 projects template missing token: {token}")

policy = Path("infrastructure/gateway/10.50-policy-matrix.yaml.example").read_text(encoding="utf-8")
for token in ["deny_by_default: true", "enforce_source_acl: true", "both_side_visibility: true", "leak_metadata: false", "admin_allowlist_required: true"]:
    if token not in policy:
        raise SystemExit(f"10.50 policy template missing token: {token}")

verify = Path("infrastructure/gateway/10.50-rbac-verify.sh").read_text(encoding="utf-8")
for token in ["RBAC_FILE", "PROJECTS_FILE", "POLICY_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"10.50 verify script missing token: {token}")

print("gateway-rbac-authorization-artifacts: OK")
