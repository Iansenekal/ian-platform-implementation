#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/83-PrePhase-Integration/83.10-DNS-and-Naming-Resolution-Tests.md",
    "infrastructure/prephase/tests/83.10-dns-inputs.env.example",
    "infrastructure/prephase/tests/83.10-dns-resolution-tests.sh",
    "infrastructure/prephase/tests/83.10-evidence-checklist.md",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"prephase-dns artifacts missing: {', '.join(missing)}")

runner = Path("infrastructure/prephase/tests/83.10-dns-resolution-tests.sh").read_text(encoding="utf-8")
for token in ["resolvectl status", "getent hosts", "dig +short", "dig -x", "DNS Forwarders"]:
    if token not in runner:
        raise SystemExit(f"83.10 runner missing token: {token}")

doc = Path("docs/83-PrePhase-Integration/83.10-DNS-and-Naming-Resolution-Tests.md").read_text(encoding="utf-8")
for token in ["Forward", "Reverse", "Forwarders", "Mandatory"]:
    if token not in doc:
        raise SystemExit(f"83.10 doc missing token: {token}")

print("prephase-dns-artifacts: OK")
