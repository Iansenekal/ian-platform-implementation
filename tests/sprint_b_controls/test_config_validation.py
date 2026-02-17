import subprocess
import unittest


class ConfigValidationTests(unittest.TestCase):
    def test_config_validation_script(self):
        subprocess.run(["python3", "scripts/validate/validate_configs.py"], check=True)
