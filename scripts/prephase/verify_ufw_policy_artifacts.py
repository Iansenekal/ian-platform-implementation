#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/02-Ports-Trust-Boundaries/02.20-UFW-Policy-Model.md",
    "infrastructure/firewall/README.md",
    "infrastructure/firewall/vars.env.example",
    "infrastructure/firewall/apply-ufw-frontend.sh",
    "infrastructure/firewall/apply-ufw-backend.sh",
    "infrastructure/firewall/verify-ufw.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"ufw-policy artifacts missing: {', '.join(missing)}")

frontend = Path("infrastructure/firewall/apply-ufw-frontend.sh").read_text(encoding="utf-8")
for token in ["ufw default deny incoming", "port 443", "ENABLE_SSH", "ufw limit in from"]:
    if token not in frontend:
        raise SystemExit(f"frontend UFW script missing token: {token}")

backend = Path("infrastructure/firewall/apply-ufw-backend.sh").read_text(encoding="utf-8")
for token in ["FRONTEND_IP", "port 443", "ENABLE_MONITORING_COLLECTOR", "9100", "9187", "9114"]:
    if token not in backend:
        raise SystemExit(f"backend UFW script missing token: {token}")

verify = Path("infrastructure/firewall/verify-ufw.sh").read_text(encoding="utf-8")
for token in ["ufw status verbose", "ss -lntp", ":5432", ":9200", ":9998"]:
    if token not in verify:
        raise SystemExit(f"verify UFW script missing token: {token}")

doc = Path("docs/02-Ports-Trust-Boundaries/02.20-UFW-Policy-Model.md").read_text(encoding="utf-8")
for token in ["F1", "F5", "AI-FRONTEND01", "AI-DATA01", "Acceptance Criteria"]:
    if token not in doc:
        raise SystemExit(f"02.20 doc missing token: {token}")

print("ufw-policy-artifacts: OK")
