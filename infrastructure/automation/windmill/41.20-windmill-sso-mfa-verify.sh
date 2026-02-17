#!/usr/bin/env bash
set -euo pipefail

DOC_FILE="${DOC_FILE:-docs/41-Automation-Windmill/41.20-SSO-MFA-Policy.md}"
IDENTITY_FILE="${IDENTITY_FILE:-infrastructure/automation/windmill/41.20-windmill-identity-modes.yml}"
MFA_FILE="${MFA_FILE:-infrastructure/automation/windmill/41.20-windmill-mfa-role-policy.csv}"
RBAC_FILE="${RBAC_FILE:-infrastructure/automation/windmill/41.20-windmill-rbac-group-mapping.yml}"
SESSION_FILE="${SESSION_FILE:-infrastructure/automation/windmill/41.20-windmill-session-policy.yml}"
INPUTS_FILE="${INPUTS_FILE:-infrastructure/automation/windmill/41.20-windmill-sso-mfa-inputs.env.example}"
CHECKLIST_FILE="${CHECKLIST_FILE:-infrastructure/automation/windmill/41.20-windmill-sso-mfa-verification-checklist.template.md}"

[[ -f "$DOC_FILE" ]] || { echo "missing doc: $DOC_FILE" >&2; exit 1; }
[[ -f "$IDENTITY_FILE" ]] || { echo "missing identity modes: $IDENTITY_FILE" >&2; exit 1; }
[[ -f "$MFA_FILE" ]] || { echo "missing MFA role policy: $MFA_FILE" >&2; exit 1; }
[[ -f "$RBAC_FILE" ]] || { echo "missing RBAC mapping: $RBAC_FILE" >&2; exit 1; }
[[ -f "$SESSION_FILE" ]] || { echo "missing session policy: $SESSION_FILE" >&2; exit 1; }
[[ -f "$INPUTS_FILE" ]] || { echo "missing inputs: $INPUTS_FILE" >&2; exit 1; }
[[ -f "$CHECKLIST_FILE" ]] || { echo "missing checklist: $CHECKLIST_FILE" >&2; exit 1; }

grep -q "Policy Goals" "$DOC_FILE"
grep -q "Identity Modes" "$DOC_FILE"
grep -q "MFA Requirements" "$DOC_FILE"
grep -q "RBAC Mapping" "$DOC_FILE"
grep -q "Session and Login Security" "$DOC_FILE"
grep -q "Break-Glass" "$DOC_FILE"
grep -q "Audit Requirements" "$DOC_FILE"
grep -q "Verification Checklist" "$DOC_FILE"

grep -q "preferred_mode: idp_sso" "$IDENTITY_FILE"
grep -q "idp_local_users" "$IDENTITY_FILE"
grep -q "break_glass_local_windmill_only" "$IDENTITY_FILE"
grep -q "local_windmill_users_default_enabled: false" "$IDENTITY_FILE"

grep -q "windmill_admin,yes" "$MFA_FILE"
grep -q "windmill_operator,recommended" "$MFA_FILE"
grep -q "windmill_script_builder,recommended" "$MFA_FILE"
grep -q "WebAuthn|TOTP" "$MFA_FILE"

grep -q "AI-WM-ADMINS" "$RBAC_FILE"
grep -q "AI-WM-OPERATORS" "$RBAC_FILE"
grep -q "AI-WM-BUILDERS" "$RBAC_FILE"
grep -q "separation_of_duties_required: true" "$RBAC_FILE"

grep -q "idle_timeout_required: true" "$SESSION_FILE"
grep -q "reauth_for_sensitive_actions: true" "$SESSION_FILE"
grep -q "idp_lockout_policy_required: true" "$SESSION_FILE"
grep -q "lan_allowlist_required: true" "$SESSION_FILE"

grep -q "^WINDMILL_IDENTITY_MODE=" "$INPUTS_FILE"
grep -q "^WINDMILL_MFA_ADMINS_REQUIRED=" "$INPUTS_FILE"
grep -q "^WINDMILL_GROUP_ADMIN=" "$INPUTS_FILE"
grep -q "^WINDMILL_IDLE_TIMEOUT_MINUTES=" "$INPUTS_FILE"

grep -q "IdP SSO login works" "$CHECKLIST_FILE"
grep -q "MFA is enforced" "$CHECKLIST_FILE"
grep -q "RBAC deny tests" "$CHECKLIST_FILE"
grep -q "break-glass process" "$CHECKLIST_FILE"

echo "41.20-windmill-sso-mfa: verification complete"
