#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/20-Frontend-Ingress-UI/20.30-UI-SSO-Flow.md",
    "infrastructure/gateway/20.30-ui-sso-inputs.env.example",
    "infrastructure/gateway/20.30-ui-sso-flow-checklist.template.md",
    "infrastructure/gateway/20.30-ui-sso-verify.sh",
    "infrastructure/gateway/20.30-evidence-checklist.md",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"20.30 UI SSO artifacts missing: {', '.join(missing)}")

doc = Path("docs/20-Frontend-Ingress-UI/20.30-UI-SSO-Flow.md").read_text(encoding="utf-8")
for token in [
    "OIDC",
    "PKCE",
    "localStorage",
    "HttpOnly",
    "groups",
    "Gateway",
    "Verification checklist",
]:
    if token not in doc:
        raise SystemExit(f"20.30 doc missing token: {token}")

inputs = Path("infrastructure/gateway/20.30-ui-sso-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "OIDC_ISSUER_URL",
    "OIDC_DISCOVERY_PATH",
    'GROUPS_CLAIM_NAME="groups"',
    'OIDC_FLOW="authorization_code_pkce"',
    'COOKIE_HTTPONLY="true"',
]:
    if token not in inputs:
        raise SystemExit(f"20.30 inputs template missing token: {token}")

checklist = Path("infrastructure/gateway/20.30-ui-sso-flow-checklist.template.md").read_text(encoding="utf-8")
for token in ["Authorization Code + PKCE", "localStorage", "Gateway returns 403", "Tier 0/1 users challenged for MFA"]:
    if token not in checklist:
        raise SystemExit(f"20.30 checklist template missing token: {token}")

verify = Path("infrastructure/gateway/20.30-ui-sso-verify.sh").read_text(encoding="utf-8")
for token in ["INPUT_FILE", "CHECKLIST_FILE", "curl -k", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"20.30 verify script missing token: {token}")

print("ui-sso-flow-artifacts: OK")
