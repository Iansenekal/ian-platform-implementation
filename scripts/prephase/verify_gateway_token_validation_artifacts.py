#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/10-Backend-Gateway/10.40-Auth-Token-Validation.md",
    "infrastructure/gateway/10.40-oidc-validation.yaml.example",
    "infrastructure/gateway/10.40-gateway-env.template",
    "infrastructure/gateway/10.40-token-validation-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"10.40 gateway token validation artifacts missing: {', '.join(missing)}")

doc = Path("docs/10-Backend-Gateway/10.40-Auth-Token-Validation.md").read_text(encoding="utf-8")
for token in [
    "JWKS",
    "RS256",
    "401",
    "403",
    "groups",
    "internal CA",
    "deny-by-default",
]:
    if token not in doc:
        raise SystemExit(f"10.40 doc missing token: {token}")

cfg = Path("infrastructure/gateway/10.40-oidc-validation.yaml.example").read_text(encoding="utf-8")
for token in [
    'issuer_url: "https://id.<domain>"',
    'allowed_algs:',
    '"RS256"',
    "required_claims:",
    'groups_claim: "groups"',
    "redact_bearer_token: true",
]:
    if token not in cfg:
        raise SystemExit(f"10.40 oidc template missing token: {token}")

env_tpl = Path("infrastructure/gateway/10.40-gateway-env.template").read_text(encoding="utf-8")
for token in ["TRUSTED_PROXY_IP=", "OIDC_CONFIG_PATH=", "LOG_REDACT_TOKENS=true", "CORRELATION_ID_HEADER="]:
    if token not in env_tpl:
        raise SystemExit(f"10.40 env template missing token: {token}")

verify = Path("infrastructure/gateway/10.40-token-validation-verify.sh").read_text(encoding="utf-8")
for token in ["OIDC_FILE", "ENV_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"10.40 verify script missing token: {token}")

print("gateway-token-validation-artifacts: OK")
