#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/11-Backend-Identity-Provider/11.70-Group-to-Role-Mapping.md",
    "infrastructure/keycloak/11.70-claims-standard.yaml.example",
    "infrastructure/keycloak/11.70-group-taxonomy.yaml.example",
    "infrastructure/keycloak/11.70-project-codes.yaml.example",
    "infrastructure/keycloak/11.70-group-role-mapping-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"11.70 group-role mapping artifacts missing: {', '.join(missing)}")

doc = Path("docs/11-Backend-Identity-Provider/11.70-Group-to-Role-Mapping.md").read_text(encoding="utf-8")
for token in [
    "groups",
    "RS256",
    "AI-PLATFORM-ADMINS",
    "AI-NC-PROJ-<PROJECT_CODE>-<ROLE>",
    "deny-by-default",
    "Verification checklist",
]:
    if token not in doc:
        raise SystemExit(f"11.70 doc missing token: {token}")

claims = Path("infrastructure/keycloak/11.70-claims-standard.yaml.example").read_text(encoding="utf-8")
for token in ['groups_claim: "groups"', 'signing_algorithm: "RS256"', "offline_jwks_validation: true"]:
    if token not in claims:
        raise SystemExit(f"11.70 claims template missing token: {token}")

taxonomy = Path("infrastructure/keycloak/11.70-group-taxonomy.yaml.example").read_text(encoding="utf-8")
for token in ["AI-PLATFORM-ADMINS", "AI-SECURITY-AUDITORS", 'prefix: "AI-NC-PROJ-"', "OWNER"]:
    if token not in taxonomy:
        raise SystemExit(f"11.70 taxonomy template missing token: {token}")

projects = Path("infrastructure/keycloak/11.70-project-codes.yaml.example").read_text(encoding="utf-8")
for token in ["BANANA-PEEL", "NIGHT-PENGUIN", "MASTER"]:
    if token not in projects:
        raise SystemExit(f"11.70 project codes template missing token: {token}")

verify = Path("infrastructure/keycloak/11.70-group-role-mapping-verify.sh").read_text(encoding="utf-8")
for token in ["CLAIMS_FILE", "TAXONOMY_FILE", "PROJECT_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"11.70 verify script missing token: {token}")

print("identity-provider-group-role-mapping-artifacts: OK")
