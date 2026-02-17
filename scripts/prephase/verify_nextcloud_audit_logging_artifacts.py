#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/21-Nextcloud/21.45-Audit-Logging-Events.md",
    "infrastructure/nextcloud/21.45-audit-event-taxonomy.yml",
    "infrastructure/nextcloud/21.45-audit-inputs.env.example",
    "infrastructure/nextcloud/21.45-evidence-pack.template.md",
    "infrastructure/nextcloud/21.45-audit-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"21.45 nextcloud audit logging artifacts missing: {', '.join(missing)}")

doc = Path("docs/21-Nextcloud/21.45-Audit-Logging-Events.md").read_text(encoding="utf-8")
for token in [
    "POPIA",
    "Event Taxonomy",
    "external share",
    "correlation_id",
    "metadata",
    "OpenSearch",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"21.45 doc missing token: {token}")

taxonomy = Path("infrastructure/nextcloud/21.45-audit-event-taxonomy.yml").read_text(encoding="utf-8")
for token in ["event_taxonomy:", "authentication:", "authorization_admin:", "content_metadata:", "external_sharing:", "service_accounts:", "required_fields:", "correlation_id"]:
    if token not in taxonomy:
        raise SystemExit(f"21.45 taxonomy missing token: {token}")

inputs = Path("infrastructure/nextcloud/21.45-audit-inputs.env.example").read_text(encoding="utf-8")
for token in ["PRIMARY_LOG_STORE=", "INDEX_NAMING=", "AUDIT_ACCESS_ROLE=AI-NC-AUDIT-READONLY", "TOKEN_HEADER_REDACTION=enabled", "PII_REDACTION=enabled"]:
    if token not in inputs:
        raise SystemExit(f"21.45 inputs template missing token: {token}")

evidence = Path("infrastructure/nextcloud/21.45-evidence-pack.template.md").read_text(encoding="utf-8")
for token in ["Case Metadata", "Required Artifacts", "Validation Notes"]:
    if token not in evidence:
        raise SystemExit(f"21.45 evidence template missing token: {token}")

verify = Path("infrastructure/nextcloud/21.45-audit-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "TAXONOMY_FILE", "INPUTS_FILE", "EVIDENCE_TEMPLATE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"21.45 verify script missing token: {token}")

print("nextcloud-audit-logging-artifacts: OK")
