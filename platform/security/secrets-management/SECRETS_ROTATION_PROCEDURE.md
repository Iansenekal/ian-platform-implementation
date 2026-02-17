# Secrets Rotation Procedure

Frequency:
- Privileged credentials: every 90 days
- Service tokens: every 30 days
- Emergency rotation: immediately after suspected compromise

Procedure:
1. Generate replacement secret.
2. Stage in target runtime environment.
3. Deploy service consuming the new secret.
4. Validate health and authentication paths.
5. Revoke old secret.
6. Record evidence in audit/change log.
