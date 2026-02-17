#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/04-Identity-Access-MFA/04.30-MFA-Policy-Standard.md",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"04.30 MFA policy artifacts missing: {', '.join(missing)}")

doc = Path("docs/04-Identity-Access-MFA/04.30-MFA-Policy-Standard.md").read_text(encoding="utf-8")
for token in [
    "MFA",
    "TOTP",
    "WebAuthn",
    "Zone E",
    "Recovery codes",
    "reset",
    "Verification checklist",
]:
    if token not in doc:
        raise SystemExit(f"04.30 doc missing token: {token}")

print("mfa-policy-artifacts: OK")
