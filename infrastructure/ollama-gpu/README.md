# GPU Ollama Build (Steps 19-20 / 82.00+)

This directory contains the LLM pointer-server baseline for dedicated Ollama runtime.

## Scope
- Dedicated pointer-server role and dependency boundaries.
- LAN-only exposure policy.
- Model provenance allowlist policy (US/EU).
- Runtime profile constraints for GPU host.

## Files
- `model-allowlist-policy.md`: approved model families and governance notes.
- `pointer-server-profile.yml`: machine-checkable runtime policy profile.
- `82.10-bios-precheck-inputs.env.example`: BIOS/UEFI precheck decision inputs.
- `82.10-bios-precheck-checklist.md`: hardware/firmware evidence checklist.
- `82.10-bios-precheck-gate.sh`: validates 82.10 precheck decisions are complete.
- `82.30-hardening-inputs.env.example`: hardening rollout inputs.
- `82.30-hardening-apply.sh`: applies LLM server hardening baseline.
- `82.30-hardening-verify.sh`: verifies hardening policy compliance.
- `82.30-evidence-checklist.md`: required hardening evidence capture list.
- `82.30-sshd_config.baseline`: hardened sshd baseline template.
- `82.30-jail.local.baseline`: fail2ban ssh jail baseline.
- `82.30-journald-override.conf`: journald bounds baseline.
- `82.30-50unattended-upgrades.baseline`: unattended-upgrades policy.
- `82.30-20auto-upgrades.baseline`: apt periodic update policy.
- `82.40-ollama-install-inputs.env.example`: install/runtime rollout inputs.
- `82.40-ollama-override.conf.baseline`: systemd override baseline template.
- `82.40-ollama-install-apply.sh`: installs/configures Ollama runtime.
- `82.40-ollama-install-verify.sh`: verifies service, network, and GPU checks.
- `82.40-evidence-checklist.md`: required install evidence capture list.
- `82.50-model-allowlist.yaml.example`: authoritative US/EU model allowlist template.
- `82.50-model-inventory-record.example.json`: per-model evidence record template.
- `82.50-allowlist-enforced-pull.sh`: wrapper enforcing allowlist on model pulls.
- `82.50-allowlist-audit.sh`: weekly audit of installed models vs allowlist/inventory.
- `82.50-evidence-checklist.md`: required allowlist policy evidence capture list.
- `82.60-lan-allowlist-inputs.env.example`: LAN bind/UFW rollout inputs.
- `82.60-lan-allowlist-apply.sh`: enforces Ollama bind and UFW caller allowlist.
- `82.60-lan-allowlist-verify.sh`: verifies bind policy and LAN allowlist controls.
- `82.60-evidence-checklist.md`: required LAN-only enforcement evidence list.
- `82.80-verification-inputs.env.example`: post-hardening verification inputs.
- `82.80-verification-run.sh`: executes mandatory verification checks and evidence logging.
- `82.80-evidence-checklist.md`: required 82.80 evidence capture list.
- `82.90-client-rollout-variables.yaml`: client-specific rollout values template.

## Related Docs
- `docs/82-LLM-Pointer-Server/82.00-Overview-and-RoleInPlatform.md`
- `docs/82-LLM-Pointer-Server/82.10-BIOS-UEFI-GPU-Prechecks.md`
- `docs/82-LLM-Pointer-Server/82.30-Base-Hardening-SSH-UFW-UnattendedUpgrades.md`
- `docs/82-LLM-Pointer-Server/82.40-Ollama-Install-AMD-GPU.md`
- `docs/82-LLM-Pointer-Server/82.50-US-EU-Model-Allowlist-Policy.md`
- `docs/82-LLM-Pointer-Server/82.60-Ollama-LAN-Only-Bind-and-UFW-Allowlist.md`
- `docs/82-LLM-Pointer-Server/82.80-Verification-Checklist.md`
- `docs/82-LLM-Pointer-Server/82.90-Client-Rollout-Variables.md`
- Central Ollama VM install guide and follow-on runbooks (`82.10+`).
