#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/41-Automation-Windmill/41.00-Overview.md",
    "infrastructure/automation/windmill/README.md",
    "infrastructure/automation/windmill/41.00-windmill-role-boundaries.yml",
    "infrastructure/automation/windmill/41.00-windmill-vs-n8n-decision-matrix.csv",
    "infrastructure/automation/windmill/41.00-windmill-governance-checklist.template.md",
    "infrastructure/automation/windmill/41.00-windmill-inputs.env.example",
    "infrastructure/automation/windmill/41.00-windmill-overview-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"41.00 windmill overview artifacts missing: {', '.join(missing)}")

doc = Path("docs/41-Automation-Windmill/41.00-Overview.md").read_text(encoding="utf-8")
for token in [
    "Role of Windmill",
    "Windmill vs n8n Decision Guide",
    "Allowed and Prohibited",
    "Trust Boundaries",
    "Identity, SSO, and MFA",
    "Script/Job Lifecycle",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"41.00 doc missing token: {token}")

role = Path("infrastructure/automation/windmill/41.00-windmill-role-boundaries.yml").read_text(encoding="utf-8")
for token in [
    "runtime_mode: lan_only",
    "public_exposure_allowed: false",
    "backend_gateway_api",
    "outbound_internet_runtime_calls",
]:
    if token not in role:
        raise SystemExit(f"41.00 role boundaries missing token: {token}")

matrix = Path("infrastructure/automation/windmill/41.00-windmill-vs-n8n-decision-matrix.csv").read_text(encoding="utf-8")
for token in [
    "human_approvals_event_workflow,n8n",
    "scheduled_scripts_data_transforms,windmill",
    "hybrid_multi_step,n8n_plus_windmill",
    "simple_api_routing,gateway_or_n8n",
]:
    if token not in matrix:
        raise SystemExit(f"41.00 decision matrix missing token: {token}")

checklist = Path("infrastructure/automation/windmill/41.00-windmill-governance-checklist.template.md").read_text(encoding="utf-8")
for token in [
    "Job catalog maintained",
    "No secrets in scripts",
    "SSO + MFA",
    "Outbound internet calls disabled",
]:
    if token not in checklist:
        raise SystemExit(f"41.00 governance checklist missing token: {token}")

inputs = Path("infrastructure/automation/windmill/41.00-windmill-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "WINDMILL_ENABLED=",
    "WINDMILL_DEPLOYMENT_VM=",
    "WINDMILL_INTERNAL_URL=",
    "WINDMILL_SSO_ENABLED=",
]:
    if token not in inputs:
        raise SystemExit(f"41.00 inputs missing token: {token}")

verify = Path("infrastructure/automation/windmill/41.00-windmill-overview-verify.sh").read_text(encoding="utf-8")
for token in [
    "DOC_FILE",
    "ROLE_FILE",
    "MATRIX_FILE",
    "CHECKLIST_FILE",
    "INPUTS_FILE",
    "grep -q",
    "verification complete",
]:
    if token not in verify:
        raise SystemExit(f"41.00 verify script missing token: {token}")

print("automation-windmill-overview-artifacts: OK")
