# VM Base Hardening (81.150)

This directory contains executable baseline hardening controls for Ubuntu VMs.

## Files
- `81.150-hardening-inputs.env.example`: rollout variables.
- `base-hardening.sh`: applies 81.150 baseline controls.
- `verify-hardening.sh`: verifies 81.150 controls and emits evidence-friendly output.
- `sshd_config.baseline`: hardened SSH daemon config template.
- `sshd.local.baseline`: fail2ban sshd jail baseline.
- `50unattended-upgrades.baseline`: unattended-upgrades policy baseline.
- `20auto-upgrades.baseline`: apt periodic update baseline.

## Usage (per VM)
1. `cp infrastructure/vm-provisioning/hardening/81.150-hardening-inputs.env.example infrastructure/vm-provisioning/hardening/81.150-hardening-inputs.env`
2. Adjust env values for target VM.
3. Apply:
   - `sudo bash infrastructure/vm-provisioning/hardening/base-hardening.sh --env-file infrastructure/vm-provisioning/hardening/81.150-hardening-inputs.env`
4. Verify:
   - `bash infrastructure/vm-provisioning/hardening/verify-hardening.sh --env-file infrastructure/vm-provisioning/hardening/81.150-hardening-inputs.env`
