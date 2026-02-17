#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/04-Identity-Access-MFA/04.70-BreakGlass-Recovery.md",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"04.70 break-glass artifacts missing: {', '.join(missing)}")

doc = Path("docs/04-Identity-Access-MFA/04.70-BreakGlass-Recovery.md").read_text(encoding="utf-8")
for token in [
    "Break-glass",
    "two-person",
    "Zone E",
    "quarterly",
    "incident",
    "BG-IdP-Admin",
    "Verification checklist",
]:
    if token not in doc:
        raise SystemExit(f"04.70 doc missing token: {token}")

print("break-glass-recovery-artifacts: OK")
