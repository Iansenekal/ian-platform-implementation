# Proxmox Networking (81.40 / 81.50)

This directory contains design and implementation artifacts for Proxmox host networking.

## Files
- `bridge-vlan-plan.yml`: canonical network design values and routing assumptions.
- `interfaces.vmbr0-baseline.example`: baseline `/etc/network/interfaces` example.
- `interfaces.vlan-trunk.example`: VLAN-aware trunk `/etc/network/interfaces` example.
- `81.40-design-gate-checklist.md`: design gate checklist.
- `81.50-network-inputs.env.example`: implementation-time input variables.
- `render-interfaces.sh`: generate baseline/trunk interfaces content from env values.
- `81.50-network-verify.sh`: host verification checks for bridge/routing/connectivity.
- `81.50-evidence-checklist.md`: required evidence capture checklist.
- `81.60-verify-inputs.env.example`: post-implementation verification input variables.
- `81.60-network-verification.sh`: full verification collector for host + optional VM checks.
- `81.60-evidence-checklist.md`: mandatory verification gate evidence checklist.

## Recommended Flow
1. Fill `81.50-network-inputs.env` from `81.50-network-inputs.env.example`.
2. Render and review config:
   - `bash infrastructure/proxmox/networking/render-interfaces.sh --env-file infrastructure/proxmox/networking/81.50-network-inputs.env --mode baseline --output /tmp/interfaces.new`
3. Apply in Proxmox UI, or copy reviewed file content to `/etc/network/interfaces` on host.
4. Run host checks:
   - `bash infrastructure/proxmox/networking/81.50-network-verify.sh --env-file infrastructure/proxmox/networking/81.50-network-inputs.env`
5. Capture evidence in `81.50-evidence-checklist.md`.
6. Run mandatory verification gate:
   - `bash infrastructure/proxmox/networking/81.60-network-verification.sh --env-file infrastructure/proxmox/networking/81.60-verify-inputs.env --evidence-dir artifacts/network-verification`
7. Complete `81.60-evidence-checklist.md` with screenshot and perimeter proof.
