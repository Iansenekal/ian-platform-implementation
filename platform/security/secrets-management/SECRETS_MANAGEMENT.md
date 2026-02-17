# Secrets Management Baseline

Scope:
- Local development
- CI pipelines
- Service runtime

Rules:
- Never commit credentials to git.
- Use `.env` locally and secret stores in non-local environments.
- Rotate shared credentials on a fixed schedule.
- Mask secrets in logs and audit records.

Enforcement hooks:
- `tools/pre-commit-secrets-check.sh`
