#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/21-Nextcloud/21.00-Overview-RoleInPlatform.md",
    "infrastructure/nextcloud/README.md",
    "infrastructure/nextcloud/21.00-overview-inputs.env.example",
    "infrastructure/nextcloud/21.00-overview-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"21.00 nextcloud overview artifacts missing: {', '.join(missing)}")

doc = Path("docs/21-Nextcloud/21.00-Overview-RoleInPlatform.md").read_text(encoding="utf-8")
for token in [
    "Nextcloud",
    "AI-DATA01",
    "AI-FRONTEND01",
    "RBAC",
    "POPIA",
    "Search",
    "Knowledge Graph",
    "SSO",
]:
    if token not in doc:
        raise SystemExit(f"21.00 doc missing token: {token}")

inputs = Path("infrastructure/nextcloud/21.00-overview-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "NEXTCLOUD_HOSTNAME=",
    "NEXTCLOUD_RUNTIME_HOST=",
    "FRONTEND_INGRESS_HOST=",
    "AUTH_MODE=",
    "PROJECT_GROUP_PATTERN=",
]:
    if token not in inputs:
        raise SystemExit(f"21.00 inputs template missing token: {token}")

verify = Path("infrastructure/nextcloud/21.00-overview-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "INPUTS_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"21.00 verify script missing token: {token}")

print("nextcloud-overview-artifacts: OK")
