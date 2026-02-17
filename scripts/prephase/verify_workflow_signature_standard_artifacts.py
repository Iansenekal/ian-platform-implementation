#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/70-Document-Workflow-eSign/70.30-Signature-Standards-Verification.md",
    "infrastructure/workflow-esign/README.md",
    "infrastructure/workflow-esign/70.30-signature-tier-policy.yml",
    "infrastructure/workflow-esign/70.30-receipt-schema.template.json",
    "infrastructure/workflow-esign/70.30-key-rotation-policy.yml",
    "infrastructure/workflow-esign/70.30-signature-verification-checklist.template.md",
    "infrastructure/workflow-esign/70.30-signature-inputs.env.example",
    "infrastructure/workflow-esign/70.30-signature-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"70.30 workflow signature-standard artifacts missing: {', '.join(missing)}")

doc = Path("docs/70-Document-Workflow-eSign/70.30-Signature-Standards-Verification.md").read_text(encoding="utf-8")
for token in [
    "Signature Definition",
    "Hash Input Standard",
    "Signature Receipt Schema",
    "Signing Keys and Trust Anchors",
    "Verification Process",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"70.30 doc missing token: {token}")

tier = Path("infrastructure/workflow-esign/70.30-signature-tier-policy.yml").read_text(encoding="utf-8")
for token in ["default_tier: S2", "S1:", "S2:", "S3:", "mfa_required_for_approval: true"]:
    if token not in tier:
        raise SystemExit(f"70.30 signature tier policy missing token: {token}")

receipt = Path("infrastructure/workflow-esign/70.30-receipt-schema.template.json").read_text(encoding="utf-8")
for token in ["\"receipt_id\"", "\"document_sha256\"", "\"step_id\"", "\"server_signature\""]:
    if token not in receipt:
        raise SystemExit(f"70.30 receipt schema missing token: {token}")

keys = Path("infrastructure/workflow-esign/70.30-key-rotation-policy.yml").read_text(encoding="utf-8")
for token in ["storage_path:", "interval_days:", "retain_old_public_keys: true", "old_key_verify_support_required: true"]:
    if token not in keys:
        raise SystemExit(f"70.30 key rotation policy missing token: {token}")

checklist = Path("infrastructure/workflow-esign/70.30-signature-verification-checklist.template.md").read_text(encoding="utf-8")
for token in ["Receipt exists in Evidence-Pack", "Document SHA-256 matches", "Historical receipts remain verifiable"]:
    if token not in checklist:
        raise SystemExit(f"70.30 verification checklist missing token: {token}")

inputs = Path("infrastructure/workflow-esign/70.30-signature-inputs.env.example").read_text(encoding="utf-8")
for token in ["SIGNATURE_ASSURANCE_TIER=", "SIGNING_KEY_ROTATION_INTERVAL_DAYS=", "VERIFY_PUBLIC_KEY_TRUST_PATH=", "RETAIN_OLD_PUBLIC_KEYS=true"]:
    if token not in inputs:
        raise SystemExit(f"70.30 signature inputs missing token: {token}")

verify = Path("infrastructure/workflow-esign/70.30-signature-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "TIER_FILE", "RECEIPT_FILE", "KEY_FILE", "CHECKLIST_FILE", "INPUTS_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"70.30 verify script missing token: {token}")

print("workflow-signature-standard-artifacts: OK")
