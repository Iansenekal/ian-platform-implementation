# Firewall Policy Artifacts (02.20)

These files implement the deterministic UFW policy model defined in:
`docs/02-Ports-Trust-Boundaries/02.20-UFW-Policy-Model.md`.

## Files

- `vars.env.example`: source-of-truth variables.
- `apply-ufw-frontend.sh`: apply policy on AI-FRONTEND01.
- `apply-ufw-backend.sh`: apply policy on AI-DATA01.
- `verify-ufw.sh`: quick host verification helper.

## Usage on target VM

1. Copy this folder to `/opt/ai-platform/firewall/`.
2. Create `/opt/ai-platform/firewall/vars.env` from `vars.env.example` and set site values.
3. Keep a Proxmox console open.
4. Run the apply script for the host role with `sudo`.
5. Run `sudo ./verify-ufw.sh` and capture evidence.

## Safety

- Always keep at least one console session open during rule changes.
- Validate access from allowlisted and non-allowlisted clients immediately after apply.
