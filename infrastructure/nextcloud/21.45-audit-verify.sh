#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/21-Nextcloud/21.45-Audit-Logging-Events.md}"
TAXONOMY_FILE="${TAXONOMY_FILE:-infrastructure/nextcloud/21.45-audit-event-taxonomy.yml}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/nextcloud/21.45-audit-inputs.env.example}"
EVIDENCE_TEMPLATE="${EVIDENCE_TEMPLATE:-infrastructure/nextcloud/21.45-evidence-pack.template.md}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$TAXONOMY_FILE" ]] || { echo "missing taxonomy: $TAXONOMY_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }
[[ -f "$EVIDENCE_TEMPLATE" ]] || { echo "missing evidence template: $EVIDENCE_TEMPLATE" >&2; exit 1; }

grep -q "Event Taxonomy" "$DOC_FILE"
grep -q "external share" "$DOC_FILE"
grep -q "correlation_id" "$DOC_FILE"
grep -q "metadata" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "^event_taxonomy:" "$TAXONOMY_FILE"
grep -q "authentication:" "$TAXONOMY_FILE"
grep -q "external_sharing:" "$TAXONOMY_FILE"
grep -q "required_fields:" "$TAXONOMY_FILE"
grep -q "correlation_id" "$TAXONOMY_FILE"

grep -q "^PRIMARY_LOG_STORE=" "$INPUTS_FILE"
grep -q "^INDEX_NAMING=" "$INPUTS_FILE"
grep -q "^AUDIT_ACCESS_ROLE=AI-NC-AUDIT-READONLY" "$INPUTS_FILE"
grep -q "^TOKEN_HEADER_REDACTION=enabled" "$INPUTS_FILE"

grep -q "Case Metadata" "$EVIDENCE_TEMPLATE"
grep -q "Required Artifacts" "$EVIDENCE_TEMPLATE"
grep -q "Validation Notes" "$EVIDENCE_TEMPLATE"

echo "21.45-nextcloud-audit-events: verification complete"
