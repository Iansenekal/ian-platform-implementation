# VM Access Baseline (81.160)

This directory contains admin access controls for VM SSH onboarding and source allowlisting.

## Files
- `81.160-access-inputs.env.example`: rollout inputs for SSH/UFW policy.
- `admin-workstation-inventory.csv`: inventory template for admin devices/IPs/fingerprints.
- `admin-users-keys.example.csv`: template mapping admin usernames to SSH public keys.
- `vscode-ssh-config.example`: optional host alias config for VS Code Remote-SSH.
- `provision-admin-access.sh`: create users, install keys, apply SSH allowlist.
- `verify-admin-access.sh`: verify user/key/UFW posture.
- `81.160-evidence-checklist.md`: evidence capture checklist.

## Usage (per VM)
1. Copy and fill files:
   - `cp infrastructure/vm-provisioning/access/81.160-access-inputs.env.example infrastructure/vm-provisioning/access/81.160-access-inputs.env`
   - `cp infrastructure/vm-provisioning/access/admin-users-keys.example.csv infrastructure/vm-provisioning/access/admin-users-keys.csv`
2. Apply:
   - `sudo bash infrastructure/vm-provisioning/access/provision-admin-access.sh --env-file infrastructure/vm-provisioning/access/81.160-access-inputs.env --keys-file infrastructure/vm-provisioning/access/admin-users-keys.csv`
3. Verify:
   - `bash infrastructure/vm-provisioning/access/verify-admin-access.sh --env-file infrastructure/vm-provisioning/access/81.160-access-inputs.env --keys-file infrastructure/vm-provisioning/access/admin-users-keys.csv`
