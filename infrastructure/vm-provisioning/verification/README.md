# VM Provisioning Verification Gates

This directory contains verification gates that must pass before platform bootstrap.

## Files
- `verification-gate.md`: high-level gate policy.
- `81.190-gate-inputs.env.example`: inputs for automated VM gate.
- `81.190-vm-provisioning-gate.sh`: executable multi-VM verification gate.
- `81.190-evidence-checklist.md`: mandatory evidence checklist.

## Usage (81.190)
1. Copy inputs:
   - `cp infrastructure/vm-provisioning/verification/81.190-gate-inputs.env.example infrastructure/vm-provisioning/verification/81.190-gate-inputs.env`
2. Adjust values (VM list, admin user, expected DNS/gateway/timezone).
3. Run:
   - `bash infrastructure/vm-provisioning/verification/81.190-vm-provisioning-gate.sh --env-file infrastructure/vm-provisioning/verification/81.190-gate-inputs.env --evidence-dir artifacts/vm-provisioning-gate`
