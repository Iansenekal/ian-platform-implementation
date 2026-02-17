#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/11-Backend-Identity-Provider/11.50-Local-Users-No-Directory.md",
    "infrastructure/keycloak/11.50-local-users-inputs.env.example",
    "infrastructure/keycloak/11.50-local-users.yaml.example",
    "infrastructure/keycloak/11.50-local-users-verify.sh",
    "infrastructure/keycloak/11.50-local-users-access-review.template.md",
    "infrastructure/keycloak/11.50-evidence-checklist.md",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"11.50 local-users artifacts missing: {', '.join(missing)}")

doc = Path("docs/11-Backend-Identity-Provider/11.50-Local-Users-No-Directory.md").read_text(encoding="utf-8")
for token in [
    "No Directory",
    "monthly access review",
    "MFA",
    "local-user lifecycle",
    "10.10.5.187",
]:
    if token not in doc:
        raise SystemExit(f"11.50 doc missing token: {token}")

cfg = Path("infrastructure/keycloak/11.50-local-users.yaml.example").read_text(encoding="utf-8")
for token in ["identity_mode: \"local_users\"", "min_length: 14", "lockout_policy:", "required_action: \"CONFIGURE_TOTP\""]:
    if token not in cfg:
        raise SystemExit(f"11.50 local-users template missing token: {token}")

verify = Path("infrastructure/keycloak/11.50-local-users-verify.sh").read_text(encoding="utf-8")
for token in ["FRONTEND_HOST", "IDP_HOST", "/opt/idp/config/local-users.yaml", "break-glass-password"]:
    if token not in verify:
        raise SystemExit(f"11.50 verify script missing token: {token}")

review = Path("infrastructure/keycloak/11.50-local-users-access-review.template.md").read_text(encoding="utf-8")
for token in ["MFA Enrolled", "Privileged Accounts", "Dormant/Orphaned Accounts", "sign-off"]:
    if token not in review:
        raise SystemExit(f"11.50 access review template missing token: {token}")

print("identity-provider-local-users-artifacts: OK")
