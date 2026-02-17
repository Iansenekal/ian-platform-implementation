from __future__ import annotations

from dataclasses import dataclass
from functools import lru_cache
import os
from typing import Any

from flask import Flask, Response, jsonify, request
import jwt
import requests


@dataclass(frozen=True)
class GatewayConfig:
    upstream_url: str
    issuer: str
    audience: str | None


def load_config() -> GatewayConfig:
    return GatewayConfig(
        upstream_url=os.getenv("UPSTREAM_URL", "http://reference-app:5000"),
        issuer=os.getenv("KEYCLOAK_ISSUER", "http://keycloak:8080/realms/master"),
        audience=os.getenv("KEYCLOAK_AUDIENCE") or None,
    )


@lru_cache(maxsize=1)
def discover_openid(issuer: str) -> dict[str, Any]:
    response = requests.get(f"{issuer}/.well-known/openid-configuration", timeout=5)
    response.raise_for_status()
    return response.json()


@lru_cache(maxsize=1)
def jwks_client(issuer: str) -> jwt.PyJWKClient:
    metadata = discover_openid(issuer)
    return jwt.PyJWKClient(metadata["jwks_uri"])


def validate_bearer_token(token: str, cfg: GatewayConfig) -> dict[str, Any]:
    signing_key = jwks_client(cfg.issuer).get_signing_key_from_jwt(token)
    options = {"verify_aud": cfg.audience is not None}
    claims = jwt.decode(
        token,
        signing_key.key,
        algorithms=["RS256"],
        issuer=cfg.issuer,
        audience=cfg.audience,
        options=options,
    )
    return claims


app = Flask(__name__)
config = load_config()


@app.route("/health")
def health() -> tuple[dict[str, str], int]:
    return {"status": "ok"}, 200


@app.route("/api/protected/health", methods=["GET"])
def protected_health() -> Response:
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return jsonify({"error": "missing_bearer_token"}), 401

    token = auth_header.removeprefix("Bearer ").strip()
    if not token:
        return jsonify({"error": "missing_bearer_token"}), 401

    try:
        claims = validate_bearer_token(token, config)
    except Exception as exc:  # noqa: BLE001
        return jsonify({"error": "invalid_token", "detail": str(exc)}), 401

    upstream = requests.get(f"{config.upstream_url}/health", timeout=5)
    return jsonify(
        {
            "gateway_auth": "success",
            "claims_subject": claims.get("sub", "unknown"),
            "upstream_status": upstream.status_code,
            "upstream_body": upstream.json(),
        }
    ), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8081)
