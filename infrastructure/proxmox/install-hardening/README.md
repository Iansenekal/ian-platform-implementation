# Proxmox Install + Hardening (Step 10)

This directory hosts implementation artifacts for:
- 81.20 Proxmox install
- 81.30 post-install hardening

Current assets:
- `81.20-install-inputs.env.example` - install variable template
- `81.20-first-boot-verify.sh` - first-boot pass/fail checks for IP/route/DNS/timezone
- `81.20-evidence-checklist.md` - mandatory screenshot/command evidence checklist
- `post-install-verify.sh` - 81.30 post-hardening verification command pack

Usage:
1. Copy `81.20-install-inputs.env.example` to `81.20-install-inputs.env` and fill values.
2. Run `81.20-first-boot-verify.sh --env-file infrastructure/proxmox/install-hardening/81.20-install-inputs.env`.
3. Capture evidence listed in `81.20-evidence-checklist.md`.
