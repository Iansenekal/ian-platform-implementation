#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/04-Identity-Access-MFA/04.60-SSO-Integration-Matrix-AllApps.md",
    "infrastructure/gateway/04.60-sso-integration-matrix.yml",
    "infrastructure/gateway/04.60-sso-integration-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"04.60 SSO matrix artifacts missing: {', '.join(missing)}")

doc = Path("docs/04-Identity-Access-MFA/04.60-SSO-Integration-Matrix-AllApps.md").read_text(encoding="utf-8")
for token in [
    "OIDC",
    "SAML",
    "AI-FRONTEND01",
    "groups",
    "Zone E",
    "Integration Matrix",
    "redirect",
]:
    if token not in doc:
        raise SystemExit(f"04.60 doc missing token: {token}")

matrix = Path("infrastructure/gateway/04.60-sso-integration-matrix.yml").read_text(encoding="utf-8")
for token in [
    "idp_single_authority: true",
    "default: oidc",
    "fallback: saml",
    'ui: "ui.<domain>"',
    "groups_claim: groups",
    "admin_step_up_required: true",
]:
    if token not in matrix:
        raise SystemExit(f"04.60 matrix missing token: {token}")

verify_script = Path("infrastructure/gateway/04.60-sso-integration-verify.sh").read_text(encoding="utf-8")
for token in ["MATRIX_FILE", "grep -q", "verification complete"]:
    if token not in verify_script:
        raise SystemExit(f"04.60 verify script missing token: {token}")

print("sso-integration-matrix-artifacts: OK")
