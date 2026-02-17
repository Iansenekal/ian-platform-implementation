#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/21-Nextcloud/21.30-Auth-Options-AD-vs-SSO.md",
    "infrastructure/nextcloud/21.30-auth-decision-matrix.yml",
    "infrastructure/nextcloud/21.30-auth-options-inputs.env.example",
    "infrastructure/nextcloud/21.30-auth-options-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"21.30 nextcloud auth-option artifacts missing: {', '.join(missing)}")

doc = Path("docs/21-Nextcloud/21.30-Auth-Options-AD-vs-SSO.md").read_text(encoding="utf-8")
for token in [
    "SSO",
    "AD/LDAPS",
    "Local users",
    "MFA",
    "break-glass",
    "OIDC",
    "SAML",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"21.30 doc missing token: {token}")

matrix = Path("infrastructure/nextcloud/21.30-auth-decision-matrix.yml").read_text(encoding="utf-8")
for token in ["default_mode:", "SSO:", "AD_LDAPS:", "LOCAL_USERS:", "fallback_break_glass:"]:
    if token not in matrix:
        raise SystemExit(f"21.30 decision matrix missing token: {token}")

inputs = Path("infrastructure/nextcloud/21.30-auth-options-inputs.env.example").read_text(encoding="utf-8")
for token in ["SELECTED_AUTH_MODE=", "SSO_PROTOCOL=", "LDAPS_PORT=636", "PROJECT_GROUP_PATTERN=", "BREAK_GLASS_ACCOUNT="]:
    if token not in inputs:
        raise SystemExit(f"21.30 inputs template missing token: {token}")

verify = Path("infrastructure/nextcloud/21.30-auth-options-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "MATRIX_FILE", "INPUTS_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"21.30 verify script missing token: {token}")

print("nextcloud-auth-options-artifacts: OK")
