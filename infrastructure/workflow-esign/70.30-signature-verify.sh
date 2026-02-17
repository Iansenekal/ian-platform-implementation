#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/70-Document-Workflow-eSign/70.30-Signature-Standards-Verification.md}"
README_FILE="${README_FILE:-infrastructure/workflow-esign/README.md}"
TIER_FILE="${TIER_FILE:-infrastructure/workflow-esign/70.30-signature-tier-policy.yml}"
RECEIPT_FILE="${RECEIPT_FILE:-infrastructure/workflow-esign/70.30-receipt-schema.template.json}"
KEY_FILE="${KEY_FILE:-infrastructure/workflow-esign/70.30-key-rotation-policy.yml}"
CHECKLIST_FILE="${CHECKLIST_FILE:-infrastructure/workflow-esign/70.30-signature-verification-checklist.template.md}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/workflow-esign/70.30-signature-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$README_FILE" ]] || { echo "missing readme: $README_FILE" >&2; exit 1; }
[[ -f "$TIER_FILE" ]] || { echo "missing tier policy: $TIER_FILE" >&2; exit 1; }
[[ -f "$RECEIPT_FILE" ]] || { echo "missing receipt schema: $RECEIPT_FILE" >&2; exit 1; }
[[ -f "$KEY_FILE" ]] || { echo "missing key rotation policy: $KEY_FILE" >&2; exit 1; }
[[ -f "$CHECKLIST_FILE" ]] || { echo "missing verification checklist: $CHECKLIST_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }

grep -q "Signature Definition" "$DOC_FILE"
grep -q "Hash Input Standard" "$DOC_FILE"
grep -q "Signature Receipt Schema" "$DOC_FILE"
grep -q "Signing Keys and Trust Anchors" "$DOC_FILE"
grep -q "Verification Process" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "default_tier: S2" "$TIER_FILE"
grep -q "S1:" "$TIER_FILE"
grep -q "S2:" "$TIER_FILE"
grep -q "S3:" "$TIER_FILE"
grep -q "mfa_required_for_approval: true" "$TIER_FILE"

grep -q '"receipt_id"' "$RECEIPT_FILE"
grep -q '"document_sha256"' "$RECEIPT_FILE"
grep -q '"step_id"' "$RECEIPT_FILE"
grep -q '"server_signature"' "$RECEIPT_FILE"

grep -q "storage_path:" "$KEY_FILE"
grep -q "interval_days:" "$KEY_FILE"
grep -q "retain_old_public_keys: true" "$KEY_FILE"
grep -q "old_key_verify_support_required: true" "$KEY_FILE"

grep -q "Receipt exists in Evidence-Pack" "$CHECKLIST_FILE"
grep -q "Document SHA-256 matches" "$CHECKLIST_FILE"
grep -q "Historical receipts remain verifiable" "$CHECKLIST_FILE"

grep -q "^SIGNATURE_ASSURANCE_TIER=" "$INPUTS_FILE"
grep -q "^SIGNING_KEY_ROTATION_INTERVAL_DAYS=" "$INPUTS_FILE"
grep -q "^VERIFY_PUBLIC_KEY_TRUST_PATH=" "$INPUTS_FILE"
grep -q "^RETAIN_OLD_PUBLIC_KEYS=true" "$INPUTS_FILE"

echo "70.30-workflow-signature-standard: verification complete"
