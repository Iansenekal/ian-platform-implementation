#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/11-Backend-Identity-Provider/11.10-Ports-Boundaries.md",
    "infrastructure/keycloak/11.10-idp-ports-boundaries.yml",
    "infrastructure/keycloak/11.10-idp-ports-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"11.10 idp ports/boundaries artifacts missing: {', '.join(missing)}")

doc = Path("docs/11-Backend-Identity-Provider/11.10-Ports-Boundaries.md").read_text(encoding="utf-8")
for token in [
    "IdP is never publicly exposed",
    "AI-FRONTEND01",
    "AI-DATA01",
    "8080",
    "8443",
    "Zone E",
    "UFW",
    "Negative tests",
]:
    if token not in doc:
        raise SystemExit(f"11.10 doc missing token: {token}")

matrix_text = Path("infrastructure/keycloak/11.10-idp-ports-boundaries.yml").read_text(encoding="utf-8")
for token in ["public_https", "idp_internal_http", "ssh_admin", "ldaps_ad_mode", "proxy_only_idp_exposure"]:
    if token not in matrix_text:
        raise SystemExit(f"11.10 boundaries matrix missing token: {token}")

verify_script = Path("infrastructure/keycloak/11.10-idp-ports-verify.sh").read_text(encoding="utf-8")
for token in ["ufw status verbose", "ss -tulpn", "ufw show raw", "IDP_INTERNAL_PORT", "PROXY_IP"]:
    if token not in verify_script:
        raise SystemExit(f"11.10 verify script missing token: {token}")

print("identity-provider-ports-boundaries-artifacts: OK")
