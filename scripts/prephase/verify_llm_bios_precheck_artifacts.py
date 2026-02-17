#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/82-LLM-Pointer-Server/82.10-BIOS-UEFI-GPU-Prechecks.md",
    "infrastructure/ollama-gpu/82.10-bios-precheck-inputs.env.example",
    "infrastructure/ollama-gpu/82.10-bios-precheck-checklist.md",
    "infrastructure/ollama-gpu/82.10-bios-precheck-gate.sh",
]

missing = [path for path in required_files if not Path(path).is_file()]
if missing:
    raise SystemExit(f"llm-bios-precheck artifacts missing: {', '.join(missing)}")

gate = Path("infrastructure/ollama-gpu/82.10-bios-precheck-gate.sh").read_text(encoding="utf-8")
for token in ["VT_X_ENABLED", "VT_D_OR_IOMMU_ENABLED", "ABOVE_4G_DECODING_ENABLED", "REBAR_ENABLED", "SECURE_BOOT_POLICY"]:
    if token not in gate:
        raise SystemExit(f"82.10 gate script missing token: {token}")

print("llm-bios-precheck-artifacts: OK")
