#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/11-Backend-Identity-Provider/11.00-Overview.md",
    "infrastructure/keycloak/docker-compose.yml",
    "infrastructure/keycloak/realm/realm-export.json",
    "scripts/smoke/keycloak_realm_bootstrap.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"11.00 identity-provider overview artifacts missing: {', '.join(missing)}")

doc = Path("docs/11-Backend-Identity-Provider/11.00-Overview.md").read_text(encoding="utf-8")
for token in [
    "OIDC-first",
    "LAN-only",
    "RS256",
    "AD",
    "Local Users",
    "AI-DATA01",
    "groups",
    "Install Sequencing",
]:
    if token not in doc:
        raise SystemExit(f"11.00 overview doc missing token: {token}")

realm = Path("infrastructure/keycloak/realm/realm-export.json").read_text(encoding="utf-8")
for token in ["realm", "roles", "groups", "otpPolicyType"]:
    if token not in realm:
        raise SystemExit(f"keycloak realm export missing token: {token}")

print("identity-provider-overview-artifacts: OK")
