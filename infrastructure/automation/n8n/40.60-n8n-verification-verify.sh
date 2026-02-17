#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/40-Automation-n8n/40.60-Verification-Checklist.md}"
MATRIX_FILE="${MATRIX_FILE:-infrastructure/automation/n8n/40.60-n8n-verification-matrix.csv}"
CHECKLIST_FILE="${CHECKLIST_FILE:-infrastructure/automation/n8n/40.60-n8n-verification-checklist.template.md}"
EVIDENCE_FILE="${EVIDENCE_FILE:-infrastructure/automation/n8n/40.60-n8n-evidence-pack.template.md}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/automation/n8n/40.60-n8n-verification-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$MATRIX_FILE" ]] || { echo "missing verification matrix: $MATRIX_FILE" >&2; exit 1; }
[[ -f "$CHECKLIST_FILE" ]] || { echo "missing checklist template: $CHECKLIST_FILE" >&2; exit 1; }
[[ -f "$EVIDENCE_FILE" ]] || { echo "missing evidence pack template: $EVIDENCE_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }

grep -q "Severity legend" "$DOC_FILE"
grep -q "Network Exposure and Trust Boundaries" "$DOC_FILE"
grep -q "Identity, SSO, MFA, and RBAC" "$DOC_FILE"
grep -q "Secrets and Credentials Hygiene" "$DOC_FILE"
grep -q "Workflow Governance and Change Control" "$DOC_FILE"
grep -q "Logging, Monitoring, and Alerting" "$DOC_FILE"
grep -q "Backup and Restore Readiness" "$DOC_FILE"
grep -q "Security Posture and Operational Readiness" "$DOC_FILE"
grep -q "Stop rollout immediately if any P0 fails" "$DOC_FILE" || grep -q "stop rollout immediately if any P0 fails" "$DOC_FILE"

grep -q "NET-01,P0" "$MATRIX_FILE"
grep -q "ID-03,P0" "$MATRIX_FILE"
grep -q "SEC-01,P0" "$MATRIX_FILE"
grep -q "BDR-02,P1" "$MATRIX_FILE"
grep -q "OPS-03,P2" "$MATRIX_FILE"

grep -q "P0 Gate" "$CHECKLIST_FILE"
grep -q "NET-01" "$CHECKLIST_FILE"
grep -q "ID-02" "$CHECKLIST_FILE"
grep -q "SEC-01" "$CHECKLIST_FILE"
grep -q "Gate Decision" "$CHECKLIST_FILE"

grep -q "Required attachments" "$EVIDENCE_FILE"
grep -q "UFW allowlist proof" "$EVIDENCE_FILE"
grep -q "backup logs and lab restore-test report" "$EVIDENCE_FILE"

grep -q "^N8N_ENVIRONMENT=" "$INPUTS_FILE"
grep -q "^N8N_ALLOWED_SOURCE_IPS=" "$INPUTS_FILE"
grep -q "^N8N_ADMIN_MFA_REQUIRED=true" "$INPUTS_FILE"
grep -q "^N8N_WORKFLOW_CATALOG_PATH=" "$INPUTS_FILE"
grep -q "^N8N_BACKUP_LOG_PATH=" "$INPUTS_FILE"

echo "40.60-n8n-verification-checklist: verification complete"
