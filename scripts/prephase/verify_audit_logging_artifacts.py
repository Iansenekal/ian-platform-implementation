#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/03-Security-POPIA/03.30-Audit-Logging.md",
    "infrastructure/audit-logging/README.md",
    "infrastructure/audit-logging/03.30-audit-inputs.env.example",
    "infrastructure/audit-logging/03.30-audit-sources.yml",
    "infrastructure/audit-logging/03.30-audit-verify.sh",
    "infrastructure/audit-logging/03.30-review-routine.template.md",
    "infrastructure/audit-logging/03.30-evidence-checklist.md",
    "platform/observability/audit-events/EVENT_SCHEMA.md",
]

missing = [path for path in required_files if not Path(path).is_file()]
if missing:
    raise SystemExit(f"03.30 audit artifacts missing: {', '.join(missing)}")

doc = Path("docs/03-Security-POPIA/03.30-Audit-Logging.md").read_text(encoding="utf-8")
for token in ["A1", "A2", "A7", "correlation_id", "Africa/Johannesburg", "Verification Checklist"]:
    if token not in doc:
        raise SystemExit(f"03.30 doc missing token: {token}")

verify_script = Path("infrastructure/audit-logging/03.30-audit-verify.sh").read_text(encoding="utf-8")
for token in ["timedatectl status", "chronyc tracking", "journalctl -u ufw", "journalctl -u ssh", "correlation_id|request_id"]:
    if token not in verify_script:
        raise SystemExit(f"03.30 verify script missing token: {token}")

sources = Path("infrastructure/audit-logging/03.30-audit-sources.yml").read_text(encoding="utf-8")
for token in ["gateway_api", "identity_provider", "nextcloud", "search_graph", "system-audit"]:
    if token not in sources:
        raise SystemExit(f"03.30 sources map missing token: {token}")

schema = Path("platform/observability/audit-events/EVENT_SCHEMA.md").read_text(encoding="utf-8")
for token in ["event_type", "event_category", "correlation_id", "actor", "target", "outcome"]:
    if token not in schema:
        raise SystemExit(f"event schema missing required token: {token}")

print("audit-logging-artifacts: OK")
