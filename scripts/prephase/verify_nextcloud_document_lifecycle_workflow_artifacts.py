#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/21-Nextcloud/21.80-Document-Lifecycle-Workflow-Integration.md",
    "infrastructure/nextcloud/21.80-lifecycle-folder-template.txt",
    "infrastructure/nextcloud/21.80-lifecycle-state-model.yml",
    "infrastructure/nextcloud/21.80-evidence-pack-manifest.template.json",
    "infrastructure/nextcloud/21.80-lifecycle-inputs.env.example",
    "infrastructure/nextcloud/21.80-lifecycle-workflow-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"21.80 nextcloud lifecycle/workflow artifacts missing: {', '.join(missing)}")

doc = Path("docs/21-Nextcloud/21.80-Document-Lifecycle-Workflow-Integration.md").read_text(encoding="utf-8")
for token in [
    "Draft",
    "In Review",
    "Approved",
    "Signed",
    "Archived",
    "Approve/Reject",
    "Evidence-Pack",
    "hash",
]:
    if token not in doc:
        raise SystemExit(f"21.80 doc missing token: {token}")

folder_template = Path("infrastructure/nextcloud/21.80-lifecycle-folder-template.txt").read_text(encoding="utf-8")
for token in ["01-Drafts/", "02-InReview/", "03-Approved/", "04-Signed/", "05-Archive/", "99-Evidence-Pack/"]:
    if token not in folder_template:
        raise SystemExit(f"21.80 folder template missing token: {token}")

state_model = Path("infrastructure/nextcloud/21.80-lifecycle-state-model.yml").read_text(encoding="utf-8")
for token in ["lifecycle_states:", "transitions:", "Approve", "Reject", "approve_by_silence_allowed: false", "sealing:"]:
    if token not in state_model:
        raise SystemExit(f"21.80 state model missing token: {token}")

manifest = Path("infrastructure/nextcloud/21.80-evidence-pack-manifest.template.json").read_text(encoding="utf-8")
for token in ['"approval_chain"', '"hash_manifest"', '"signature_manifest"', '"sealed": true']:
    if token not in manifest:
        raise SystemExit(f"21.80 evidence manifest missing token: {token}")

inputs = Path("infrastructure/nextcloud/21.80-lifecycle-inputs.env.example").read_text(encoding="utf-8")
for token in ["EXPLICIT_APPROVAL_ACTIONS=Approve,Reject", "APPROVE_BY_SILENCE_ALLOWED=false", "HASH_ALGORITHM=SHA-256", "EVIDENCE_PACK_SEALING="]:
    if token not in inputs:
        raise SystemExit(f"21.80 inputs template missing token: {token}")

verify = Path("infrastructure/nextcloud/21.80-lifecycle-workflow-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "FOLDER_TEMPLATE_FILE", "STATE_MODEL_FILE", "MANIFEST_TEMPLATE_FILE", "INPUTS_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"21.80 verify script missing token: {token}")

print("nextcloud-document-lifecycle-workflow-artifacts: OK")
