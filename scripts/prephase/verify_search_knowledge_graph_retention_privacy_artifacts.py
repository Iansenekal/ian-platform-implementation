#!/usr/bin/env python3
from pathlib import Path

required_files = [
    "docs/30-Search-KnowledgeGraph/30.70-Retention-Privacy-Controls.md",
    "infrastructure/search-graph/README.md",
    "infrastructure/search-graph/30.70-retention-policy.yml",
    "infrastructure/search-graph/30.70-content-class-retention-matrix.csv",
    "infrastructure/search-graph/30.70-deletion-propagation-sla.yml",
    "infrastructure/search-graph/30.70-privacy-regression-checklist.template.md",
    "infrastructure/search-graph/30.70-retention-inputs.env.example",
    "infrastructure/search-graph/30.70-retention-privacy-verify.sh",
]

missing = [p for p in required_files if not Path(p).is_file()]
if missing:
    raise SystemExit(f"30.70 search/graph retention-privacy artifacts missing: {', '.join(missing)}")

doc = Path("docs/30-Search-KnowledgeGraph/30.70-Retention-Privacy-Controls.md").read_text(encoding="utf-8")
for token in [
    "POPIA",
    "metadata-first",
    "Retention",
    "Deletion Propagation",
    "Sensitive",
    "Verification Checklist",
]:
    if token not in doc:
        raise SystemExit(f"30.70 doc missing token: {token}")

policy = Path("infrastructure/search-graph/30.70-retention-policy.yml").read_text(encoding="utf-8")
for token in [
    "RC-01",
    "RC-02",
    "RC-03",
    "RC-04",
    "metadata_first: true",
    "audit_summary_required: true",
]:
    if token not in policy:
        raise SystemExit(f"30.70 retention policy missing token: {token}")

matrix = Path("infrastructure/search-graph/30.70-content-class-retention-matrix.csv").read_text(encoding="utf-8")
for token in [
    "content_class,default_indexing,retention_class,notes",
    "contracts_legal_privileged",
    "hr_personnel",
    "personal_onedrive",
]:
    if token not in matrix:
        raise SystemExit(f"30.70 retention matrix missing token: {token}")

sla = Path("infrastructure/search-graph/30.70-deletion-propagation-sla.yml").read_text(encoding="utf-8")
for token in [
    "source_deleted",
    "acl_narrowed",
    "moved_out_of_scope",
    "purge_graph_nodes_edges: true",
    "record_audit_event: true",
]:
    if token not in sla:
        raise SystemExit(f"30.70 deletion SLA config missing token: {token}")

checklist = Path("infrastructure/search-graph/30.70-privacy-regression-checklist.template.md").read_text(encoding="utf-8")
for token in [
    "Metadata-only default enforced",
    "Deletion propagation SLA test",
    "Person/entity enrichment remains disabled",
    "Evidence stored",
]:
    if token not in checklist:
        raise SystemExit(f"30.70 regression checklist missing token: {token}")

inputs = Path("infrastructure/search-graph/30.70-retention-inputs.env.example").read_text(encoding="utf-8")
for token in [
    "DEFAULT_INDEXING_MODE=metadata-only",
    "RETENTION_RC01_DAYS=",
    "DELETION_PROPAGATION_SLA_HOURS=",
    "QUERY_LOGGING_LEVEL=",
    "APPROVER=DPO+Security",
]:
    if token not in inputs:
        raise SystemExit(f"30.70 inputs template missing token: {token}")

verify = Path("infrastructure/search-graph/30.70-retention-privacy-verify.sh").read_text(encoding="utf-8")
for token in [
    "DOC_FILE",
    "POLICY_FILE",
    "MATRIX_FILE",
    "SLA_FILE",
    "CHECKLIST_FILE",
    "INPUTS_FILE",
    "grep -q",
    "verification complete",
]:
    if token not in verify:
        raise SystemExit(f"30.70 verify script missing token: {token}")

print("search-knowledge-graph-retention-privacy-artifacts: OK")
