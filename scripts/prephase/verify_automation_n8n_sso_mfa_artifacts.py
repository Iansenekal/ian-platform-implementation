#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/40-Automation-n8n/40.20-SSO-MFA-Policy.md",
    "infrastructure/automation/n8n/40.20-n8n-identity-modes.yml",
    "infrastructure/automation/n8n/40.20-n8n-mfa-role-policy.csv",
    "infrastructure/automation/n8n/40.20-n8n-rbac-group-mapping.yml",
    "infrastructure/automation/n8n/40.20-n8n-session-policy.yml",
    "infrastructure/automation/n8n/40.20-n8n-sso-mfa-inputs.env.example",
    "infrastructure/automation/n8n/40.20-n8n-sso-mfa-verification-checklist.template.md",
    "infrastructure/automation/n8n/40.20-n8n-sso-mfa-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"40.20 n8n SSO/MFA artifacts missing: {', '.join(missing)}")

doc = Path("docs/40-Automation-n8n/40.20-SSO-MFA-Policy.md").read_text(encoding="utf-8")
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
        raise SystemExit(f"40.20 doc missing token: {token}")

identity = Path("infrastructure/automation/n8n/40.20-n8n-identity-modes.yml").read_text(encoding="utf-8")
for token in [
    "preferred_mode: oidc_sso",
    "idp_local_users",
    "break_glass_local_n8n_only",
    "local_n8n_users_default_enabled: false",
]:
    if token not in identity:
        raise SystemExit(f"40.20 identity modes missing token: {token}")

mfa = Path("infrastructure/automation/n8n/40.20-n8n-mfa-role-policy.csv").read_text(encoding="utf-8")
for token in [
    "n8n_admin,yes",
    "n8n_operator,recommended",
    "n8n_builder,recommended",
    "WebAuthn|TOTP",
]:
    if token not in mfa:
        raise SystemExit(f"40.20 MFA policy missing token: {token}")

rbac = Path("infrastructure/automation/n8n/40.20-n8n-rbac-group-mapping.yml").read_text(encoding="utf-8")
for token in [
    "AI-N8N-ADMINS",
    "AI-N8N-OPERATORS",
    "AI-N8N-BUILDERS",
    "separation_of_duties_required: true",
]:
    if token not in rbac:
        raise SystemExit(f"40.20 RBAC mapping missing token: {token}")

session = Path("infrastructure/automation/n8n/40.20-n8n-session-policy.yml").read_text(encoding="utf-8")
for token in [
    "idle_timeout_required: true",
    "reauth_for_sensitive_actions: true",
    "idp_lockout_policy_required: true",
    "lan_allowlist_required: true",
]:
    if token not in session:
        raise SystemExit(f"40.20 session policy missing token: {token}")

inputs = Path("infrastructure/automation/n8n/40.20-n8n-sso-mfa-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "N8N_IDENTITY_MODE=",
    "N8N_MFA_ADMINS_REQUIRED=",
    "N8N_GROUP_ADMIN=",
    "N8N_IDLE_TIMEOUT_MINUTES=",
]:
    if token not in inputs:
        raise SystemExit(f"40.20 inputs missing token: {token}")

checklist = Path("infrastructure/automation/n8n/40.20-n8n-sso-mfa-verification-checklist.template.md").read_text(encoding="utf-8")
for token in [
    "OIDC SSO login works",
    "MFA is enforced",
    "RBAC deny tests",
    "Break-glass process",
]:
    if token not in checklist:
        raise SystemExit(f"40.20 checklist missing token: {token}")

verify = Path("infrastructure/automation/n8n/40.20-n8n-sso-mfa-verify.sh").read_text(encoding="utf-8")
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
        raise SystemExit(f"40.20 verify script missing token: {token}")

print("automation-n8n-sso-mfa-artifacts: OK")
