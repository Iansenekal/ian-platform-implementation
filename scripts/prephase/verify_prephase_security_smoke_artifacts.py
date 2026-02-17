#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/83-PrePhase-Integration/83.20-Security-Smoke-Tests.md",
    "infrastructure/prephase/tests/83.20-security-smoke-inputs.env.example",
    "infrastructure/prephase/tests/83.20-security-smoke-tests.sh",
    "infrastructure/prephase/tests/83.20-evidence-checklist.md",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"prephase-security-smoke artifacts missing: {', '.join(missing)}")

runner = Path("infrastructure/prephase/tests/83.20-security-smoke-tests.sh").read_text(encoding="utf-8")
for token in ["ufw status verbose", "ss -tulpen", "nmap -Pn", "/api/tags", "BLOCKED_DATA_PORTS"]:
    if token not in runner:
        raise SystemExit(f"83.20 runner missing token: {token}")

doc = Path("docs/83-PrePhase-Integration/83.20-Security-Smoke-Tests.md").read_text(encoding="utf-8")
for token in ["UFW", "SSH", "Port", "Mandatory"]:
    if token not in doc:
        raise SystemExit(f"83.20 doc missing token: {token}")

print("prephase-security-smoke-artifacts: OK")
