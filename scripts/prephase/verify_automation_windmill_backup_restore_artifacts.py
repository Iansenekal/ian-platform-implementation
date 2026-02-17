#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/41-Automation-Windmill/41.50-Backup-Restore.md",
    "infrastructure/automation/windmill/41.50-windmill-backup-scope.yml",
    "infrastructure/automation/windmill/41.50-windmill-backup-retention-matrix.csv",
    "infrastructure/automation/windmill/41.50-windmill-restore-procedure.template.md",
    "infrastructure/automation/windmill/41.50-windmill-restore-verification-checklist.template.md",
    "infrastructure/automation/windmill/41.50-windmill-backup-restore-inputs.env.example",
    "infrastructure/automation/windmill/41.50-windmill-backup-restore-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"41.50 windmill backup/restore artifacts missing: {', '.join(missing)}")

doc = Path("docs/41-Automation-Windmill/41.50-Backup-Restore.md").read_text(encoding="utf-8")
for token in [
    "Required Backup Scope",
    "Disallowed Backup Content",
    "Recommended Backup Frequency",
    "Restore Procedure",
    "Mandatory Post-Restore Verification",
    "Restore Test Schedule",
]:
    if token not in doc:
        raise SystemExit(f"41.50 doc missing token: {token}")

scope = Path("infrastructure/automation/windmill/41.50-windmill-backup-scope.yml").read_text(encoding="utf-8")
for token in [
    "required_backup_items",
    "windmill_database",
    "windmill_script_flow_exports_versioned",
    "encryption_dependencies_required_for_restore: true",
]:
    if token not in scope:
        raise SystemExit(f"41.50 backup scope missing token: {token}")

retention = Path("infrastructure/automation/windmill/41.50-windmill-backup-retention-matrix.csv").read_text(encoding="utf-8")
for token in [
    "windmill_database,daily,30-90",
    "script_flow_exports,on_change_plus_daily,180-365",
    "config_templates,on_change_plus_weekly,180",
]:
    if token not in retention:
        raise SystemExit(f"41.50 retention matrix missing token: {token}")

procedure = Path("infrastructure/automation/windmill/41.50-windmill-restore-procedure.template.md").read_text(encoding="utf-8")
for token in [
    "Validate secret and encryption dependency recovery readiness",
    "Restore Windmill database",
    "Execute post-restore verification checklist",
]:
    if token not in procedure:
        raise SystemExit(f"41.50 restore procedure missing token: {token}")

checklist = Path("infrastructure/automation/windmill/41.50-windmill-restore-verification-checklist.template.md").read_text(encoding="utf-8")
for token in [
    "SSO login and admin MFA enforcement",
    "RBAC deny tests",
    "Logs/audit do not expose secrets",
    "Scheduled backups resume",
]:
    if token not in checklist:
        raise SystemExit(f"41.50 restore checklist missing token: {token}")

inputs = Path("infrastructure/automation/windmill/41.50-windmill-backup-restore-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "WINDMILL_BACKUP_TOOL=",
    "WINDMILL_BACKUP_DESTINATION=",
    "WINDMILL_DB_BACKUP_FREQUENCY=",
    "WINDMILL_BACKUP_RETENTION_DAYS=",
    "WINDMILL_SECRETS_DEPENDENCY_STORAGE=",
]:
    if token not in inputs:
        raise SystemExit(f"41.50 inputs missing token: {token}")

verify = Path("infrastructure/automation/windmill/41.50-windmill-backup-restore-verify.sh").read_text(encoding="utf-8")
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
        raise SystemExit(f"41.50 verify script missing token: {token}")

print("automation-windmill-backup-restore-artifacts: OK")
