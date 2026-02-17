#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/41-Automation-Windmill/41.20-SSO-MFA-Policy.md",
    "infrastructure/automation/windmill/41.20-windmill-identity-modes.yml",
    "infrastructure/automation/windmill/41.20-windmill-mfa-role-policy.csv",
    "infrastructure/automation/windmill/41.20-windmill-rbac-group-mapping.yml",
    "infrastructure/automation/windmill/41.20-windmill-session-policy.yml",
    "infrastructure/automation/windmill/41.20-windmill-sso-mfa-inputs.env.example",
    "infrastructure/automation/windmill/41.20-windmill-sso-mfa-verification-checklist.template.md",
    "infrastructure/automation/windmill/41.20-windmill-sso-mfa-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"41.20 windmill SSO/MFA artifacts missing: {', '.join(missing)}")

doc = Path("docs/41-Automation-Windmill/41.20-SSO-MFA-Policy.md").read_text(encoding="utf-8")
for token in [
    "Policy Goals",
    "Identity Modes",
    "MFA Requirements",
    "RBAC Mapping",
    "Session and Login Security",
    "Break-Glass",
    "Audit Requirements",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"41.20 doc missing token: {token}")

identity = Path("infrastructure/automation/windmill/41.20-windmill-identity-modes.yml").read_text(encoding="utf-8")
for token in [
    "preferred_mode: idp_sso",
    "idp_local_users",
    "break_glass_local_windmill_only",
    "local_windmill_users_default_enabled: false",
]:
    if token not in identity:
        raise SystemExit(f"41.20 identity modes missing token: {token}")

mfa = Path("infrastructure/automation/windmill/41.20-windmill-mfa-role-policy.csv").read_text(encoding="utf-8")
for token in [
    "windmill_admin,yes",
    "windmill_operator,recommended",
    "windmill_script_builder,recommended",
    "WebAuthn|TOTP",
]:
    if token not in mfa:
        raise SystemExit(f"41.20 MFA policy missing token: {token}")

rbac = Path("infrastructure/automation/windmill/41.20-windmill-rbac-group-mapping.yml").read_text(encoding="utf-8")
for token in [
    "AI-WM-ADMINS",
    "AI-WM-OPERATORS",
    "AI-WM-BUILDERS",
    "separation_of_duties_required: true",
]:
    if token not in rbac:
        raise SystemExit(f"41.20 RBAC mapping missing token: {token}")

session = Path("infrastructure/automation/windmill/41.20-windmill-session-policy.yml").read_text(encoding="utf-8")
for token in [
    "idle_timeout_required: true",
    "reauth_for_sensitive_actions: true",
    "idp_lockout_policy_required: true",
    "lan_allowlist_required: true",
]:
    if token not in session:
        raise SystemExit(f"41.20 session policy missing token: {token}")

inputs = Path("infrastructure/automation/windmill/41.20-windmill-sso-mfa-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "WINDMILL_IDENTITY_MODE=",
    "WINDMILL_MFA_ADMINS_REQUIRED=",
    "WINDMILL_GROUP_ADMIN=",
    "WINDMILL_IDLE_TIMEOUT_MINUTES=",
]:
    if token not in inputs:
        raise SystemExit(f"41.20 inputs missing token: {token}")

checklist = Path("infrastructure/automation/windmill/41.20-windmill-sso-mfa-verification-checklist.template.md").read_text(encoding="utf-8")
for token in [
    "IdP SSO login works",
    "MFA is enforced",
    "RBAC deny tests",
    "break-glass process",
]:
    if token not in checklist:
        raise SystemExit(f"41.20 checklist missing token: {token}")

verify = Path("infrastructure/automation/windmill/41.20-windmill-sso-mfa-verify.sh").read_text(encoding="utf-8")
for token in [
    "DOC_FILE",
    "IDENTITY_FILE",
    "MFA_FILE",
    "RBAC_FILE",
    "SESSION_FILE",
    "INPUTS_FILE",
    "CHECKLIST_FILE",
    "grep -q",
    "verification complete",
]:
    if token not in verify:
        raise SystemExit(f"41.20 verify script missing token: {token}")

print("automation-windmill-sso-mfa-artifacts: OK")
