#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/21-Nextcloud/21.81-eSign-Integration-Options.md",
    "infrastructure/nextcloud/21.81-esign-options-matrix.yml",
    "infrastructure/nextcloud/21.81-esign-inputs.env.example",
    "infrastructure/nextcloud/21.81-signature-verification-checklist.template.md",
    "infrastructure/nextcloud/21.81-esign-options-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"21.81 nextcloud eSign-option artifacts missing: {', '.join(missing)}")

doc = Path("docs/21-Nextcloud/21.81-eSign-Integration-Options.md").read_text(encoding="utf-8")
for token in [
    "Option A",
    "Option B",
    "Option C",
    "Option D",
    "SSO + MFA",
    "Evidence-Pack",
    "Approve/Reject",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"21.81 doc missing token: {token}")

matrix = Path("infrastructure/nextcloud/21.81-esign-options-matrix.yml").read_text(encoding="utf-8")
for token in ["options:", "A:", "B:", "C:", "D:", "cloud_runtime_dependency: true", "allowed_default: false", "selection_guidance:"]:
    if token not in matrix:
        raise SystemExit(f"21.81 option matrix missing token: {token}")

inputs = Path("infrastructure/nextcloud/21.81-esign-inputs.env.example").read_text(encoding="utf-8")
for token in ["MFA_STEP_UP_AT_SIGNING=true", "INTERNAL_PKI_PRESENT=", "CERTIFICATE_ISSUANCE_MODEL=", "REVOCATION_METHOD=", "EVIDENCE_PACK_SEALING="]:
    if token not in inputs:
        raise SystemExit(f"21.81 inputs template missing token: {token}")

checklist = Path("infrastructure/nextcloud/21.81-signature-verification-checklist.template.md").read_text(encoding="utf-8")
for token in ["Approve` or `Reject", "Hash manifest", "Signature verification report", "Independent signature validation", "sealed read-only"]:
    if token not in checklist:
        raise SystemExit(f"21.81 signature checklist missing token: {token}")

verify = Path("infrastructure/nextcloud/21.81-esign-options-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "MATRIX_FILE", "INPUTS_FILE", "CHECKLIST_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"21.81 verify script missing token: {token}")

print("nextcloud-esign-options-artifacts: OK")
