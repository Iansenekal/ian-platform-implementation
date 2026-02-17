from pathlib import Path
import importlib
import subprocess
import unittest


class SprintBControlsTests(unittest.TestCase):
    def test_keycloak_and_gateway_scaffolds_exist(self):
        self.assertTrue(Path("infrastructure/keycloak/docker-compose.yml").is_file())
        self.assertTrue(Path("infrastructure/keycloak/realm/realm-export.json").is_file())
        self.assertTrue(Path("infrastructure/gateway/docker-compose.yml").is_file())
        self.assertTrue(Path("infrastructure/gateway/app.py").is_file())

    def test_secrets_controls_exist_and_scan_runs(self):
        self.assertTrue(Path("tools/pre-commit-secrets-check.sh").is_file())
        subprocess.run(["bash", "tools/pre-commit-secrets-check.sh", "--ci"], check=True)

    def test_reference_app_audit_event_shape(self):
        mod = importlib.import_module("reference_app.test_app").reference_app

        with mod.app.test_request_context("/api/login", method="POST"):
            mod.g.correlation_id = "req-test"
            event = mod.build_audit_event(
                event_type="authentication.login_success",
                action="login",
                outcome="success",
                actor_id="alice",
                target_id="reference-app",
                outcome_reason="Credentials accepted",
            )

        required_keys = [
            "timestamp",
            "timestamp_tz",
            "event_id",
            "correlation_id",
            "source_system",
            "event_type",
            "event_category",
            "actor",
            "target",
            "action",
            "outcome",
            "severity",
            "metadata",
        ]
        for key in required_keys:
            self.assertIn(key, event)
