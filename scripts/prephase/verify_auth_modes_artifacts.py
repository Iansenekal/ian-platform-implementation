#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/04-Identity-Access-MFA/04.20-Auth-Modes-AD-vs-LocalUsers.md",
    "infrastructure/keycloak/04.20-auth-modes-decision.yml",
    "infrastructure/keycloak/04.20-auth-modes-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"04.20 auth modes artifacts missing: {', '.join(missing)}")

doc = Path("docs/04-Identity-Access-MFA/04.20-Auth-Modes-AD-vs-LocalUsers.md").read_text(encoding="utf-8")
for token in [
    "Mode A",
    "Mode B",
    "LDAPS",
    "Zone E",
    "Monthly access review",
    "Migration Notes",
    "AI-NC-PROJ-<CODE>-VIEW",
]:
    if token not in doc:
        raise SystemExit(f"04.20 doc missing token: {token}")

matrix_text = Path("infrastructure/keycloak/04.20-auth-modes-decision.yml").read_text(encoding="utf-8")
for token in [
    "mode_a_ad_integrated",
    "mode_b_local_users",
    "ldaps_636",
    "min_password_length_14",
    "shared_baseline",
    "migration",
]:
    if token not in matrix_text:
        raise SystemExit(f"04.20 decision matrix missing token: {token}")

verify_script = Path("infrastructure/keycloak/04.20-auth-modes-verify.sh").read_text(encoding="utf-8")
for token in ["MODE", "nc -vz", "openssl s_client", "timedatectl status", "ad|local"]:
    if token not in verify_script:
        raise SystemExit(f"04.20 verify script missing token: {token}")

print("auth-modes-artifacts: OK")
