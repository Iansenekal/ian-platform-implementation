# VM Provisioning Verification Gate (Step 18)

All VM checks must pass before moving to core platform rollout.

Mandatory checks:
- AI-DATA01 install gate executed (`81.110-ai-data01-verify.sh`).
- AI-FRONTEND01 install gate executed (`81.120-ai-frontend01-verify.sh`).
- 81.150 hardening apply + verify executed on each deployed VM.
- 81.160 admin access onboarding + verification executed on each deployed VM.
- 81.190 provisioning gate script executed and PASS report generated.
- Evidence stored for SSH/UFW/fail2ban/unattended-upgrades outputs.

Required approvals:
- Infrastructure lead
- Security lead
- Platform owner
