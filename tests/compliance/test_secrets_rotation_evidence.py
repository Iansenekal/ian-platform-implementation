from pathlib import Path
import json
import subprocess
import tempfile
import unittest


class SecretsRotationEvidenceTests(unittest.TestCase):
    def test_evidence_generator_outputs_json_and_markdown(self):
        with tempfile.TemporaryDirectory() as tmp_dir:
            subprocess.run(
                [
                    "python3",
                    "scripts/compliance/generate_secrets_rotation_evidence.py",
                    "--output-dir",
                    tmp_dir,
                ],
                check=True,
            )

            json_path = Path(tmp_dir) / "secrets-rotation-evidence.json"
            md_path = Path(tmp_dir) / "secrets-rotation-evidence.md"
            checksums_path = Path(tmp_dir) / "checksums.sha256"
            statement_path = Path(tmp_dir) / "attestation-statement.json"

            self.assertTrue(json_path.is_file())
            self.assertTrue(md_path.is_file())
            self.assertTrue(checksums_path.is_file())
            self.assertTrue(statement_path.is_file())

            evidence = json.loads(json_path.read_text(encoding="utf-8"))
            self.assertEqual(evidence.get("evidence_type"), "secrets_rotation")
            self.assertIn("generated_at_utc", evidence)
            self.assertTrue(evidence["scan_result"]["passed"])
            self.assertGreaterEqual(len(evidence["controls_snapshot"]), 4)

            checksums_text = checksums_path.read_text(encoding="utf-8")
            self.assertIn("secrets-rotation-evidence.json", checksums_text)
            self.assertIn("secrets-rotation-evidence.md", checksums_text)

            statement = json.loads(statement_path.read_text(encoding="utf-8"))
            self.assertEqual(statement.get("_type"), "https://in-toto.io/Statement/v1")
            self.assertEqual(statement.get("predicateType"), "https://slsa.dev/provenance/v1")
            self.assertGreaterEqual(len(statement.get("subject", [])), 2)
