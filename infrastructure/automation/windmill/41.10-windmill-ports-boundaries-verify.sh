#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/41-Automation-Windmill/41.10-Ports-Boundaries.md}"
PORT_POLICY_FILE="${PORT_POLICY_FILE:-infrastructure/automation/windmill/41.10-windmill-port-policy.yml}"
OUTBOUND_FILE="${OUTBOUND_FILE:-infrastructure/automation/windmill/41.10-windmill-outbound-allowlist.yml}"
UFW_FILE="${UFW_FILE:-infrastructure/automation/windmill/41.10-windmill-ufw-allowlist.template.csv}"
CHECKLIST_FILE="${CHECKLIST_FILE:-infrastructure/automation/windmill/41.10-windmill-boundary-verification-checklist.template.md}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/automation/windmill/41.10-windmill-boundaries-inputs.env.example}"

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
grep -q "port: 8000" "$PORT_POLICY_FILE"
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

grep -q "app port 8000" "$CHECKLIST_FILE"
grep -q "deny-by-default" "$CHECKLIST_FILE"
grep -q "no Docker socket" "$CHECKLIST_FILE"

grep -q "^WINDMILL_UI_PORT=" "$INPUTS_FILE"
grep -q "^WINDMILL_APP_PORT=" "$INPUTS_FILE"
grep -q "^WINDMILL_APP_BIND=" "$INPUTS_FILE"
grep -q "^WINDMILL_OUTBOUND_DEFAULT=" "$INPUTS_FILE"

echo "41.10-windmill-ports-boundaries: verification complete"
