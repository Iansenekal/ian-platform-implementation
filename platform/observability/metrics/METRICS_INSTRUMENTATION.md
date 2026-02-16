# Metrics Instrumentation Guide

**Version:** 1.0  
**Last Updated:** 2026-02-13  
**Focus:** Prometheus-compatible metrics for observability, SLO tracking, and security monitoring  
**Strategy:** Metrics exposed at `/metrics` endpoint (Prometheus text format)

---

## Overview

Every service exposes Prometheus metrics at **`GET /metrics`** endpoint. Metrics include:
- **Request latency** (histogram)
- **Error rates** (counter)
- **Queue depths, cache hits** (gauge)
- **Security events** (counter)

Metrics enable:
- SLO tracking (availability, latency, error rate)
- Alerting on anomalies
- Capacity planning
- Incident response ("Which service was slow at 10:25am?")

---

## Metric Types

### Counter
Monotonically increasing value (never decreases). Use for counts: requests, errors, logins, disk writes.

```
# Example: HTTP requests by endpoint
http_requests_total{endpoint="/api/users",method="GET",status="200"} 1042
http_requests_total{endpoint="/api/users",method="GET",status="404"} 3
http_requests_total{endpoint="/api/users",method="POST",status="201"} 127
http_requests_total{endpoint="/api/users",method="POST",status="400"} 5
```

### Gauge
Value that can go up or down. Use for measurements: queue size, CPU usage, active connections, cache size.

```
# Example: Active connections
http_active_connections{service="auth-service"} 42
database_active_connections{pool="main"} 8
cache_entries{type="sessions"} 1024
```

### Histogram
Distribution of values (latencies). Prometheus automatically generates buckets + quantiles.

```
# Example: HTTP request latency
http_request_duration_seconds_bucket{le="0.01",endpoint="/api/users"} 50
http_request_duration_seconds_bucket{le="0.05",endpoint="/api/users"} 200
http_request_duration_seconds_bucket{le="0.1",endpoint="/api/users"} 350
http_request_duration_seconds_bucket{le="0.5",endpoint="/api/users"} 995
http_request_duration_seconds_bucket{le="1.0",endpoint="/api/users"} 1000
http_request_duration_seconds_bucket{le="+Inf",endpoint="/api/users"} 1042
http_request_duration_seconds_sum{endpoint="/api/users"} 245.67
http_request_duration_seconds_count{endpoint="/api/users"} 1042
```

### Summary
Alternative to histogram; includes quantile calculations on the client side (less storage, less accurate).

```
# Example: Custom processing latency
process_duration_seconds{quantile="0.5",operation="transcription"} 2.5
process_duration_seconds{quantile="0.95",operation="transcription"} 8.3
process_duration_seconds{quantile="0.99",operation="transcription"} 12.1
process_duration_seconds_sum{operation="transcription"} 10000
process_duration_seconds_count{operation="transcription"} 500
```

---

## Standard Metrics (All Services)

Every service must expose these:

### HTTP Request Metrics

```
http_requests_total{endpoint="/api/...",method="GET|POST|...",status="2xx|4xx|5xx"} N
http_request_duration_seconds{endpoint="/api/...",method="GET|POST|...",le="0.01|0.05|0.1|0.5|1.0|+Inf"} N
http_active_connections{service="my-service"} N
```

**Endpoint labels:** `/api/users`, `/api/documents`, `/health`, `/metrics` (all endpoints)  
**Method labels:** GET, POST, PUT, DELETE, PATCH  
**Status labels:** 200, 201, 204, 400, 401, 403, 404, 500, 503  

### Application Errors

```
app_errors_total{service="my-service",error_type="validation|database|timeout|auth"} N
app_warnings_total{service="my-service",warning_type="retry|degraded|threshold"} N
```

### Database Metrics (if applicable)

```
db_connection_pool_size{pool="main",status="active|idle"} N
db_query_duration_seconds{query_type="SELECT|INSERT|UPDATE|DELETE",table="users",le="0.01|0.1|1.0|+Inf"} N
db_errors_total{table="users",error_type="constraint|timeout|connection"} N
```

### Cache Metrics (if applicable)

```
cache_hits_total{cache_name="sessions",operation="get"} N
cache_misses_total{cache_name="sessions",operation="get"} N
cache_entries{cache_name="sessions",status="valid|expired"} N
cache_size_bytes{cache_name="sessions"} B
```

### Custom Service Metrics

Examples by component:

**Auth Service:**
```
auth_login_attempts_total{result="success|failure",mfa_required="true|false"} N
auth_token_issued_total{token_type="access|refresh"} N
auth_session_duration_seconds{quantile="0.5|0.95|0.99"} S
```

**Nextcloud/Documents:**
```
file_uploads_total{size_bucket="<1MB|1-10MB|10-100MB|>100MB"} N
file_download_bytes{endpoint="/documents"} B
share_operations_total{operation="create|revoke",recipient_type="user|group|public"} N
```

**Voice Transcription:**
```
transcription_jobs_total{status="success|failure|timeout"} N
transcription_duration_seconds{model="whisper-base|whisper-large",le="1|5|10|30|+Inf"} S
audio_bytes_processed_total{} B
```

**Search/Graph:**
```
search_queries_total{result="hit|miss"} N
search_query_duration_seconds{le="0.1|0.5|1.0|5.0|+Inf"} S
graph_nodes_indexed_total{node_type="document|user|event"} N
```

---

## Metric Naming Convention

```
<namespace>_<subsystem>_<name>_<unit>
```

**Examples:**
- `http_requests_total` (dimensionless count)
- `http_request_duration_seconds` (latency, unit=seconds)
- `cache_size_bytes` (size, unit=bytes)
- `transcription_jobs_total` (count)
- `error_rate_ratio` (dimensionless, range 0-1)

**Rules:**
- Use `_total` for counters (lifetime sum)
- Use `_duration_seconds` for timing
- Use `_bytes` for sizes
- Use lower_case_with_underscores
- Avoid plurals (counter is `errors_total`, not `error_count`)

---

## Implementation Examples

### Python (Prometheus Client)

```python
from prometheus_client import Counter, Gauge, Histogram, start_http_server
from flask import Flask, request, g
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

# Middleware to track request metrics
@app.before_request
def before_request():
    g.start_time = time.time()
    g.correlation_id = request.headers.get(
        'X-Correlation-ID',
        f"req-{uuid.uuid4().hex}"
    )

@app.after_request
def after_request(response):
    duration = time.time() - g.start_time
    endpoint = request.endpoint or request.path
    http_requests_total.labels(
        endpoint=endpoint,
        method=request.method,
        status=response.status_code
    ).inc()
    http_request_duration.labels(
        endpoint=endpoint,
        method=request.method
    ).observe(duration)
    return response

# App endpoint
@app.route('/api/login', methods=['POST'])
def login():
    mfa_required = True
    try:
        # ... authenticate ...
        auth_logins_total.labels(result='success', mfa_required=mfa_required).inc()
        return {"status": "success"}, 200
    except Exception as e:
        auth_logins_total.labels(result='failure', mfa_required=mfa_required).inc()
        return {"status": "error"}, 401

# Health check
@app.route('/health')
def health():
    return {"status": "healthy"}, 200

if __name__ == '__main__':
    # Start metrics HTTP server on port 8000
    start_http_server(8000)
    # App on port 5000
    app.run(port=5000)
```

**Test it:**
```bash
curl http://localhost:8000/metrics | grep http_
```

### Node.js (prom-client)

```javascript
const express = require('express');
const promClient = require('prom-client');
const { v4: uuidv4 } = require('uuid');

const app = express();

// Create metrics
const httpRequestsTotal = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['endpoint', 'method', 'status']
});

const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request latency',
  labelNames: ['endpoint', 'method'],
  buckets: [0.01, 0.05, 0.1, 0.5, 1.0, 5.0]
});

const authLoginsTotal = new promClient.Counter({
  name: 'auth_login_attempts_total',
  help: 'Login attempts',
  labelNames: ['result', 'mfa_required']
});

// Middleware to track metrics
app.use((req, res, next) => {
  req.startTime = Date.now();
  req.correlationId = req.headers['x-correlation-id'] || `req-${uuidv4()}`;
  
  const originalSend = res.send;
  res.send = function(data) {
    const duration = (Date.now() - req.startTime) / 1000;
    const endpoint = req.route?.path || req.path;
    
    httpRequestsTotal.labels(endpoint, req.method, res.statusCode).inc();
    httpRequestDuration.labels(endpoint, req.method).observe(duration);
    
    return originalSend.call(this, data);
  };
  
  next();
});

// Login endpoint
app.post('/api/login', (req, res) => {
  try {
    // ... authenticate ...
    authLoginsTotal.labels('success', 'true').inc();
    res.json({ status: 'success' });
  } catch (err) {
    authLoginsTotal.labels('failure', 'true').inc();
    res.status(401).json({ status: 'error' });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', promClient.register.contentType);
  res.end(await promClient.register.metrics());
});

app.listen(5000);
```

### Go

```go
package main

import (
	"net/http"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	httpRequestsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total HTTP requests",
		},
		[]string{"endpoint", "method", "status"},
	)

	httpRequestDuration = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "http_request_duration_seconds",
			Help:    "HTTP request latency",
			Buckets: []float64{0.01, 0.05, 0.1, 0.5, 1.0, 5.0},
		},
		[]string{"endpoint", "method"},
	)

	authLoginsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "auth_login_attempts_total",
			Help: "Login attempts",
		},
		[]string{"result", "mfa_required"},
	)
)

func init() {
	prometheus.MustRegister(httpRequestsTotal)
	prometheus.MustRegister(httpRequestDuration)
	prometheus.MustRegister(authLoginsTotal)
}

func middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next.ServeHTTP(w, r)
		duration := time.Since(start).Seconds()

		endpoint := r.URL.Path
		httpRequestsTotal.WithLabelValues(endpoint, r.Method, "200").Inc()
		httpRequestDuration.WithLabelValues(endpoint, r.Method).Observe(duration)
	})
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	// ... authenticate ...
	authLoginsTotal.WithLabelValues("success", "true").Inc()
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"status":"success"}`))
}

func main() {
	// Metrics endpoint
	http.Handle("/metrics", promhttp.Handler())

	// App endpoints
	http.Handle("/", middleware(http.HandlerFunc(loginHandler)))
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"healthy"}`))
	})

	http.ListenAndServe(":5000", nil)
}
```

---

## Prometheus Scrape Configuration

### Docker Compose Example

```yaml
version: '3'
services:
  auth-service:
    image: myregistry/auth-service:1.0.0
    ports:
      - "5000:5000"
    expose:
      - "8000"  # Metrics port
    labels:
      - "prometheus=true"
      - "prometheus_metrics_port=8000"

  nextcloud:
    image: nextcloud:latest
    ports:
      - "80:80"
    expose:
      - "9100"  # Node exporter

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'

volumes:
  prometheus_data:
```

### prometheus.yml

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    monitor: 'ian-platform'
    region: 'south-africa'
    environment: 'staging'

scrape_configs:
  # Auth Service
  - job_name: 'auth-service'
    static_configs:
      - targets: ['localhost:8000']
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
      - target_label: service
        replacement: 'auth-service'

  # Nextcloud (assuming Nextcloud Exporter runs on :9100)
  - job_name: 'nextcloud'
    static_configs:
      - targets: ['localhost:9100']
    relabel_configs:
      - target_label: service
        replacement: 'nextcloud'

  # Gateway/Reverse Proxy
  - job_name: 'gateway'
    static_configs:
      - targets: ['localhost:8001']
    relabel_configs:
      - target_label: service
        replacement: 'gateway'

  # Node Exporter (system metrics)
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
    relabel_configs:
      - target_label: service
        replacement: 'system'

  # Prometheus itself
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```

---

## Service-Level Objectives (SLOs)

SLOs define the acceptable performance levels. Use metrics to measure compliance.

### Standard SLOs (All Services)

| Objective | Target | Metric | Window |
|-----------|--------|--------|--------|
| **Availability** | 99.9% | `(requests with status 5xx / total requests) < 0.1%` | Monthly |
| **Latency (p95)** | <500ms | `http_request_duration_seconds{quantile="0.95"} < 0.5` | Monthly |
| **Latency (p99)** | <2s | `http_request_duration_seconds{quantile="0.99"} < 2.0` | Monthly |
| **Error Rate** | <1% | `(errors_total / requests_total) < 0.01` | Monthly |

### Service-Specific SLOs

**Auth Service:**
- Availability: 99.99% (higher due to POPIA compliance)
- Login latency (p95): <200ms
- MFA success rate: >99.9%

**Nextcloud (Document Manager):**
- Availability: 99.9%
- File upload latency (p95): <2s
- File download latency (p95): <1s

**Gateway:**
- Availability: 99.99% (upstream for all services)
- Request forwarding latency (p99): <100ms
- Token validation latency (p99): <50ms

**Transcription Service:**
- Availability: 99.5% (batch processing, lower SLO)
- Transcription job completion: >99%

### Error Budget

If SLO is 99.9% availability, monthly error budget is:

```
Total minutes/month: 43,200 (30 * 24 * 60)
Downtime budget: 43,200 * (1 - 0.999) = 43.2 minutes
```

Once error budget is consumed, **no new deployments** until next month (preserve availability).

---

## Alert Rules

Define alerts based on SLO violations:

```yaml
# prometheus-alerts.yml
groups:
  - name: slo_alerts
    interval: 30s
    rules:
      # High error rate
      - alert: HighErrorRate
        expr: rate(app_errors_total[5m]) > 0.01
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate in {{ $labels.service }}"
          runbook: "https://wiki.example.com/runbooks/high_error_rate"

      # Slow response times
      - alert: SlowResponseTime
        expr: histogram_quantile(0.95, http_request_duration_seconds) > 0.5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Slow responses from {{ $labels.service }}"

      # High latency percentile
      - alert: HighLatencyP99
        expr: histogram_quantile(0.99, http_request_duration_seconds) > 2.0
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "P99 latency high in {{ $labels.service }}"

      # Service down
      - alert: ServiceDown
        expr: up{job="auth-service"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "{{ $labels.service }} is down!"

      # Database connection pool exhausted
      - alert: DBConnectionPoolExhausted
        expr: db_connection_pool_size{status="active"} >= db_connection_pool_size{status="total"}
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "DB connection pool exhausted in {{ $labels.database }}"
```

---

## Example Prometheus Queries

### Service Health

```promql
# Requests per second (RPS)
rate(http_requests_total[1m])

# Error rate as percentage
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) * 100

# Availability (uptime)
up{job="auth-service"}

# Services with high error rates
sum(rate(app_errors_total[5m])) by (service) > 0.01
```

### Latency Analysis

```promql
# Average latency
avg(rate(http_request_duration_seconds_sum[5m])) / avg(rate(http_request_duration_seconds_count[5m]))

# P95 latency by endpoint
histogram_quantile(0.95, http_request_duration_seconds)

# P99 latency by service
histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m])) by (service)

# Slowest endpoints
topk(5, histogram_quantile(0.95, http_request_duration_seconds))
```

### Security Metrics

```promql
# Failed login attempts
rate(auth_login_attempts_total{result="failure"}[5m])

# MFA usage
rate(auth_login_attempts_total{mfa_required="true"}[1h])

# Unauthorized access attempts
rate(http_requests_total{status="401"}[5m]) + rate(http_requests_total{status="403"}[5m])
```

### Resource Monitoring

```promql
# Database connection pool usage
db_connection_pool_size{status="active"} / db_connection_pool_size{status="total"}

# Cache hit rate
rate(cache_hits_total[5m]) / (rate(cache_hits_total[5m]) + rate(cache_misses_total[5m]))

# Transcription average duration
avg(transcription_duration_seconds) by (model)
```

---

## Scraping Best Practices

### Frequency & Intervals

- **Scrape interval:** 15s (default, acceptable for most services)
- **Evaluation interval:** 15s (same as scrape interval)
- **Alert threshold:** Usually 5m (fire alert if condition holds for 5 minutes, avoid noise)

### Label Strategy

Good labels:
```
http_requests_total{endpoint="/api/users", method="GET", status="200", service="auth-service", region="sa"}
```

Bad labels (too many, unbounded):
```
http_requests_total{user_id="user-123", ip_address="192.0.2.1", ...}  # Cardinality explosion
```

**Rule:** Only add labels if they're known, fixed, and limited in count (<100 unique values per label).

### Retention & Storage

```yaml
global:
  scrape_interval: 15s
  # Keep raw data for 15 days; Prometheus will compress
  retention: 15d
```

For high-cardinality metrics (many labels), reduce retention to save disk space.

---

## Testing Metrics

### Verify Endpoint

```bash
# Curl metrics endpoint
curl http://localhost:8000/metrics | grep http_requests_total

# Filter specific metric
curl http://localhost:8000/metrics | grep '^http_request_duration_seconds_bucket'

# Check metric format
curl http://localhost:8000/metrics | head -20
# Should show comments starting with #
```

### Validate Scrape Config

```bash
# Run Prometheus in config-check mode
prometheus --config.file=prometheus.yml --syntax-only
# Output: "config OK"
```

### Test PromQL Query

```bash
# Access Prometheus UI on http://localhost:9090/graph
# Example query:
rate(http_requests_total[5m])

# Instant query via CLI
curl 'http://localhost:9090/api/v1/query?query=up'
```

---

## References

- [Prometheus Documentation](https://prometheus.io/docs/)
- [SDN Metrics (Prometheus Best Practices)](https://prometheus.io/docs/practices/naming/)
- [SRE Book: Monitoring Distributed Systems](https://sre.google/sre-book/monitoring-distributed-systems/)
- [EVENT_SCHEMA.md](../audit-events/EVENT_SCHEMA.md) — Audit events (complement metrics)
- [STRUCTURED_LOGGING.md](../logging/STRUCTURED_LOGGING.md) — Logs (complement metrics)

---

## Version History

- **1.0** (Feb 2026): Initial metrics instrumentation guide for Prometheus integration
