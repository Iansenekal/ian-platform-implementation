#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import json


def read(path: str) -> str:
    p = Path(path)
    if not p.is_file():
        raise SystemExit(f"missing file: {path}")
    return p.read_text(encoding="utf-8")


def ensure_no_tabs(text: str, path: str) -> None:
    if "\t" in text:
        raise SystemExit(f"tab indentation found in: {path}")


def validate_prometheus() -> None:
    prom = read("platform/observability/metrics/prometheus.yml")
    alerts = read("platform/observability/metrics/alert-rules.yml")

    ensure_no_tabs(prom, "platform/observability/metrics/prometheus.yml")
    ensure_no_tabs(alerts, "platform/observability/metrics/alert-rules.yml")

    required_prom_tokens = [
        "global:",
        "scrape_configs:",
        "rule_files:",
        "job_name: 'reference-app'",
        "targets: ['reference-app:5000']",
    ]
    for token in required_prom_tokens:
        if token not in prom:
            raise SystemExit(f"prometheus config missing token: {token}")

    required_alert_tokens = [
        "groups:",
        "alert: ServiceDown",
        'expr: up{job="reference-app"} == 0',
        "alert: HighLatencyP95",
    ]
    for token in required_alert_tokens:
        if token not in alerts:
            raise SystemExit(f"alert rules missing token: {token}")


def validate_gateway_app() -> None:
    gateway_app = read("infrastructure/gateway/app.py")
    required_tokens = [
        "PyJWKClient",
        "validate_bearer_token",
        "KEYCLOAK_ISSUER",
        "/api/protected/health",
    ]
    for token in required_tokens:
        if token not in gateway_app:
            raise SystemExit(f"gateway app missing token: {token}")


def validate_keycloak() -> None:
    realm_text = read("infrastructure/keycloak/realm/realm-export.json")
    realm = json.loads(realm_text)

    if realm.get("realm") != "platform":
        raise SystemExit("keycloak realm name must be 'platform'")
    if not realm.get("enabled"):
        raise SystemExit("keycloak realm must be enabled")
    if realm.get("otpPolicyType") != "totp":
        raise SystemExit("keycloak otpPolicyType must be 'totp'")
    if not realm.get("otpPolicyAlgorithm"):
        raise SystemExit("keycloak otpPolicyAlgorithm must be set")

    role_names = {role.get("name") for role in realm.get("roles", {}).get("realm", [])}
    for role in ["platform-admin", "platform-operator", "platform-user"]:
        if role not in role_names:
            raise SystemExit(f"missing keycloak role: {role}")

    compose = read("infrastructure/keycloak/docker-compose.yml")
    required_tokens = ["services:", "postgres:", "keycloak:", "--import-realm"]
    for token in required_tokens:
        if token not in compose:
            raise SystemExit(f"keycloak compose missing token: {token}")


def validate_gateway_compose() -> None:
    compose = read("infrastructure/gateway/docker-compose.yml")
    required_tokens = [
        "services:",
        "gateway:",
        "build: .",
        "keycloak:",
        "reference-app:",
        "KEYCLOAK_ISSUER:",
    ]
    for token in required_tokens:
        if token not in compose:
            raise SystemExit(f"gateway compose missing token: {token}")


def main() -> None:
    validate_prometheus()
    validate_gateway_app()
    validate_keycloak()
    validate_gateway_compose()
    print("config-validation: OK")


if __name__ == "__main__":
    main()
