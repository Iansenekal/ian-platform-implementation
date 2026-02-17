# Model Allowlist Policy (Summary)

Authoritative policy and controls are defined in:
- `docs/82-LLM-Pointer-Server/82.50-US-EU-Model-Allowlist-Policy.md`

Enforcement artifacts:
- `infrastructure/ollama-gpu/82.50-model-allowlist.yaml.example`
- `infrastructure/ollama-gpu/82.50-allowlist-enforced-pull.sh`
- `infrastructure/ollama-gpu/82.50-allowlist-audit.sh`

Baseline requirements:
- Only US/EU provenance models may be installed.
- Pulls must run through allowlist enforcement with approval reference.
- Evidence records are mandatory per model install and weekly audits.
