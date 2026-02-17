#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/30-Search-KnowledgeGraph/30.10-Sources-and-Connectors.md",
    "infrastructure/search-graph/README.md",
    "infrastructure/search-graph/30.10-connector-inventory.template.yml",
    "infrastructure/search-graph/30.10-connector-onboarding-checklist.template.md",
    "infrastructure/search-graph/30.10-connector-inputs.env.example",
    "infrastructure/search-graph/30.10-connector-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"30.10 search/graph sources-connectors artifacts missing: {', '.join(missing)}")

doc = Path("docs/30-Search-KnowledgeGraph/30.10-Sources-and-Connectors.md").read_text(encoding="utf-8")
for token in [
    "Nextcloud",
    "SMB",
    "Microsoft 365",
    "ACL",
    "minimization",
    "onboarding",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"30.10 doc missing token: {token}")

inventory = Path("infrastructure/search-graph/30.10-connector-inventory.template.yml").read_text(encoding="utf-8")
for token in [
    "source_type: nextcloud",
    "source_type: smb",
    "source_type: m365",
    "indexing_mode: metadata_default",
    "acl_required: true",
]:
    if token not in inventory:
        raise SystemExit(f"30.10 inventory missing token: {token}")

checklist = Path("infrastructure/search-graph/30.10-connector-onboarding-checklist.template.md").read_text(encoding="utf-8")
for token in [
    "business justification",
    "service identity",
    "ACL deny tests",
    "change control",
]:
    if token not in checklist:
        raise SystemExit(f"30.10 onboarding checklist missing token: {token}")

inputs = Path("infrastructure/search-graph/30.10-connector-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "ENABLED_CONNECTORS=",
    "METADATA_ONLY_DEFAULT=true",
    "GROUP_CLAIM_NAME=groups",
    "SECRETS_PATH=/opt/<stack>/secrets",
    "DELETION_PROPAGATION_SLA=",
]:
    if token not in inputs:
        raise SystemExit(f"30.10 inputs template missing token: {token}")

verify = Path("infrastructure/search-graph/30.10-connector-verify.sh").read_text(encoding="utf-8")
for token in [
    "DOC_FILE",
    "INVENTORY_FILE",
    "CHECKLIST_FILE",
    "INPUTS_FILE",
    "grep -q",
    "verification complete",
]:
    if token not in verify:
        raise SystemExit(f"30.10 verify script missing token: {token}")

print("search-knowledge-graph-sources-connectors-artifacts: OK")
