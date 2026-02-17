from pathlib import Path
import sys
import unittest


REFERENCE_APP_DIR = Path(__file__).resolve().parents[2] / "services" / "reference-app"
sys.path.insert(0, str(REFERENCE_APP_DIR))

import app as reference_app  # noqa: E402


class ReferenceAppTests(unittest.TestCase):
    def setUp(self):
        self.client = reference_app.app.test_client()

    def test_health_endpoint_returns_healthy_and_correlation_id(self):
        response = self.client.get("/health")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_json(), {"status": "healthy"})
        self.assertTrue(response.headers["X-Correlation-ID"].startswith("req-"))

    def test_correlation_id_is_echoed_when_provided(self):
        correlation_id = "req-test-123"
        response = self.client.get("/health", headers={"X-Correlation-ID": correlation_id})

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.headers["X-Correlation-ID"], correlation_id)

    def test_login_success_and_failure_paths(self):
        success_response = self.client.post("/api/login", json={"password": "demo-password"})
        failure_response = self.client.post("/api/login", json={"password": "invalid"})

        self.assertEqual(success_response.status_code, 200)
        self.assertEqual(success_response.get_json(), {"status": "success"})
        self.assertEqual(failure_response.status_code, 401)
        self.assertEqual(failure_response.get_json(), {"status": "error"})

    def test_metrics_endpoint_exposes_prometheus_metrics(self):
        self.client.get("/health")
        self.client.post("/api/login", json={"password": "demo-password"})

        response = self.client.get("/metrics")
        body = response.get_data(as_text=True)

        self.assertEqual(response.status_code, 200)
        self.assertIn("text/plain", response.headers["Content-Type"])
        self.assertIn("http_requests_total", body)
        self.assertIn("http_request_duration_seconds_bucket", body)
        self.assertIn("auth_login_attempts_total", body)
