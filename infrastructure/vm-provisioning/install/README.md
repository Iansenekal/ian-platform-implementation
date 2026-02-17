# VM OS Install Gates (81.110+)

This directory contains OS installation verification assets for VM provisioning.

## Current Assets
- `81.110-ai-data01-inputs.env.example`: AI-DATA01 install variables.
- `81.110-ai-data01-verify.sh`: AI-DATA01 post-install verification checks.
- `81.110-netplan-01-netcfg.yaml.example`: static netplan baseline reference.
- `81.110-evidence-checklist.md`: mandatory evidence checklist.
- `81.120-ai-frontend01-inputs.env.example`: AI-FRONTEND01 install variables.
- `81.120-ai-frontend01-verify.sh`: AI-FRONTEND01 post-install verification checks.
- `81.120-netplan-01-netcfg.yaml.example`: frontend static netplan baseline reference.
- `81.120-evidence-checklist.md`: frontend mandatory evidence checklist.

## Usage (81.110)
1. Copy inputs file:
   - `cp infrastructure/vm-provisioning/install/81.110-ai-data01-inputs.env.example infrastructure/vm-provisioning/install/81.110-ai-data01-inputs.env`
2. Fill environment-specific values.
3. Run inside AI-DATA01 VM:
   - `bash infrastructure/vm-provisioning/install/81.110-ai-data01-verify.sh --env-file infrastructure/vm-provisioning/install/81.110-ai-data01-inputs.env`
4. Capture evidence listed in `81.110-evidence-checklist.md`.

## Usage (81.120)
1. Copy inputs file:
   - `cp infrastructure/vm-provisioning/install/81.120-ai-frontend01-inputs.env.example infrastructure/vm-provisioning/install/81.120-ai-frontend01-inputs.env`
2. Fill environment-specific values.
3. Run inside AI-FRONTEND01 VM:
   - `bash infrastructure/vm-provisioning/install/81.120-ai-frontend01-verify.sh --env-file infrastructure/vm-provisioning/install/81.120-ai-frontend01-inputs.env`
4. Capture evidence listed in `81.120-evidence-checklist.md`.
