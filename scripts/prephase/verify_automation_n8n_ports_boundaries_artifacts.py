#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/40-Automation-n8n/40.10-Ports-Boundaries.md",
    "infrastructure/automation/n8n/40.10-n8n-port-policy.yml",
    "infrastructure/automation/n8n/40.10-n8n-outbound-allowlist.yml",
    "infrastructure/automation/n8n/40.10-n8n-ufw-allowlist.template.csv",
    "infrastructure/automation/n8n/40.10-n8n-boundary-verification-checklist.template.md",
    "infrastructure/automation/n8n/40.10-n8n-boundaries-inputs.env.example",
    "infrastructure/automation/n8n/40.10-n8n-ports-boundaries-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"40.10 n8n ports/boundaries artifacts missing: {', '.join(missing)}")

doc = Path("docs/40-Automation-n8n/40.10-Ports-Boundaries.md").read_text(encoding="utf-8")
for token in [
    "Inbound Ports",
    "Outbound Communications",
    "UFW Allowlist Intent",
    "Trust Boundary Rules",
    "Integration Boundaries",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"40.10 doc missing token: {token}")

port_policy = Path("infrastructure/automation/n8n/40.10-n8n-port-policy.yml").read_text(encoding="utf-8")
for token in [
    "lan_only_required: true",
    "public_exposure_allowed: false",
    "port: 443",
    "port: 5678",
    "bind_scope: localhost_only",
]:
    if token not in port_policy:
        raise SystemExit(f"40.10 port policy missing token: {token}")

outbound = Path("infrastructure/automation/n8n/40.10-n8n-outbound-allowlist.yml").read_text(encoding="utf-8")
for token in [
    "default_policy: deny",
    "backend_gateway",
    "nextcloud",
    "postgres",
    "opensearch",
    "external_outbound_requires_explicit_approval: true",
]:
    if token not in outbound:
        raise SystemExit(f"40.10 outbound allowlist missing token: {token}")

ufw = Path("infrastructure/automation/n8n/40.10-n8n-ufw-allowlist.template.csv").read_text(encoding="utf-8")
for token in [
    "admin_workstation_static_ips",
    "AI-FRONTEND01_optional",
    "all_other_lan_hosts",
    "no,reduce_attack_surface",
]:
    if token not in ufw:
        raise SystemExit(f"40.10 UFW template missing token: {token}")

checklist = Path("infrastructure/automation/n8n/40.10-n8n-boundary-verification-checklist.template.md").read_text(encoding="utf-8")
for token in [
    "port 5678",
    "deny-by-default",
    "no Docker socket",
    "secrets standard",
]:
    if token not in checklist:
        raise SystemExit(f"40.10 checklist missing token: {token}")

inputs = Path("infrastructure/automation/n8n/40.10-n8n-boundaries-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "N8N_UI_PORT=",
    "N8N_CONTAINER_PORT=",
    "N8N_CONTAINER_BIND=",
    "N8N_OUTBOUND_DEFAULT=",
]:
    if token not in inputs:
        raise SystemExit(f"40.10 inputs missing token: {token}")

verify = Path("infrastructure/automation/n8n/40.10-n8n-ports-boundaries-verify.sh").read_text(encoding="utf-8")
for token in [
    "DOC_FILE",
    "PORT_POLICY_FILE",
    "OUTBOUND_FILE",
    "UFW_FILE",
    "CHECKLIST_FILE",
    "INPUTS_FILE",
    "grep -q",
    "verification complete",
]:
    if token not in verify:
        raise SystemExit(f"40.10 verify script missing token: {token}")

print("automation-n8n-ports-boundaries-artifacts: OK")
