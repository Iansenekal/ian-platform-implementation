# 03.30 Audit Logging Artifacts

Operational assets for `docs/03-Security-POPIA/03.30-Audit-Logging.md`.

## Files

- `03.30-audit-inputs.env.example`: environment-specific variables.
- `03.30-audit-sources.yml`: component/source matrix and index mapping.
- `03.30-audit-verify.sh`: baseline verification runner.
- `03.30-review-routine.template.md`: day-2 review cadence template.
- `03.30-evidence-checklist.md`: evidence requirements for go-live gate.

## Usage

1. Copy inputs file to runtime `.env` and set values.
2. Apply module-specific audit settings per stack.
3. Run `03.30-audit-verify.sh` from each VM.
4. Capture evidence for `83.30` gate and compliance pack.
