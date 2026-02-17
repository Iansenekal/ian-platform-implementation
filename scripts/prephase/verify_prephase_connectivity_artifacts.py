#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/83-PrePhase-Integration/83.00-EndToEnd-Connectivity-Tests.md",
    "infrastructure/prephase/tests/83.00-connectivity-inputs.env.example",
    "infrastructure/prephase/tests/83.00-end-to-end-connectivity.sh",
    "infrastructure/prephase/tests/83.00-evidence-checklist.md",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"prephase-connectivity artifacts missing: {', '.join(missing)}")

script = Path("infrastructure/prephase/tests/83.00-end-to-end-connectivity.sh").read_text(encoding="utf-8")
for token in ["nc -vz", "curl -ksf", "api/tags", "openssl s_client", "ufw status verbose"]:
    if token not in script:
        raise SystemExit(f"83.00 runner missing token: {token}")

doc = Path("docs/83-PrePhase-Integration/83.00-EndToEnd-Connectivity-Tests.md").read_text(encoding="utf-8")
for token in ["PASS", "DNS", "TLS", "Firewall"]:
    if token not in doc:
        raise SystemExit(f"83.00 doc missing token: {token}")

print("prephase-connectivity-artifacts: OK")
