# Data VM Verification Checklist (AI-DATA01)

- Ubuntu 24.04 minimal install completed per `docs/81-Proxmox-Host/81.110-Ubuntu-24.04-Minimal-Install-DataVM.md`.
- Static IP configured and verified (`10.10.5.178/24` by lab default).
- SSH access verified from admin workstation.
- Baseline package update/install completed.
- QEMU guest agent installed and active in guest.
- UFW baseline enabled and SSH allowlist rule present.
- Run and archive output:
- `bash infrastructure/vm-provisioning/install/81.110-ai-data01-verify.sh --env-file infrastructure/vm-provisioning/install/81.110-ai-data01-inputs.env`
- Evidence captured per `infrastructure/vm-provisioning/install/81.110-evidence-checklist.md`.
