from pathlib import Path
import unittest


class WorkflowDocsTests(unittest.TestCase):
    def test_traceability_and_backlog_exist(self):
        self.assertTrue(Path("docs/WORKFLOW_TRACEABILITY.md").is_file())
        self.assertTrue(Path("docs/IMPLEMENTATION_BACKLOG.md").is_file())

    def test_traceability_contains_major_ranges(self):
        content = Path("docs/WORKFLOW_TRACEABILITY.md").read_text(encoding="utf-8")
        for token in ["00-09", "10-29", "30-59", "60-79", "80-99"]:
            self.assertIn(token, content)
