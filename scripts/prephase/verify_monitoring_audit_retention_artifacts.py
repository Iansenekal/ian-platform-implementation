#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/50-Monitoring-Logging/50.30-Audit-Events-and-Retention.md",
    "infrastructure/audit-logging/50.30-retention-policy-matrix.yml",
    "infrastructure/audit-logging/50.30-legal-hold-request.template.md",
    "infrastructure/audit-logging/50.30-quarterly-access-review.template.md",
    "infrastructure/audit-logging/50.30-evidence-checklist.md",
    "platform/observability/audit-events/EVENT_SCHEMA.md",
    "platform/observability/audit-events/RETENTION_POLICY.md",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"50.30 monitoring/audit retention artifacts missing: {', '.join(missing)}")

doc = Path("docs/50-Monitoring-Logging/50.30-Audit-Events-and-Retention.md").read_text(encoding="utf-8")
for token in [
    "P0",
    "Minimum Audit Event Fields",
    "Retention and Purge Policy",
    "Legal Hold",
    "Africa/Johannesburg",
    "Data minimization",
]:
    if token not in doc:
        raise SystemExit(f"50.30 doc missing token: {token}")

matrix_text = Path("infrastructure/audit-logging/50.30-retention-policy-matrix.yml").read_text(encoding="utf-8")
for token in [
    "authentication_mfa",
    "admin_role_changes",
    "automation_execution_metadata",
    "file_share_metadata",
    "system_security_controls",
    "quarterly_access_review",
    "purge_execution_logs",
]:
    if token not in matrix_text:
        raise SystemExit(f"50.30 matrix missing token: {token}")

legal_hold = Path("infrastructure/audit-logging/50.30-legal-hold-request.template.md").read_text(encoding="utf-8")
for token in ["Compliance Officer", "Security Owner", "Hold end date", "read-only"]:
    if token not in legal_hold:
        raise SystemExit(f"50.30 legal hold template missing token: {token}")

retention = Path("platform/observability/audit-events/RETENTION_POLICY.md").read_text(encoding="utf-8")
for token in ["Retention", "Purge", "365", "180", "90"]:
    if token not in retention:
        raise SystemExit(f"RETENTION_POLICY missing token: {token}")

print("monitoring-audit-retention-artifacts: OK")
