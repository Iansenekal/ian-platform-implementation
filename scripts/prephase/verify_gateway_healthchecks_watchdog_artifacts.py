#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/10-Backend-Gateway/10.80-Healthchecks-Watchdog.md",
    "infrastructure/gateway/10.80-healthcheck.sh",
    "infrastructure/gateway/10.80-deps-check.sh",
    "infrastructure/gateway/10.80-watchdog-log-summary.sh",
    "infrastructure/gateway/10.80-compose-healthcheck.template.yml",
    "infrastructure/gateway/10.80-systemd-watchdog.service.template",
    "infrastructure/gateway/10.80-health-watchdog-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"10.80 gateway health/watchdog artifacts missing: {', '.join(missing)}")

doc = Path("docs/10-Backend-Gateway/10.80-Healthchecks-Watchdog.md").read_text(encoding="utf-8")
for token in [
    "liveness",
    "readiness",
    "/health",
    "/ready",
    "OpenSearch",
    "IdP",
    "Restart=always",
    "503",
]:
    if token not in doc:
        raise SystemExit(f"10.80 doc missing token: {token}")

health = Path("infrastructure/gateway/10.80-healthcheck.sh").read_text(encoding="utf-8")
for token in ["GATEWAY_HEALTH_HOST", "GATEWAY_HEALTH_PORT", "curl -fsS", "/health"]:
    if token not in health:
        raise SystemExit(f"10.80 healthcheck template missing token: {token}")

deps = Path("infrastructure/gateway/10.80-deps-check.sh").read_text(encoding="utf-8")
for token in ["opensearch", "127.0.0.1:5432", "127.0.0.1:9998", "IDP_DISCOVERY_URL", "idp discovery not reachable"]:
    if token not in deps:
        raise SystemExit(f"10.80 deps-check template missing token: {token}")

summary = Path("infrastructure/gateway/10.80-watchdog-log-summary.sh").read_text(encoding="utf-8")
for token in ["ufw status", "ss -tulpn", "systemctl status ai-gateway.service"]:
    if token not in summary:
        raise SystemExit(f"10.80 watchdog summary script missing token: {token}")

verify = Path("infrastructure/gateway/10.80-health-watchdog-verify.sh").read_text(encoding="utf-8")
for token in ["HEALTHCHECK_FILE", "DEPS_FILE", "SUMMARY_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"10.80 verify script missing token: {token}")

print("gateway-healthchecks-watchdog-artifacts: OK")
