#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/40-Automation-n8n/40.50-Backup-Restore.md}"
SCOPE_FILE="${SCOPE_FILE:-infrastructure/automation/n8n/40.50-n8n-backup-scope.yml}"
RETENTION_FILE="${RETENTION_FILE:-infrastructure/automation/n8n/40.50-n8n-backup-retention-matrix.csv}"
PROCEDURE_FILE="${PROCEDURE_FILE:-infrastructure/automation/n8n/40.50-n8n-restore-procedure.template.md}"
CHECKLIST_FILE="${CHECKLIST_FILE:-infrastructure/automation/n8n/40.50-n8n-restore-verification-checklist.template.md}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/automation/n8n/40.50-n8n-backup-restore-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$SCOPE_FILE" ]] || { echo "missing backup scope policy: $SCOPE_FILE" >&2; exit 1; }
[[ -f "$RETENTION_FILE" ]] || { echo "missing backup retention matrix: $RETENTION_FILE" >&2; exit 1; }
[[ -f "$PROCEDURE_FILE" ]] || { echo "missing restore procedure: $PROCEDURE_FILE" >&2; exit 1; }
[[ -f "$CHECKLIST_FILE" ]] || { echo "missing restore checklist: $CHECKLIST_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }

grep -q "Required Backup Scope" "$DOC_FILE"
grep -q "Disallowed Backup Content" "$DOC_FILE"
grep -q "Restore Procedure" "$DOC_FILE"
grep -q "Mandatory Post-Restore Verification" "$DOC_FILE"
grep -q "Restore Test Schedule" "$DOC_FILE"

grep -q "required_backup_items" "$SCOPE_FILE"
grep -q "n8n_database" "$SCOPE_FILE"
grep -q "workflow_exports_sanitized" "$SCOPE_FILE"
grep -q "encryption_key_required_for_restore: true" "$SCOPE_FILE"

grep -q "n8n_database,daily,30-90" "$RETENTION_FILE"
grep -q "workflow_exports,on_change_plus_daily,180-365" "$RETENTION_FILE"
grep -q "config_templates,on_change_plus_weekly,180" "$RETENTION_FILE"

grep -q "Validate n8n encryption key recovery" "$PROCEDURE_FILE"
grep -q "Execute post-restore verification checklist" "$PROCEDURE_FILE"

grep -q "SSO login and admin MFA enforcement" "$CHECKLIST_FILE"
grep -q "Credential decryption works" "$CHECKLIST_FILE"
grep -q "RBAC deny tests" "$CHECKLIST_FILE"
grep -q "Scheduled backups resume" "$CHECKLIST_FILE"

grep -q "^N8N_BACKUP_TOOL=" "$INPUTS_FILE"
grep -q "^N8N_BACKUP_DESTINATION=" "$INPUTS_FILE"
grep -q "^N8N_DB_BACKUP_FREQUENCY=" "$INPUTS_FILE"
grep -q "^N8N_BACKUP_RETENTION_DAYS=" "$INPUTS_FILE"
grep -q "^N8N_ENCRYPTION_KEY_STORAGE=" "$INPUTS_FILE"

echo "40.50-n8n-backup-restore: verification complete"
