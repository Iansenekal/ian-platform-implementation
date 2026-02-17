import json
from pathlib import Path
import importlib.util
import sys
import sysconfig
import time
import uuid

# Ensure stdlib `platform` is loaded, not the repo's top-level `platform/` directory.
_stdlib_platform_path = Path(sysconfig.get_path("stdlib")) / "platform.py"
_platform_spec = importlib.util.spec_from_file_location("platform", _stdlib_platform_path)
_platform_module = importlib.util.module_from_spec(_platform_spec)
_platform_spec.loader.exec_module(_platform_module)
sys.modules["platform"] = _platform_module

from flask import Flask, Response, g, jsonify, request
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

app = Flask(__name__)


def _utc_iso_timestamp():
    return time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())


def emit_structured_log(level, message, **fields):
    entry = {
        "timestamp": _utc_iso_timestamp(),
        "timestamp_tz": "Africa/Johannesburg",
        "level": level,
        "service": "reference-app",
        "correlation_id": getattr(g, "correlation_id", "unknown"),
        "message": message,
    }
    entry.update(fields)
    print(json.dumps(entry), flush=True)


def build_audit_event(event_type, action, outcome, actor_id, target_id, outcome_reason):
    return {
        "timestamp": _utc_iso_timestamp(),
        "timestamp_tz": "Africa/Johannesburg",
        "event_id": str(uuid.uuid4()),
        "correlation_id": getattr(g, "correlation_id", "unknown"),
        "source_system": "reference-app",
        "event_type": event_type,
        "event_category": event_type.split(".")[0],
        "actor": {
            "id": actor_id,
            "type": "human",
            "name": actor_id,
            "source_ip": request.remote_addr or "unknown",
        },
        "target": {
            "type": "application",
            "id": target_id,
            "name": "reference-app",
            "resource_path": request.path,
        },
        "action": action,
        "outcome": outcome,
        "outcome_reason": outcome_reason,
        "severity": "info" if outcome == "success" else "warning",
        "metadata": {
            "method": request.method,
        },
    }

# Metrics
http_requests_total = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['endpoint', 'method', 'status']
)

http_request_duration = Histogram(
    'http_request_duration_seconds',
    'HTTP request latency',
    ['endpoint', 'method'],
    buckets=[0.01, 0.05, 0.1, 0.5, 1.0, 5.0]
)

auth_logins_total = Counter(
    'auth_login_attempts_total',
    'Login attempts',
    ['result', 'mfa_required']
)

@app.before_request
def before_request():
    g.start_time = time.time()
    g.correlation_id = request.headers.get('X-Correlation-ID', f"req-{uuid.uuid4().hex}")

@app.after_request
def after_request(response):
    duration = time.time() - g.start_time
    endpoint = request.endpoint or request.path
    http_requests_total.labels(endpoint=endpoint, method=request.method, status=response.status_code).inc()
    http_request_duration.labels(endpoint=endpoint, method=request.method).observe(duration)
    response.headers['X-Correlation-ID'] = g.correlation_id
    return response

@app.route('/api/login', methods=['POST'])
def login():
    payload = request.get_json(silent=True) or {}
    password = payload.get('password')
    username = payload.get('username', 'unknown-user')

    # Placeholder auth flow for reference-app instrumentation demos.
    if password == 'demo-password':
        auth_logins_total.labels(result='success', mfa_required='true').inc()
        emit_structured_log("info", "Login success", user_id=username, action="login", result="success")
        print(json.dumps(build_audit_event(
            "authentication.login_success",
            "login",
            "success",
            username,
            "reference-app",
            "Credentials accepted",
        )), flush=True)
        return jsonify({'status': 'success'}), 200

    auth_logins_total.labels(result='failure', mfa_required='true').inc()
    emit_structured_log("warning", "Login failure", user_id=username, action="login", result="failure")
    print(json.dumps(build_audit_event(
        "authentication.login_failure",
        "login",
        "failure",
        username,
        "reference-app",
        "Invalid credentials",
    )), flush=True)
    return jsonify({'status': 'error'}), 401

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

@app.route('/metrics')
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
