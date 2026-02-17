#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/40-Automation-n8n/40.50-Backup-Restore.md",
    "infrastructure/automation/n8n/40.50-n8n-backup-scope.yml",
    "infrastructure/automation/n8n/40.50-n8n-backup-retention-matrix.csv",
    "infrastructure/automation/n8n/40.50-n8n-restore-procedure.template.md",
    "infrastructure/automation/n8n/40.50-n8n-restore-verification-checklist.template.md",
    "infrastructure/automation/n8n/40.50-n8n-backup-restore-inputs.env.example",
    "infrastructure/automation/n8n/40.50-n8n-backup-restore-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"40.50 n8n backup/restore artifacts missing: {', '.join(missing)}")

doc = Path("docs/40-Automation-n8n/40.50-Backup-Restore.md").read_text(encoding="utf-8")
for token in [
    "Required Backup Scope",
    "Disallowed Backup Content",
    "Recommended Backup Frequency",
    "Restore Procedure",
    "Mandatory Post-Restore Verification",
    "Restore Test Schedule",
]:
    if token not in doc:
        raise SystemExit(f"40.50 doc missing token: {token}")

scope = Path("infrastructure/automation/n8n/40.50-n8n-backup-scope.yml").read_text(encoding="utf-8")
for token in [
    "required_backup_items",
    "n8n_database",
    "workflow_exports_sanitized",
    "encryption_key_required_for_restore: true",
]:
    if token not in scope:
        raise SystemExit(f"40.50 backup scope missing token: {token}")

retention = Path("infrastructure/automation/n8n/40.50-n8n-backup-retention-matrix.csv").read_text(encoding="utf-8")
for token in [
    "n8n_database,daily,30-90",
    "workflow_exports,on_change_plus_daily,180-365",
    "config_templates,on_change_plus_weekly,180",
]:
    if token not in retention:
        raise SystemExit(f"40.50 retention matrix missing token: {token}")

procedure = Path("infrastructure/automation/n8n/40.50-n8n-restore-procedure.template.md").read_text(encoding="utf-8")
for token in [
    "Validate n8n encryption key recovery",
    "Restore n8n database",
    "Execute post-restore verification checklist",
]:
    if token not in procedure:
        raise SystemExit(f"40.50 restore procedure missing token: {token}")

checklist = Path("infrastructure/automation/n8n/40.50-n8n-restore-verification-checklist.template.md").read_text(encoding="utf-8")
for token in [
    "SSO login and admin MFA enforcement",
    "Credential decryption works",
    "RBAC deny tests",
    "Scheduled backups resume",
]:
    if token not in checklist:
        raise SystemExit(f"40.50 restore checklist missing token: {token}")

inputs = Path("infrastructure/automation/n8n/40.50-n8n-backup-restore-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "N8N_BACKUP_TOOL=",
    "N8N_BACKUP_DESTINATION=",
    "N8N_DB_BACKUP_FREQUENCY=",
    "N8N_BACKUP_RETENTION_DAYS=",
    "N8N_ENCRYPTION_KEY_STORAGE=",
]:
    if token not in inputs:
        raise SystemExit(f"40.50 inputs missing token: {token}")

verify = Path("infrastructure/automation/n8n/40.50-n8n-backup-restore-verify.sh").read_text(encoding="utf-8")
for token in [
    "DOC_FILE",
    "SCOPE_FILE",
    "RETENTION_FILE",
    "PROCEDURE_FILE",
    "CHECKLIST_FILE",
    "INPUTS_FILE",
    "grep -q",
    "verification complete",
]:
    if token not in verify:
        raise SystemExit(f"40.50 verify script missing token: {token}")

print("automation-n8n-backup-restore-artifacts: OK")
