import os
import subprocess
import unittest


class GatewayJwtValidationSmokeTests(unittest.TestCase):
    @unittest.skipUnless(os.getenv("RUN_GATEWAY_JWT_SMOKE") == "1", "Set RUN_GATEWAY_JWT_SMOKE=1 to run Docker smoke test")
    def test_gateway_jwt_validation_smoke(self):
        subprocess.run(["bash", "scripts/smoke/gateway_jwt_validation.sh"], check=True)
