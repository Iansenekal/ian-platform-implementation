#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/03-Security-POPIA/03.20-Secrets-Standard.md",
    "infrastructure/secrets-standard/README.md",
    "infrastructure/secrets-standard/03.20-stack-inputs.env.example",
    "infrastructure/secrets-standard/03.20-secrets-README.template.txt",
    "infrastructure/secrets-standard/03.20-env.template.example",
    "infrastructure/secrets-standard/03.20-init-stack-layout.sh",
    "infrastructure/secrets-standard/03.20-generate-secret-file.sh",
    "infrastructure/secrets-standard/03.20-verify-secrets-standard.sh",
    "infrastructure/secrets-standard/03.20-evidence-checklist.md",
]

missing = [path for path in required_files if not Path(path).is_file()]
if missing:
    raise SystemExit(f"03.20 secrets-standard artifacts missing: {', '.join(missing)}")

doc = Path("docs/03-Security-POPIA/03.20-Secrets-Standard.md").read_text(encoding="utf-8")
for token in ["S0", "S1", "S4", "/opt/<stack>/secrets", "Verification Checklist"]:
    if token not in doc:
        raise SystemExit(f"03.20 doc missing token: {token}")

init_script = Path("infrastructure/secrets-standard/03.20-init-stack-layout.sh").read_text(encoding="utf-8")
for token in ["/opt/${STACK_NAME}", "chmod 0750", "README.txt", ".env.template"]:
    if token not in init_script:
        raise SystemExit(f"03.20 init script missing token: {token}")

generate_script = Path("infrastructure/secrets-standard/03.20-generate-secret-file.sh").read_text(encoding="utf-8")
for token in ["openssl rand -base64 32", "openssl rand -hex 64", "openssl genpkey", "chmod 0440", "chmod 0400"]:
    if token not in generate_script:
        raise SystemExit(f"03.20 generate script missing token: {token}")

verify_script = Path("infrastructure/secrets-standard/03.20-verify-secrets-standard.sh").read_text(encoding="utf-8")
for token in ["stat -c", "grep -RIn", "--exclude-dir=secrets", "password=|passwd|secret=|token=|BEGIN PRIVATE KEY"]:
    if token not in verify_script:
        raise SystemExit(f"03.20 verify script missing token: {token}")

print("secrets-standard-artifacts: OK")
