# Correlation ID Pattern

**Version:** 1.0  
**Last Updated:** 2026-02-13  
**Timezone:** Africa/Johannesburg (UTC+2)

---

## Overview

A **correlation ID** (also called request ID, trace ID, or request correlation ID) uniquely identifies a request flow across all services, systems, and components as it propagates through the platform. It enables:

- **Request tracing:** Follow a single user action (e.g., login, file upload) across multiple services
- **Incident forensics:** Link all events related to a security event or outage
- **Performance debugging:** Correlate slow operations across service boundaries
- **Compliance auditing:** Group related audit events for investigation

---

## Requirements

### Format

- **Length:** 32–64 alphanumeric characters (UUID or custom)
- **Characters:** `[A-Za-z0-9\-_]` (URL-safe, no spaces or special chars)
- **Uniqueness:** Must be globally unique within a 24-hour window
- **Immutability:** Once assigned, must not change during the request lifetime

### Examples of Valid Correlation IDs

- UUID v4: `550e8400-e29b-41d4-a716-446655440000`
- Timestamp-based: `req-1707805543123-abc123def456`
- Prefixed UUID: `req-550e8400-e29b-41d4-a716-446655440000`
- Custom: `login-alice-2026-02-13-10-25-43-xyz`

### Examples of Invalid Correlation IDs

- ❌ Too short: `abc`
- ❌ Contains spaces: `request id 123`
- ❌ Special chars: `correlation!id#123`
- ❌ Non-ASCII: `correlation-①②③`

---

## Generation Rules

### At Entry Points

Entry points are the first boundary where a request enters the platform:
- **HTTP request** to a service (incoming from client or another service)
- **Message consumed** from a queue
- **Scheduled job** triggered by cron or scheduler
- **Internal API call** initiated by a batch process

**Rule:** If the correlation ID is NOT present in the incoming request, **generate a new one**.

### Generation Strategy

Choose ONE of the following:

#### Option A: UUID v4 (Recommended)

Generate a random UUID v4 and optionally prefix it.

```
550e8400-e29b-41d4-a716-446655440000
req-550e8400-e29b-41d4-a716-446655440000
```

**Pros:** Standard, collision-free, ~36–40 chars  
**Cons:** Not sortable by time

**Libraries:**
- Python: `import uuid; uuid.uuid4().hex` → `550e8400e29b41d4a716446655440000`
- Node.js: `const { v4: uuidv4 } = require('uuid'); uuidv4()` → `550e8400-e29b-41d4-a716-446655440000`
- Go: `import "github.com/google/uuid"; uuid.New().String()`
- Java: `UUID.randomUUID().toString()`

#### Option B: Timestamp + Random

More human-readable and sortable by time.

```
req-1707805543123-abc123def456
          ↑ milliseconds since epoch
```

Format: `<prefix>-<timestamp_ms>-<random_suffix>`

**Pros:** Human-readable, sortable, ~40 chars  
**Cons:** Slightly less uniform randomness

**Libraries:**
- Python: `f"req-{int(time.time() * 1000)}-{uuid.uuid4().hex[:12]}"`
- Node.js: `const ms = Date.now(); const rand = crypto.randomBytes(6).toString('hex'); \`req-${ms}-${rand}\``
- Go: `fmt.Sprintf("req-%d-%s", time.Now().UnixMilli(), rand.String(6))`

#### Option C: Service-Namespaced

Include the originating service for easy filtering.

```
svc-gateway-550e8400-e29b-41d4-a716-446655440000
   ↑ service prefix
```

**Pros:** Easy to identify originator  
**Cons:** Additional length (~50–60 chars)

---

## Propagation Rules

### HTTP Requests

**Header Name:** `X-Correlation-ID` (standard across the platform)

**Request (Client → Service):**
```http
GET /api/documents
X-Correlation-ID: req-550e8400-e29b-41d4-a716-446655440000
Authorization: Bearer <token>
```

**Response (Service → Client):**
```http
HTTP/1.1 200 OK
X-Correlation-ID: req-550e8400-e29b-41d4-a716-446655440000
Content-Type: application/json
```

**Service → Service (Internal):**
When a service calls another service, always pass the original correlation ID:
```http
GET /internal/api/users/123
X-Correlation-ID: req-550e8400-e29b-41d4-a716-446655440000
X-Service-To-Service: true
Authorization: Bearer <service-token>
```

### Message Queues (RabbitMQ, Kafka, etc.)

Store the correlation ID in message headers or metadata:

**RabbitMQ:**
```
Message properties: headers = { "X-Correlation-ID": "req-550e8400..." }
```

**Kafka:**
```
Headers: [ { "key": "X-Correlation-ID", "value": "req-550e8400..." } ]
```

**Example (Python pika):**
```python
import pika

properties = pika.BasicProperties(
    headers={ "X-Correlation-ID": correlation_id }
)
channel.basic_publish(
    exchange='events',
    routing_key='audit.login',
    body=event_json,
    properties=properties
)
```

### Logs

Include the correlation ID in **every log line** generated during the request.

**Structured Logging (JSON):**
```json
{
  "timestamp": "2026-02-13T10:25:43.123Z",
  "correlation_id": "req-550e8400-e29b-41d4-a716-446655440000",
  "service": "auth-service",
  "level": "info",
  "message": "User login successful",
  "user_id": "user-456"
}
```

**Plaintext Logging (minimally):**
```
2026-02-13T10:25:43.123Z [req-550e8400...] INFO auth-service: User login successful
```

### Audit Events

Correlation ID is a **standard field** in all audit events:

```json
{
  "timestamp": "2026-02-13T10:25:43.123Z",
  "correlation_id": "req-550e8400-e29b-41d4-a716-446655440000",
  "event_type": "authentication.login_success",
  "...": "..."
}
```

---

## Implementation Guide

### Step 1: Extract or Generate at Entry Point

```python
# Flask example
from flask import request, g
import uuid

@app.before_request
def set_correlation_id():
    correlation_id = request.headers.get(
        'X-Correlation-ID',
        f"req-{uuid.uuid4().hex}"
    )
    g.correlation_id = correlation_id
    request.headers = request.headers.copy()
    request.headers['X-Correlation-ID'] = correlation_id
```

### Step 2: Propagate in Service-to-Service Calls

```python
# When calling another service
import requests

def call_downstream_service(endpoint):
    headers = {
        'X-Correlation-ID': g.correlation_id,
        'Authorization': f"Bearer {service_token}"
    }
    response = requests.get(endpoint, headers=headers)
    return response
```

### Step 3: Include in All Logs

```python
# Configure logging to include correlation_id
import logging
import json

correlation_id = g.correlation_id
logging.info(
    json.dumps({
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "correlation_id": correlation_id,
        "event": "user_login",
        "user_id": user_id
    })
)
```

### Step 4: Include in Audit Events

```python
# Audit event emission
emit_audit_event({
    "timestamp": datetime.utcnow().isoformat() + "Z",
    "correlation_id": g.correlation_id,
    "event_type": "authentication.login_success",
    "actor": {"id": user_id, ...},
    ...
})
```

### Step 5: Return in Response Headers

```python
# Always return the correlation ID to the client
@app.after_request
def add_correlation_id_to_response(response):
    response.headers['X-Correlation-ID'] = g.correlation_id
    return response
```

---

## Example: End-to-End Request Flow

### Timeline: User Login with Keycloak + Gateway + Auth Service

```
1. Client → Gateway (HTTP POST /login)
   ❌ No X-Correlation-ID header
   → Gateway generates: req-550e8400-e29b-41d4-a716-446655440000

2. Gateway → Keycloak (HTTP POST /token)
   ✅ X-Correlation-ID: req-550e8400-e29b-41d4-a716-446655440000
   Keycloak receives, propagates to logs and audit events

3. Keycloak → Auth Svc (Service-to-service call)
   ✅ X-Correlation-ID: req-550e8400-e29b-41d4-a716-446655440000
   Auth service processes, logs, emits audit event

4. Auth Svc → Message Queue (RabbitMQ)
   ✅ Headers: { "X-Correlation-ID": "req-550e8400-e29b-41d4-a716-446655440000" }
   Async processing consumes message with same correlation ID

5. Queue Consumer (Audit Logger) → Audit Store
   ✅ Stores audit event with correlation_id = req-550e8400-e29b-41d4-a716-446655440000

6. Gateway → Client (HTTP Response)
   ✅ X-Correlation-ID: req-550e8400-e29b-41d4-a716-446655440000
   Client can track request in dashboards
```

### In Logs & Audit Events

All these events share the same correlation ID:
```
Log: [req-550e8400...] Gateway: POST /login from 192.0.2.100
Log: [req-550e8400...] Keycloak: Token request for alice@company.za
Log: [req-550e8400...] Auth-Service: Login validation passed
Audit: [req-550e8400...] Event: authentication.login_success
Log: [req-550e8400...] AuditLogger: Audit event written
```

### Forensic Query

Later, during incident investigation:
```sql
SELECT * FROM audit_events WHERE correlation_id = 'req-550e8400...'
-- Returns: all events related to this login, in order, across all services
```

---

## Handling Special Cases

### Long-Lived Processes (Batch Jobs, Scheduled Tasks)

Batch jobs may generate multiple requests internally. Best practice:
- **Parent job ID:** Track the batch job itself (e.g., `batch-daily-sync-2026-02-13`)
- **Child correlation IDs:** Each operation within the batch gets a child ID (e.g., `req-batch-daily-sync-...-operation-01`)

Example:
```python
parent_job_id = "batch-daily-sync-2026-02-13"
for user in users:
    correlation_id = f"{parent_job_id}-{user.id}-{uuid.uuid4().hex[:8]}"
    process_user(user, correlation_id)
```

### Webhook / External Events

If an external system sends a webhook without a correlation ID:
- Generate a new correlation ID
- Prefix to indicate external origin: `webhook-external-550e8400...`

### Retry Logic

When retrying a failed request:
- **Reuse the original correlation ID** (all retry attempts share the same ID)
- **Log the retry count** in the `metadata` of audit events (e.g., `"retry_attempt": 2`)

```python
for attempt in range(1, max_retries + 1):
    try:
        result = call_service(endpoint, correlation_id=original_id)
        break
    except TransientError as e:
        if attempt < max_retries:
            log_retry(correlation_id, attempt, e)
            time.sleep(backoff_seconds)
        else:
            raise
```

---

## Monitoring & Debugging

### Dashboard: Request Trace View

Operators should be able to query: "Show me all events for correlation ID X"

```
Correlation ID: req-550e8400-e29b-41d4-a716-446655440000
├── [10:25:43.100] Gateway: Received from 192.0.2.100
├── [10:25:43.105] Keycloak: Token request initiated
├── [10:25:43.200] Auth-Service: Credentials validated
├── [10:25:43.210] Keycloak: Token issued
├── [10:25:43.220] Audit-Logger: Event written
├── [10:25:43.225] Gateway: Response sent
└── Total Duration: 125ms
```

### Alerts Based on Correlation IDs

- Alert if correlation ID not found in expected services (dropped requests)
- Alert if same correlation ID used multiple times (reuse bug)
- Alert if correlation ID missing in critical audit events (logging bug)

---

## Testing

### Unit Test Example (Python)

```python
def test_correlation_id_propagation():
    client = app.test_client()
    
    # Test 1: Header passed through
    response = client.get('/api/data', headers={
        'X-Correlation-ID': 'test-123'
    })
    assert response.headers['X-Correlation-ID'] == 'test-123'
    
    # Test 2: Generated if missing
    response = client.get('/api/data')
    assert 'X-Correlation-ID' in response.headers
    assert len(response.headers['X-Correlation-ID']) >= 32
    
    # Test 3: Included in logs
    with patch('logging.info') as mock_log:
        client.get('/api/data', headers={
            'X-Correlation-ID': 'test-456'
        })
        # Verify correlation_id is in logged data
        logged_data = json.loads(mock_log.call_args[0][0])
        assert logged_data['correlation_id'] == 'test-456'
```

---

## References

- [EVENT_SCHEMA.md](./EVENT_SCHEMA.md) — Audit event structure (includes correlation_id field)
- [RETENTION_POLICY.md](./RETENTION_POLICY.md) — Log retention rules
- [AUDIT_EVENT_CATALOG.md](./AUDIT_EVENT_CATALOG.md) — Event types requiring correlation IDs

---

## Version History

- **1.0** (Feb 2026): Initial correlation ID pattern specification
