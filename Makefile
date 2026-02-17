PYTHON ?= $(if $(wildcard .venv/bin/python),.venv/bin/python,python3)
PIP ?= $(PYTHON) -m pip

.PHONY: install-dev lint build test verify smoke-keycloak smoke-gateway-jwt evidence-secrets-rotation

install-dev:
	$(PYTHON) -m ensurepip --upgrade
	$(PIP) install -r services/reference-app/requirements.txt

lint:
	$(PYTHON) -m compileall -q services tests scripts
	bash -n tools/pre-commit-secrets-check.sh
	bash -n scripts/prephase/verify_artifact_presence.sh
	bash -n infrastructure/audit-logging/03.30-audit-verify.sh
	bash -n infrastructure/keycloak/04.20-auth-modes-verify.sh
	bash -n infrastructure/keycloak/04.40-rbac-groups-verify.sh
	bash -n infrastructure/gateway/04.60-sso-integration-verify.sh
	bash -n infrastructure/keycloak/11.10-idp-ports-verify.sh
	bash -n infrastructure/keycloak/11.40-ad-ldaps-verify.sh
	bash -n infrastructure/keycloak/11.50-local-users-verify.sh
	bash -n infrastructure/keycloak/11.60-mfa-verify.sh
	bash -n infrastructure/keycloak/11.70-group-role-mapping-verify.sh
	bash -n infrastructure/gateway/20.20-tls-verify.sh
	bash -n infrastructure/gateway/20.30-ui-sso-verify.sh
	bash -n infrastructure/gateway/10.40-token-validation-verify.sh
	bash -n infrastructure/gateway/10.50-rbac-verify.sh
	bash -n infrastructure/gateway/10.80-health-watchdog-verify.sh
	bash -n infrastructure/nextcloud/21.00-overview-verify.sh
	bash -n infrastructure/nextcloud/21.30-auth-options-verify.sh
	bash -n infrastructure/nextcloud/21.35-permissions-verify.sh
	bash -n infrastructure/nextcloud/21.36-group-naming-verify.sh
	bash -n infrastructure/nextcloud/21.37-project-acl-verify.sh
	bash -n infrastructure/nextcloud/21.45-audit-verify.sh
	bash -n infrastructure/nextcloud/21.80-lifecycle-workflow-verify.sh
	bash -n infrastructure/nextcloud/21.81-esign-options-verify.sh
	bash -n infrastructure/search-graph/30.00-overview-verify.sh
	bash -n infrastructure/search-graph/30.10-connector-verify.sh
	bash -n infrastructure/search-graph/30.15-acl-inheritance-verify.sh
	bash -n infrastructure/search-graph/30.70-retention-privacy-verify.sh
	bash -n infrastructure/secrets-standard/03.20-init-stack-layout.sh
	bash -n infrastructure/secrets-standard/03.20-generate-secret-file.sh
	bash -n infrastructure/secrets-standard/03.20-verify-secrets-standard.sh
	bash -n infrastructure/firewall/apply-ufw-frontend.sh
	bash -n infrastructure/firewall/apply-ufw-backend.sh
	bash -n infrastructure/firewall/verify-ufw.sh
	bash -n infrastructure/vm-provisioning/hardening/base-hardening.sh
	bash -n infrastructure/proxmox/networking/render-interfaces.sh
	bash -n infrastructure/proxmox/networking/81.50-network-verify.sh
	bash -n infrastructure/proxmox/networking/81.60-network-verification.sh
	bash -n infrastructure/proxmox/storage/81.70-storage-decision-gate.sh
	bash -n infrastructure/proxmox/storage/81.80-storage-verify.sh
	bash -n infrastructure/proxmox/storage/81.90-storage-verification.sh
	bash -n infrastructure/vm-provisioning/install/81.110-ai-data01-verify.sh
	bash -n infrastructure/vm-provisioning/install/81.120-ai-frontend01-verify.sh
	bash -n infrastructure/vm-provisioning/hardening/verify-hardening.sh
	bash -n infrastructure/vm-provisioning/access/provision-admin-access.sh
	bash -n infrastructure/vm-provisioning/access/verify-admin-access.sh
	bash -n infrastructure/vm-provisioning/verification/81.190-vm-provisioning-gate.sh
	bash -n infrastructure/ollama-gpu/82.10-bios-precheck-gate.sh
	bash -n infrastructure/ollama-gpu/82.30-hardening-apply.sh
	bash -n infrastructure/ollama-gpu/82.30-hardening-verify.sh
	bash -n infrastructure/ollama-gpu/82.40-ollama-install-apply.sh
	bash -n infrastructure/ollama-gpu/82.40-ollama-install-verify.sh
	bash -n infrastructure/ollama-gpu/82.50-allowlist-enforced-pull.sh
	bash -n infrastructure/ollama-gpu/82.50-allowlist-audit.sh
	bash -n infrastructure/ollama-gpu/82.60-lan-allowlist-apply.sh
	bash -n infrastructure/ollama-gpu/82.60-lan-allowlist-verify.sh
	bash -n infrastructure/ollama-gpu/82.80-verification-run.sh
	bash -n infrastructure/prephase/tests/83.00-end-to-end-connectivity.sh
	bash -n infrastructure/prephase/tests/83.10-dns-resolution-tests.sh
	bash -n infrastructure/prephase/tests/83.20-security-smoke-tests.sh
	bash -n infrastructure/prephase/tests/83.30-go-live-gate-report.sh
	$(PYTHON) scripts/validate/validate_configs.py

build:
	$(PYTHON) -m py_compile services/reference-app/app.py

test:
	$(PYTHON) -m unittest discover -s tests -p "test_*.py" -v

verify:
	bash scripts/prephase/verify_artifact_presence.sh
	$(PYTHON) scripts/prephase/verify_audit_logging_artifacts.py
	$(PYTHON) scripts/prephase/verify_auth_modes_artifacts.py
	$(PYTHON) scripts/prephase/verify_break_glass_recovery_artifacts.py
	$(PYTHON) scripts/prephase/verify_rbac_role_model_artifacts.py
	$(PYTHON) scripts/prephase/verify_sso_integration_matrix_artifacts.py
	$(PYTHON) scripts/prephase/verify_mfa_policy_artifacts.py
	$(PYTHON) scripts/prephase/verify_identity_provider_ad_ldaps_artifacts.py
	$(PYTHON) scripts/prephase/verify_identity_provider_local_users_artifacts.py
	$(PYTHON) scripts/prephase/verify_identity_provider_mfa_artifacts.py
	$(PYTHON) scripts/prephase/verify_identity_provider_group_role_mapping_artifacts.py
	$(PYTHON) scripts/prephase/verify_frontend_internal_tls_artifacts.py
	$(PYTHON) scripts/prephase/verify_ui_sso_flow_artifacts.py
	$(PYTHON) scripts/prephase/verify_gateway_token_validation_artifacts.py
	$(PYTHON) scripts/prephase/verify_gateway_rbac_authorization_artifacts.py
	$(PYTHON) scripts/prephase/verify_gateway_healthchecks_watchdog_artifacts.py
	$(PYTHON) scripts/prephase/verify_nextcloud_overview_artifacts.py
	$(PYTHON) scripts/prephase/verify_nextcloud_auth_options_artifacts.py
	$(PYTHON) scripts/prephase/verify_nextcloud_permissions_model_artifacts.py
	$(PYTHON) scripts/prephase/verify_nextcloud_group_naming_artifacts.py
	$(PYTHON) scripts/prephase/verify_nextcloud_project_acl_blueprint_artifacts.py
	$(PYTHON) scripts/prephase/verify_nextcloud_audit_logging_artifacts.py
	$(PYTHON) scripts/prephase/verify_nextcloud_document_lifecycle_workflow_artifacts.py
	$(PYTHON) scripts/prephase/verify_nextcloud_esign_options_artifacts.py
	$(PYTHON) scripts/prephase/verify_search_knowledge_graph_overview_artifacts.py
	$(PYTHON) scripts/prephase/verify_search_knowledge_graph_sources_connectors_artifacts.py
	$(PYTHON) scripts/prephase/verify_search_knowledge_graph_acl_inheritance_artifacts.py
	$(PYTHON) scripts/prephase/verify_search_knowledge_graph_retention_privacy_artifacts.py
	$(PYTHON) scripts/prephase/verify_identity_provider_overview_artifacts.py
	$(PYTHON) scripts/prephase/verify_identity_provider_ports_boundaries_artifacts.py
	$(PYTHON) scripts/prephase/verify_monitoring_audit_retention_artifacts.py
	$(PYTHON) scripts/prephase/verify_secrets_standard_artifacts.py
	$(PYTHON) scripts/prephase/verify_ufw_policy_artifacts.py
	$(PYTHON) scripts/prephase/verify_network_plan.py
	$(PYTHON) scripts/prephase/verify_storage_plan.py
	$(PYTHON) scripts/prephase/verify_vm_blueprints.py
	$(PYTHON) scripts/prephase/verify_vm_install_artifacts.py
	$(PYTHON) scripts/prephase/verify_vm_hardening_artifacts.py
	$(PYTHON) scripts/prephase/verify_vm_access_artifacts.py
	$(PYTHON) scripts/prephase/verify_vm_provisioning_gate_artifacts.py
	$(PYTHON) scripts/prephase/verify_llm_pointer_profile.py
	$(PYTHON) scripts/prephase/verify_llm_bios_precheck_artifacts.py
	$(PYTHON) scripts/prephase/verify_llm_hardening_artifacts.py
	$(PYTHON) scripts/prephase/verify_llm_ollama_install_artifacts.py
	$(PYTHON) scripts/prephase/verify_llm_allowlist_policy_artifacts.py
	$(PYTHON) scripts/prephase/verify_llm_lan_allowlist_artifacts.py
	$(PYTHON) scripts/prephase/verify_llm_verification_checklist_artifacts.py
	$(PYTHON) scripts/prephase/verify_llm_client_rollout_variables_artifacts.py
	$(PYTHON) scripts/prephase/verify_prephase_connectivity_artifacts.py
	$(PYTHON) scripts/prephase/verify_prephase_dns_artifacts.py
	$(PYTHON) scripts/prephase/verify_prephase_security_smoke_artifacts.py
	$(PYTHON) scripts/prephase/verify_prebootstrap_go_live_gate_artifacts.py
	$(PYTHON) scripts/validate/validate_configs.py
	bash tools/pre-commit-secrets-check.sh --ci

smoke-keycloak:
	RUN_KEYCLOAK_SMOKE=1 $(PYTHON) -m unittest -v tests.sprint_b_controls.test_keycloak_realm_bootstrap

smoke-gateway-jwt:
	RUN_GATEWAY_JWT_SMOKE=1 $(PYTHON) -m unittest -v tests.sprint_b_controls.test_gateway_jwt_validation

evidence-secrets-rotation:
	$(PYTHON) scripts/compliance/generate_secrets_rotation_evidence.py --output-dir artifacts/secrets-rotation
