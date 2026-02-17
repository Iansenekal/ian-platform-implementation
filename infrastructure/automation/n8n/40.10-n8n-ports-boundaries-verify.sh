#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/40-Automation-n8n/40.10-Ports-Boundaries.md}"
PORT_POLICY_FILE="${PORT_POLICY_FILE:-infrastructure/automation/n8n/40.10-n8n-port-policy.yml}"
OUTBOUND_FILE="${OUTBOUND_FILE:-infrastructure/automation/n8n/40.10-n8n-outbound-allowlist.yml}"
UFW_FILE="${UFW_FILE:-infrastructure/automation/n8n/40.10-n8n-ufw-allowlist.template.csv}"
CHECKLIST_FILE="${CHECKLIST_FILE:-infrastructure/automation/n8n/40.10-n8n-boundary-verification-checklist.template.md}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/automation/n8n/40.10-n8n-boundaries-inputs.env.example}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$PORT_POLICY_FILE" ]] || { echo "missing port policy: $PORT_POLICY_FILE" >&2; exit 1; }
[[ -f "$OUTBOUND_FILE" ]] || { echo "missing outbound allowlist: $OUTBOUND_FILE" >&2; exit 1; }
[[ -f "$UFW_FILE" ]] || { echo "missing UFW allowlist template: $UFW_FILE" >&2; exit 1; }
[[ -f "$CHECKLIST_FILE" ]] || { echo "missing verification checklist: $CHECKLIST_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }

grep -q "Inbound Ports" "$DOC_FILE"
grep -q "Outbound Communications" "$DOC_FILE"
grep -q "UFW Allowlist Intent" "$DOC_FILE"
grep -q "Trust Boundary Rules" "$DOC_FILE"
grep -q "Risk Notes" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "lan_only_required: true" "$PORT_POLICY_FILE"
grep -q "public_exposure_allowed: false" "$PORT_POLICY_FILE"
grep -q "port: 443" "$PORT_POLICY_FILE"
grep -q "port: 5678" "$PORT_POLICY_FILE"
grep -q "bind_scope: localhost_only" "$PORT_POLICY_FILE"

grep -q "default_policy: deny" "$OUTBOUND_FILE"
grep -q "backend_gateway" "$OUTBOUND_FILE"
grep -q "nextcloud" "$OUTBOUND_FILE"
grep -q "opensearch" "$OUTBOUND_FILE"
grep -q "external_outbound_requires_explicit_approval: true" "$OUTBOUND_FILE"

grep -q "admin_workstation_static_ips" "$UFW_FILE"
grep -q "AI-FRONTEND01_optional" "$UFW_FILE"
grep -q "all_other_lan_hosts" "$UFW_FILE"
grep -q "no,reduce_attack_surface" "$UFW_FILE"

grep -q "port 5678" "$CHECKLIST_FILE"
grep -q "deny-by-default" "$CHECKLIST_FILE"
grep -q "no Docker socket" "$CHECKLIST_FILE"

grep -q "^N8N_UI_PORT=" "$INPUTS_FILE"
grep -q "^N8N_CONTAINER_PORT=" "$INPUTS_FILE"
grep -q "^N8N_CONTAINER_BIND=" "$INPUTS_FILE"
grep -q "^N8N_OUTBOUND_DEFAULT=" "$INPUTS_FILE"

echo "40.10-n8n-ports-boundaries: verification complete"
