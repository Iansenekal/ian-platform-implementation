#!/usr/bin/env python3
from pathlib import Path

plan = Path("infrastructure/proxmox/networking/bridge-vlan-plan.yml").read_text(encoding="utf-8")
required_tokens = [
    "network_design:",
    "mode: baseline_vmbr0",
    "lan_only: true",
    "baseline_vmbr0:",
    "bridge: vmbr0",
    "management_ip_cidr:",
    "gateway:",
    "admin_allowlist:",
    "optional_vlan_expansion:",
    "id: 10",
    "id: 20",
    "id: 30",
    "cidr: 10.10.10.0/24",
    "cidr: 10.10.20.0/24",
    "cidr: 10.10.30.0/24",
    "routing_assumptions:",
    "no_wan_port_forward: true",
    "inter_vlan_routing_controlled_by_firewall: true",
    "internal_dns_only: true",
]
missing = [token for token in required_tokens if token not in plan]
if missing:
    raise SystemExit(f"network-plan missing tokens: {', '.join(missing)}")
print("network-plan: OK")
