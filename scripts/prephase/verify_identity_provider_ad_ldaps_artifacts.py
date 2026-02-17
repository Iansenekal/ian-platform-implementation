#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/11-Backend-Identity-Provider/11.40-AD-Integration-LDAPS.md",
    "infrastructure/keycloak/11.40-ad-ldaps-inputs.env.example",
    "infrastructure/keycloak/11.40-ad-ldaps.yaml.example",
    "infrastructure/keycloak/11.40-group-mapping.yaml.example",
    "infrastructure/keycloak/11.40-ad-ldaps-verify.sh",
    "infrastructure/keycloak/11.40-evidence-checklist.md",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"11.40 AD-LDAPS artifacts missing: {', '.join(missing)}")

doc = Path("docs/11-Backend-Identity-Provider/11.40-AD-Integration-LDAPS.md").read_text(encoding="utf-8")
for token in [
    "LDAPS only",
    "bind account",
    "/opt/idp/secrets",
    "group-mapping.yaml",
    "groups",
    "openssl s_client",
    "ldapsearch",
]:
    if token not in doc:
        raise SystemExit(f"11.40 doc missing token: {token}")

cfg = Path("infrastructure/keycloak/11.40-ad-ldaps.yaml.example").read_text(encoding="utf-8")
for token in ["protocol: \"ldaps\"", "verify_cert: true", "dn_file", "password_file", "nested_groups"]:
    if token not in cfg:
        raise SystemExit(f"11.40 ad-ldaps template missing token: {token}")

map_cfg = Path("infrastructure/keycloak/11.40-group-mapping.yaml.example").read_text(encoding="utf-8")
for token in ["token_groups_claim", "platform_groups", "project_groups", "emit_group"]:
    if token not in map_cfg:
        raise SystemExit(f"11.40 group mapping template missing token: {token}")

verify = Path("infrastructure/keycloak/11.40-ad-ldaps-verify.sh").read_text(encoding="utf-8")
for token in ["nc -vz", "openssl s_client", "getent hosts", "BIND_DN_FILE", "BIND_PASSWORD_FILE"]:
    if token not in verify:
        raise SystemExit(f"11.40 verify script missing token: {token}")

print("identity-provider-ad-ldaps-artifacts: OK")
