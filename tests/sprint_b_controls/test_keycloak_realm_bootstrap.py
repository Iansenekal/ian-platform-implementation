import os
import subprocess
import unittest


class KeycloakRealmBootstrapSmokeTests(unittest.TestCase):
    @unittest.skipUnless(os.getenv("RUN_KEYCLOAK_SMOKE") == "1", "Set RUN_KEYCLOAK_SMOKE=1 to run Docker smoke test")
    def test_keycloak_realm_bootstrap_smoke(self):
        subprocess.run(["bash", "scripts/smoke/keycloak_realm_bootstrap.sh"], check=True)
