#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/11-Backend-Identity-Provider/11.60-MFA-TOTP-WebAuthn-RecoveryCodes.md",
    "infrastructure/keycloak/11.60-mfa-policy.yaml.example",
    "infrastructure/keycloak/11.60-mfa-enrollment-checklist.template.md",
    "infrastructure/keycloak/11.60-mfa-verify.sh",
    "infrastructure/keycloak/11.60-evidence-checklist.md",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"11.60 MFA artifacts missing: {', '.join(missing)}")

doc = Path("docs/11-Backend-Identity-Provider/11.60-MFA-TOTP-WebAuthn-RecoveryCodes.md").read_text(encoding="utf-8")
for token in [
    "TOTP",
    "WebAuthn",
    "Recovery codes",
    "Zone E",
    "approval",
    "Verification checklist",
]:
    if token not in doc:
        raise SystemExit(f"11.60 doc missing token: {token}")

policy = Path("infrastructure/keycloak/11.60-mfa-policy.yaml.example").read_text(encoding="utf-8")
for token in [
    "totp:",
    "webauthn:",
    "recovery_codes:",
    "block_token_issuance_until_enrolled",
    "requires_identity_proofing",
]:
    if token not in policy:
        raise SystemExit(f"11.60 policy template missing token: {token}")

checklist = Path("infrastructure/keycloak/11.60-mfa-enrollment-checklist.template.md").read_text(encoding="utf-8")
for token in ["Enroll TOTP", "Enroll WebAuthn", "Reset MFA methods", "Identity proofing"]:
    if token not in checklist:
        raise SystemExit(f"11.60 checklist template missing token: {token}")

verify = Path("infrastructure/keycloak/11.60-mfa-verify.sh").read_text(encoding="utf-8")
for token in ["POLICY_FILE", "CHECKLIST_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"11.60 verify script missing token: {token}")

print("identity-provider-mfa-artifacts: OK")
