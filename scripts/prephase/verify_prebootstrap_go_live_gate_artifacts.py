#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/83-PrePhase-Integration/83.30-PreBootstrap-GoLive-Gate.md",
    "infrastructure/prephase/tests/83.30-prebootstrap-go-live-gate.md",
    "infrastructure/prephase/tests/83.30-go-live-gate-inputs.env.example",
    "infrastructure/prephase/tests/83.30-go-live-gate-report.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"prebootstrap-go-live artifacts missing: {', '.join(missing)}")

runner = Path("infrastructure/prephase/tests/83.30-go-live-gate-report.sh").read_text(encoding="utf-8")
for token in ["SECTION_1", "SECTION_8", "NO-GO", "GO", "BOOTSTRAP_RELEASE_REF"]:
    if token not in runner:
        raise SystemExit(f"83.30 report script missing token: {token}")

doc = Path("docs/83-PrePhase-Integration/83.30-PreBootstrap-GoLive-Gate.md").read_text(encoding="utf-8")
for token in ["Go/No-Go", "REQUIRED", "Decision", "Sign-Off"]:
    if token not in doc:
        raise SystemExit(f"83.30 doc missing token: {token}")

print("prebootstrap-go-live-artifacts: OK")
