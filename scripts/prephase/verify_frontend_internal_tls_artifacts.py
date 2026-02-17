#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/20-Frontend-Ingress-UI/20.20-TLS-Internal.md",
    "infrastructure/gateway/20.20-tls-inputs.env.example",
    "infrastructure/gateway/20.20-ui-san.cnf.example",
    "infrastructure/gateway/20.20-tls-verify.sh",
    "infrastructure/gateway/20.20-evidence-checklist.md",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"20.20 internal TLS artifacts missing: {', '.join(missing)}")

doc = Path("docs/20-Frontend-Ingress-UI/20.20-TLS-Internal.md").read_text(encoding="utf-8")
for token in [
    "internal CA",
    "AI-FRONTEND01",
    "Root + Intermediate",
    "openssl s_client",
    "update-ca-certificates",
    "Verify return code: 0",
]:
    if token not in doc:
        raise SystemExit(f"20.20 doc missing token: {token}")

inputs = Path("infrastructure/gateway/20.20-tls-inputs.env.example").read_text(encoding="utf-8")
for token in ["UI_FQDN", "FRONTEND_IP", "CA_BUNDLE_PATH", "UI_CERT_PATH", "UI_KEY_PATH"]:
    if token not in inputs:
        raise SystemExit(f"20.20 tls inputs missing token: {token}")

san = Path("infrastructure/gateway/20.20-ui-san.cnf.example").read_text(encoding="utf-8")
for token in ["subjectAltName", "DNS.1", "IP.1", "CN=ui.lab.local"]:
    if token not in san:
        raise SystemExit(f"20.20 san template missing token: {token}")

verify = Path("infrastructure/gateway/20.20-tls-verify.sh").read_text(encoding="utf-8")
for token in ["INPUT_FILE", "openssl s_client", 'curl "https://${UI_FQDN}/"', "verification complete"]:
    if token not in verify:
        raise SystemExit(f"20.20 tls verify script missing token: {token}")

print("frontend-internal-tls-artifacts: OK")
