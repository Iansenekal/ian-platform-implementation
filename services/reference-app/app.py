from flask import Flask, request, g, jsonify
from prometheus_client import Counter, Histogram, start_http_server
import time
import uuid

app = Flask(__name__)

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
    try:
        auth_logins_total.labels(result='success', mfa_required='true').inc()
        return jsonify({'status': 'success'}), 200
    except Exception:
        auth_logins_total.labels(result='failure', mfa_required='true').inc()
        return jsonify({'status': 'error'}), 401

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    # Expose metrics on port 8000
    start_http_server(8000)
    app.run(host='0.0.0.0', port=5000)
