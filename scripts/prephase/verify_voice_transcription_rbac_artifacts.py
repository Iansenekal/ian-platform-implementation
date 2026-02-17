#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/60-Voice-Transcription/60.40-RBAC-Access-Controls.md",
    "infrastructure/voice-transcription/README.md",
    "infrastructure/voice-transcription/60.40-role-permission-matrix.csv",
    "infrastructure/voice-transcription/60.40-group-mapping.template.yml",
    "infrastructure/voice-transcription/60.40-nextcloud-acl-map.csv",
    "infrastructure/voice-transcription/60.40-api-authz-rules.yml",
    "infrastructure/voice-transcription/60.40-rbac-inputs.env.example",
    "infrastructure/voice-transcription/60.40-rbac-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"60.40 voice/transcription rbac artifacts missing: {', '.join(missing)}")

doc = Path("docs/60-Voice-Transcription/60.40-RBAC-Access-Controls.md").read_text(encoding="utf-8")
for token in [
    "Least privilege",
    "Voice-Admin",
    "Permission Matrix",
    "Nextcloud Folder ACL",
    "Gateway/API",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"60.40 doc missing token: {token}")

matrix = Path("infrastructure/voice-transcription/60.40-role-permission-matrix.csv").read_text(encoding="utf-8")
for token in ["capability,voice_admin", "approve_reject_transcript", "export_transcript", "change_policy_retention_rules"]:
    if token not in matrix:
        raise SystemExit(f"60.40 permission matrix missing token: {token}")

groups = Path("infrastructure/voice-transcription/60.40-group-mapping.template.yml").read_text(encoding="utf-8")
for token in ["Voice-Admin", "project_scope_pattern", "mfa_required_roles", "restricted_workflow_roles"]:
    if token not in groups:
        raise SystemExit(f"60.40 group mapping missing token: {token}")

acl = Path("infrastructure/voice-transcription/60.40-nextcloud-acl-map.csv").read_text(encoding="utf-8")
for token in ["30-PendingReview", "40-Final", "50-Evidence-Pack", "90-System-Internal"]:
    if token not in acl:
        raise SystemExit(f"60.40 nextcloud acl map missing token: {token}")

rules = Path("infrastructure/voice-transcription/60.40-api-authz-rules.yml").read_text(encoding="utf-8")
for token in ["require_role_and_project_scope: true", "forbid_index_from_pending_review: true", "export_requires_approval_event: true", "no_related_content_leakage: true"]:
    if token not in rules:
        raise SystemExit(f"60.40 api authz rules missing token: {token}")

inputs = Path("infrastructure/voice-transcription/60.40-rbac-inputs.env.example").read_text(encoding="utf-8")
for token in ["GROUPS_CLAIM_NAME=groups", "ROLE_GROUP_PREFIX=VOICE-ROLE-", "MFA_REQUIRED_ROLES=", "SERVICE_ACCOUNT_SCOPE_MODEL="]:
    if token not in inputs:
        raise SystemExit(f"60.40 rbac inputs missing token: {token}")

verify = Path("infrastructure/voice-transcription/60.40-rbac-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "MATRIX_FILE", "GROUPS_FILE", "ACL_FILE", "RULES_FILE", "INPUTS_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"60.40 verify script missing token: {token}")

print("voice-transcription-rbac-artifacts: OK")
