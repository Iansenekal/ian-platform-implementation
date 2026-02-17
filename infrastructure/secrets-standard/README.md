# 03.20 Secrets Standard Artifacts

These assets implement `docs/03-Security-POPIA/03.20-Secrets-Standard.md`.

## Files

- `03.20-stack-inputs.env.example`: stack-specific inputs.
- `03.20-init-stack-layout.sh`: create deterministic `/opt/<stack>` layout.
- `03.20-generate-secret-file.sh`: generate file-based secrets with strict permissions.
- `03.20-verify-secrets-standard.sh`: verify permissions and no hardcoded-secret patterns.
- `03.20-secrets-README.template.txt`: non-secret README template for `/opt/<stack>/secrets/README.txt`.
- `03.20-env.template.example`: non-secret `.env.template` sample.
- `03.20-evidence-checklist.md`: execution evidence checklist.

## Usage

1. Copy `03.20-stack-inputs.env.example` to `03.20-stack-inputs.env` and set values.
2. Run `sudo bash 03.20-init-stack-layout.sh 03.20-stack-inputs.env`.
3. Generate each required secret with `03.20-generate-secret-file.sh`.
4. Run `sudo bash 03.20-verify-secrets-standard.sh 03.20-stack-inputs.env`.
