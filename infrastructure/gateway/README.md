# Gateway Deployment Scaffold (Sprint B)

This directory contains a JWT-validating gateway baseline for:
- ingress proxy routing
- real token validation against Keycloak JWKS
- protected endpoint health validation

Current state:
- Python gateway with RS256 JWT verification via Keycloak OIDC discovery + JWKS
- Integrated local compose stack (Postgres + Keycloak + reference app + gateway)
- Smoke test support for valid/invalid token verification

Run locally:
- `make smoke-gateway-jwt`
