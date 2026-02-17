#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/30-Search-KnowledgeGraph/30.00-Overview.md",
    "infrastructure/search-graph/README.md",
    "infrastructure/search-graph/30.00-overview-inputs.env.example",
    "infrastructure/search-graph/30.00-source-catalog.template.yml",
    "infrastructure/search-graph/30.00-acl-enforcement-policy.yml",
    "infrastructure/search-graph/30.00-overview-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"30.00 search/graph overview artifacts missing: {', '.join(missing)}")

doc = Path("docs/30-Search-KnowledgeGraph/30.00-Overview.md").read_text(encoding="utf-8")
for token in [
    "OpenSearch",
    "Knowledge Graph",
    "mind-map",
    "ACL",
    "Anti-leakage",
    "POPIA",
    "Nextcloud",
]:
    if token not in doc:
        raise SystemExit(f"30.00 doc missing token: {token}")

inputs = Path("infrastructure/search-graph/30.00-overview-inputs.env.example").read_text(encoding="utf-8")
for token in ["OPENSEARCH_URL=", "TIKA_URL=", "GROUP_CLAIM_NAME=groups", "PROJECT_CODE_PATH_RULE=", "MINDMAP_ENABLED="]:
    if token not in inputs:
        raise SystemExit(f"30.00 inputs template missing token: {token}")

catalog = Path("infrastructure/search-graph/30.00-source-catalog.template.yml").read_text(encoding="utf-8")
for token in ["type: nextcloud", "type: smb", "type: m365", "allowed_file_types:", "max_file_size_mb:"]:
    if token not in catalog:
        raise SystemExit(f"30.00 source catalog missing token: {token}")

policy = Path("infrastructure/search-graph/30.00-acl-enforcement-policy.yml").read_text(encoding="utf-8")
for token in ["index_time_acl_tagging: true", "query_time_filtering: true", "hide_unauthorized_existence: true", "group_claim_name: groups"]:
    if token not in policy:
        raise SystemExit(f"30.00 acl policy missing token: {token}")

verify = Path("infrastructure/search-graph/30.00-overview-verify.sh").read_text(encoding="utf-8")
for token in ["DOC_FILE", "INPUTS_FILE", "CATALOG_FILE", "ACL_POLICY_FILE", "grep -q", "verification complete"]:
    if token not in verify:
        raise SystemExit(f"30.00 verify script missing token: {token}")

print("search-knowledge-graph-overview-artifacts: OK")
