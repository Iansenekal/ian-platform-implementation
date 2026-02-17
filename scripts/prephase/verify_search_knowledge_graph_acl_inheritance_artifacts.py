#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/30-Search-KnowledgeGraph/30.15-ACL-and-Permissions-Inheritance.md",
    "infrastructure/search-graph/README.md",
    "infrastructure/search-graph/30.15-acl-enforcement-policy.yml",
    "infrastructure/search-graph/30.15-principal-mapping.template.yml",
    "infrastructure/search-graph/30.15-acl-regression-checklist.template.md",
    "infrastructure/search-graph/30.15-acl-inputs.env.example",
    "infrastructure/search-graph/30.15-acl-inheritance-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"30.15 search/graph acl-inheritance artifacts missing: {', '.join(missing)}")

doc = Path("docs/30-Search-KnowledgeGraph/30.15-ACL-and-Permissions-Inheritance.md").read_text(encoding="utf-8")
for token in [
    "ACL",
    "deny-by-default",
    "query-time",
    "Mind-Map",
    "drift",
    "Verification",
]:
    if token not in doc:
        raise SystemExit(f"30.15 doc missing token: {token}")

policy = Path("infrastructure/search-graph/30.15-acl-enforcement-policy.yml").read_text(encoding="utf-8")
for token in [
    "deny_by_default: true",
    "no_acl_no_index: true",
    "query_time_acl_filtering: true",
    "both_endpoints_required: true",
    "no_placeholder_nodes: true",
]:
    if token not in policy:
        raise SystemExit(f"30.15 acl policy missing token: {token}")

mapping = Path("infrastructure/search-graph/30.15-principal-mapping.template.yml").read_text(encoding="utf-8")
for token in [
    "groups_claim_name: groups",
    "canonical_project_pattern",
    "external_guest_indexing_allowed: false",
]:
    if token not in mapping:
        raise SystemExit(f"30.15 principal mapping missing token: {token}")

checklist = Path("infrastructure/search-graph/30.15-acl-regression-checklist.template.md").read_text(encoding="utf-8")
for token in [
    "No-group user returns zero results",
    "safe fields only",
    "no placeholder nodes",
    "Evidence bundle",
]:
    if token not in checklist:
        raise SystemExit(f"30.15 acl regression checklist missing token: {token}")

inputs = Path("infrastructure/search-graph/30.15-acl-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "GROUPS_CLAIM_NAME=groups",
    "DENY_BY_DEFAULT=true",
    "NO_ACL_NO_INDEX=true",
    "GRAPH_NO_PLACEHOLDERS=true",
    "DRIFT_ALERT_THRESHOLD_PERCENT=",
]:
    if token not in inputs:
        raise SystemExit(f"30.15 inputs template missing token: {token}")

verify = Path("infrastructure/search-graph/30.15-acl-inheritance-verify.sh").read_text(encoding="utf-8")
for token in [
    "DOC_FILE",
    "POLICY_FILE",
    "MAPPING_FILE",
    "CHECKLIST_FILE",
    "INPUTS_FILE",
    "grep -q",
    "verification complete",
]:
    if token not in verify:
        raise SystemExit(f"30.15 verify script missing token: {token}")

print("search-knowledge-graph-acl-inheritance-artifacts: OK")
