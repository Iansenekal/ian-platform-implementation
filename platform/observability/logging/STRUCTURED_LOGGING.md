# Structured Logging Guide

**Version:** 1.0  
**Last Updated:** 2026-02-13  
**Strategy:** In-container, stdout-based, structured JSON  
**Integration:** Docker stdout → log driver (JSON-file, journald, etc.)

---

## Overview

All services emit structured logs to **stdout only** (never files). Logs are JSON-formatted, one object per line, containing:
- Timestamp (UTC)
- Log level (debug, info, warn, error, critical)
- Service/component name
- Correlation ID (from request context)
- Message and structured fields

**Benefits:**
- Parseable by log aggregators (ELK, Loki, Datadog, CloudWatch)
- Container-native (stdout is the standard)
- Minimal overhead (no file I/O, no disk space)
- Easy filtering by any field

---

## Standard Log Format

### Required Fields (Every Log Line)

```json
{
  "timestamp": "2026-02-13T10:25:43.123Z",
  "timestamp_tz": "Africa/Johannesburg",
  "level": "info",
  "service": "auth-service",
  "version": "1.0.0",
  "correlation_id": "req-550e8400-e29b-41d4-a716-446655440000",
  "message": "User login successful",
  
  // Additional context fields (log-level dependent)
  "user_id": "user-456",
  "session_id": "sess-xyz789",
  "duration_ms": 245,
  
  // For errors
  "error_code": "AUTH_OK",
  "error_message": "MFA verification passed"
}
```

### Field Definitions

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `timestamp` | ISO 8601 string | ✅ | UTC only; format: `2026-02-13T10:25:43.123Z` |
| `timestamp_tz` | string | ✅ | Timezone for local context; use `Africa/Johannesburg` |
| `level` | enum | ✅ | `debug`, `info`, `warn`, `error`, `critical` |
| `service` | string | ✅ | Name of the service/component emitting the log |
| `version` | string | ✅ | Service version (e.g., `1.0.0` or `git-sha-abc123`) |
| `correlation_id` | string | ✅ | Request ID; enables tracing across services |
| `message` | string | ✅ | Human-readable summary (keep <200 chars) |
| `user_id` | string | ⚠️ | User identifier (only if action was by a user) |
| `error_code` | string | ❌ | Application-specific error code (if error) |
| `error_message` | string | ❌ | Brief error description (sanitized, no secrets) |
| Additional fields | any | ❌ | Context-specific (duration_ms, bytes, etc.) |

---

## Log Levels

Choose the appropriate level for each log:

### debug
- Internal flow, variable values, loop iterations
- High volume, only enabled during troubleshooting
- Example: `"Checking MFA cache for user X"`

### info
- Normal operations that operators should know about
- Moderate volume, expected in production
- Example: `"User login successful"`, `"Service started listening on :8080"`

### warn
- Unexpected but recoverable conditions
- Operators should investigate
- Example: `"Invalid MFA attempt (3 failures in 10 minutes)"`, `"Database connection took 2s (threshold: 1s)"`

### error
- Error condition that requires action
- Something failed; operation may be incomplete
- Example: `"Failed to send email: SMTP timeout"`, `"User account not found"`

### critical
- Security incident or total service failure
- Page on-call engineer immediately
- Example: `"Unauthorized privilege escalation detected"`, `"Database connection pool exhausted"`

---

## DO's and DON'Ts

### DO ✅

**Emit to stdout:**
```python
import sys, json, datetime
log_entry = {
    "timestamp": datetime.datetime.utcnow().isoformat() + "Z",
    "level": "info",
    "service": "auth-service",
    "message": "User login successful",
    "user_id": "user-456"
}
print(json.dumps(log_entry), flush=True)
```

**Include correlation ID in every log:**
```python
log_entry["correlation_id"] = get_correlation_id_from_request()
```

**Mask sensitive fields:**
```python
# ✅ Good
log_entry["password"] = "***"
log_entry["api_key"] = "key_***" + key[-8:]

# ❌ Bad
log_entry["password"] = "mysupersecretpassword123"
```

**Use consistent field names:**
```python
# ✅ Good
{ "user_id": "user-123", "session_id": "sess-abc" }

# ❌ Bad (inconsistent)
{ "uid": "user-123", "sessionId": "sess-abc" }
```

### DON'T ❌

**Never log to files:**
```python
# ❌ Bad
with open("/var/log/auth.log", "a") as f:
    f.write(json.dumps(log_entry) + "\n")

# ✅ Good
print(json.dumps(log_entry))
```

**Never log secrets:**
```python
# ❌ Bad
log_entry["access_token"] = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# ✅ Good
log_entry["token_issued"] = True
```

**Never log PII without purpose:**
```python
# ❌ Bad
log_entry["email"] = "user@example.com"
log_entry["phone"] = "+27123456789"

# ✅ Good (metadata only)
log_entry["user_id"] = "user-456"
```

**Never include payloads:**
```python
# ❌ Bad
log_entry["request_body"] = { "username": "alice", "password": "secret" }
log_entry["response_body"] = { "data": "..." }

# ✅ Good
log_entry["request_type"] = "login"
log_entry["response_code"] = 200
```

**Never use non-UTC timestamps:**
```python
# ❌ Bad
import time
log_entry["timestamp"] = time.strftime("%Y-%m-%d %H:%M:%S")  # Local time

# ✅ Good
import datetime
log_entry["timestamp"] = datetime.datetime.utcnow().isoformat() + "Z"
```

**Never log stack traces in production:**
```python
# ❌ Bad
try:
    ...
except Exception as e:
    log_entry["traceback"] = traceback.format_exc()

# ✅ Good
except Exception as e:
    log_entry["error_message"] = str(e)  # Sanitized
    # Optionally log traceback only in debug mode
```

---

## Language-Specific Examples

### Python (Flask)

```python
from flask import Flask, request, g
import json
import logging
import datetime
import uuid
import sys

app = Flask(__name__)

# Setup stdout logging
class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_entry = {
            "timestamp": datetime.datetime.utcnow().isoformat() + "Z",
            "timestamp_tz": "Africa/Johannesburg",
            "level": record.levelname.lower(),
            "service": "auth-service",
            "version": "1.0.0",
            "correlation_id": getattr(g, "correlation_id", "unknown"),
            "message": record.getMessage(),
        }
        return json.dumps(log_entry)

handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(JSONFormatter())
app.logger.addHandler(handler)
app.logger.setLevel(logging.INFO)

# Middleware: Set correlation ID
@app.before_request
def set_correlation_id():
    g.correlation_id = request.headers.get(
        "X-Correlation-ID",
        f"req-{uuid.uuid4().hex}"
    )
    request.headers = dict(request.headers)  # Copy for mutation
    request.headers["X-Correlation-ID"] = g.correlation_id

@app.after_request
def add_correlation_id_to_response(response):
    response.headers["X-Correlation-ID"] = g.correlation_id
    return response

# Example endpoint
@app.route("/api/login", methods=["POST"])
def login():
    try:
        user_id = request.json.get("username")
        app.logger.info(
            "User login attempt",
            extra={"user_id": user_id, "source_ip": request.remote_addr}
        )
        
        # ... validate credentials ...
        
        session_id = f"sess-{uuid.uuid4().hex[:8]}"
        app.logger.info(
            "User login successful",
            extra={
                "user_id": user_id,
                "session_id": session_id,
                "duration_ms": 245,
                "mfa_verified": True
            }
        )
        return {"status": "success", "session_id": session_id}, 200
        
    except Exception as e:
        app.logger.error(
            "Login failed",
            extra={"user_id": user_id, "error_message": str(e)}
        )
        return {"status": "error"}, 400

if __name__ == "__main__":
    app.run()
```

**Output:**
```json
{"timestamp": "2026-02-13T10:25:43.123Z", "timestamp_tz": "Africa/Johannesburg", "level": "info", "service": "auth-service", "version": "1.0.0", "correlation_id": "req-abc123", "message": "User login attempt", "user_id": "alice"}
{"timestamp": "2026-02-13T10:25:43.350Z", "timestamp_tz": "Africa/Johannesburg", "level": "info", "service": "auth-service", "version": "1.0.0", "correlation_id": "req-abc123", "message": "User login successful", "user_id": "alice", "session_id": "sess-xyz", "duration_ms": 245, "mfa_verified": true}
```

---

### Node.js (Express)

```javascript
const express = require('express');
const { v4: uuidv4 } = require('uuid');
const app = express();

// JSON logging helper
function log(level, message, extra = {}) {
    const entry = {
        timestamp: new Date().toISOString(),
        timestamp_tz: "Africa/Johannesburg",
        level: level,
        service: "auth-service",
        version: "1.0.0",
        correlation_id: global.correlationId || "unknown",
        message: message,
        ...extra
    };
    console.log(JSON.stringify(entry));
}

// Middleware: Correlation ID
app.use((req, res, next) => {
    global.correlationId = req.headers['x-correlation-id'] || `req-${uuidv4()}`;
    res.setHeader('X-Correlation-ID', global.correlationId);
    next();
});

// Example endpoint
app.post('/api/login', (req, res) => {
    try {
        const userId = req.body.username;
        log('info', 'User login attempt', { user_id: userId, source_ip: req.ip });
        
        // ... validate credentials ...
        
        const sessionId = `sess-${Math.random().toString(36).substring(7)}`;
        const duration = 245;
        
        log('info', 'User login successful', {
            user_id: userId,
            session_id: sessionId,
            duration_ms: duration,
            mfa_verified: true
        });
        
        res.json({ status: 'success', session_id: sessionId });
    } catch (err) {
        log('error', 'Login failed', { error_message: err.message });
        res.status(400).json({ status: 'error' });
    }
});

app.listen(3000);
```

---

### Go

```go
package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/google/uuid"
)

type LogEntry struct {
	Timestamp   string      `json:"timestamp"`
	TimestampTZ string      `json:"timestamp_tz"`
	Level       string      `json:"level"`
	Service     string      `json:"service"`
	Version     string      `json:"version"`
	CorrelationID string    `json:"correlation_id"`
	Message     string      `json:"message"`
	Extra       map[string]interface{} `json:"-"`
}

func (e LogEntry) MarshalJSON() ([]byte, error) {
	m := map[string]interface{}{
		"timestamp":      e.Timestamp,
		"timestamp_tz":   e.TimestampTZ,
		"level":          e.Level,
		"service":        e.Service,
		"version":        e.Version,
		"correlation_id": e.CorrelationID,
		"message":        e.Message,
	}
	for k, v := range e.Extra {
		m[k] = v
	}
	return json.Marshal(m)
}

func Log(level, message string, extra map[string]interface{}) {
	entry := LogEntry{
		Timestamp:   time.Now().UTC().Format(time.RFC3339Nano),
		TimestampTZ: "Africa/Johannesburg",
		Level:       level,
		Service:     "auth-service",
		Version:     "1.0.0",
		CorrelationID: getCorrelationID(),
		Message:     message,
		Extra:       extra,
	}
	data, _ := json.Marshal(entry)
	fmt.Fprintln(os.Stdout, string(data))
}

func getCorrelationID() string {
	// From request context; implementation depends on handler
	return "req-" + uuid.New().String()
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	userId := r.PostFormValue("username")
	Log("info", "User login attempt", map[string]interface{}{
		"user_id":    userId,
		"source_ip":  r.RemoteAddr,
	})
	
	// ... validate credentials ...
	
	sessionID := "sess-" + uuid.New().String()[:8]
	Log("info", "User login successful", map[string]interface{}{
		"user_id":       userId,
		"session_id":    sessionID,
		"duration_ms":   245,
		"mfa_verified":  true,
	})
	
	w.Header().Set("Content-Type", "application/json")
	fmt.Fprintf(w, `{"status":"success","session_id":"%s"}`, sessionID)
}

func main() {
	http.HandleFunc("/api/login", loginHandler)
	http.ListenAndServe(":8080", nil)
}
```

---

### Shell/Bash

```bash
#!/bin/bash

# Simple JSON logging function
log() {
    local level=$1
    local message=$2
    shift 2
    
    local timestamp=$(date -u +'%Y-%m-%dT%H:%M:%S.000Z')
    local correlation_id="${CORRELATION_ID:-unknown}"
    
    # Build JSON object
    local json="{
        \"timestamp\": \"${timestamp}\",
        \"timestamp_tz\": \"Africa/Johannesburg\",
        \"level\": \"${level}\",
        \"service\": \"example-service\",
        \"version\": \"1.0.0\",
        \"correlation_id\": \"${correlation_id}\",
        \"message\": \"${message}\""
    
    # Add extra fields (key=value pairs)
    while [ $# -gt 0 ]; do
        json="${json},
        \"$1\": \"$2\""
        shift 2
    done
    
    json="${json}
    }"
    
    echo "$json" | jq -c '.'  # Pretty output (install jq)
}

# Example usage
CORRELATION_ID="req-abc123"
log "info" "Processing started" "file" "batch.csv" "count" "1000"
log "info" "Processing complete" "duration_ms" "5234"
log "error" "Failed to process" "error_message" "Disk full"
```

**Output:**
```json
{"timestamp":"2026-02-13T10:25:43.000Z","timestamp_tz":"Africa/Johannesburg","level":"info","service":"example-service","version":"1.0.0","correlation_id":"req-abc123","message":"Processing started","file":"batch.csv","count":"1000"}
```

---

## Integration Patterns

### With Docker

Logs automatically captured by Docker's JSON-file driver:

```bash
# Run service
docker run -d --name auth-service myregistry/auth-service:1.0.0

# View logs (Docker outputs JSON automatically)
docker logs auth-service | jq '.'

# Tail logs
docker logs -f auth-service | grep '"level":"error"'
```

### With Docker Compose

```yaml
version: '3'
services:
  auth-service:
    image: myregistry/auth-service:1.0.0
    ports:
      - "8080:8080"
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
    environment:
      - LOG_LEVEL=info
```

---

## Log Rotation & Cleanup

Since logs go to stdout, Docker's driver handles rotation:

```yaml
# In docker-compose.yml
logging:
  driver: json-file
  options:
    max-size: "10m"        # Rotate when log hits 10MB
    max-file: "3"           # Keep 3 rotated files (30MB total)
    labels: "service=auth"  # Add labels for filtering
```

For dev container (local testing):
```bash
# Logs to stdout; capture with:
service-app > service.log 2>&1

# Or pipe to jq for filtering:
service-app 2>&1 | jq 'select(.level == "error")'
```

---

## Filtering & Queries

### By Log Level

```bash
# Show only errors
docker logs my-service | grep '"level":"error"'
```

### By Correlation ID

```bash
# Show all logs for a single request
docker logs my-service | grep 'req-abc123'
```

### By Time Range

```bash
# Show logs after a timestamp
docker logs my-service --since "2026-02-13T10:00:00Z"
```

### With jq (if available)

```bash
# Pretty-print
docker logs my-service | jq '.'

# Filter by level
docker logs my-service | jq 'select(.level == "error")'

# Extract fields
docker logs my-service | jq '.user_id, .duration_ms'

# Count errors per service
docker logs my-service | jq 'select(.level == "error") | .service' | sort | uniq -c
```

---

## Testing & Validation

### Unit Test Example (Python)

```python
def test_login_logs_correct_fields(capsys):
    """Verify login endpoint logs required fields."""
    client = app.test_client()
    
    response = client.post("/api/login", json={
        "username": "alice",
        "password": "secret"
    })
    
    captured = capsys.readouterr()
    log_lines = [json.loads(line) for line in captured.out.strip().split('\n')]
    
    # Verify success log has required fields
    success_log = [l for l in log_lines if l.get("message") == "User login successful"][0]
    assert success_log.get("user_id") == "alice"
    assert success_log.get("session_id") is not None
    assert success_log.get("correlation_id") is not None
    assert success_log.get("timestamp").endswith("Z")
    assert success_log.get("level") == "info"
```

### Integration Test (Check for Secrets)

```bash
#!/bin/bash
# Run service and check logs for leaked secrets

service-app > /tmp/service.log 2>&1 &
sleep 2
kill %1

# Check for common secret patterns
if grep -E "(password|token|key|secret)" /tmp/service.log | grep -vE "(***|masked|redacted)"; then
    echo "FAIL: Secrets found in logs!"
    exit 1
else
    echo "PASS: No unmasked secrets in logs"
    exit 0
fi
```

---

## Common Mistakes to Avoid

### ❌ Multiple JSON Objects on One Line

```json
{"log": "entry1"}{"log": "entry2"}
```

**Fix:** Newline-delimited JSON (each log on separate line)
```json
{"log": "entry1"}
{"log": "entry2"}
```

### ❌ Logging Without Correlation ID

```json
{"timestamp": "...", "level": "info", "message": "User action"}
```

**Fix:** Always include correlation_id
```json
{"timestamp": "...", "correlation_id": "req-abc123", "level": "info", "message": "User action"}
```

### ❌ Inconsistent Timestamps

```json
{"timestamp": "2026-02-13T10:25:43Z"}
{"timestamp": "2026-02-13 10:25:43"}
{"timestamp": 1707805543}
```

**Fix:** Standardize on ISO 8601 UTC
```json
{"timestamp": "2026-02-13T10:25:43.123Z"}
```

### ❌ Logging Non-JSON

```
Customer login: alice at 10:25:43
```

**Fix:** Emit structured JSON
```json
{"timestamp": "2026-02-13T10:25:43.123Z", "message": "Customer login", "user_id": "alice"}
```

---

## Logging Library Recommendations

### Python
- **Built-in `logging`** + custom JSON formatter (shown above)
- **python-json-logger:** Pre-built JSON formatter
- **structlog:** Structured logging framework

### Node.js
- **pino:** Built for JSON logging + high performance
- **winston:** Flexible logging; easy JSON config
- **bunyan:** Structured JSON logging (legacy, but robust)

### Go
- **go.uber.org/zap:** Structured logging, fast
- **logrus:** Simple, widely used
- **log/slog:** Standard library (Go 1.21+)

### Bash/Shell
- jq + printf (shown above)
- Custom functions for JSON generation

---

## References

- [EVENT_SCHEMA.md](../audit-events/EVENT_SCHEMA.md) — Audit event structure (includes logging standards)
- [CORRELATION_ID_PATTERN.md](../audit-events/CORRELATION_ID_PATTERN.md) — How to propagate request IDs in logs
- Docker Logging: https://docs.docker.com/config/containers/logging/

---

## Version History

- **1.0** (Feb 2026): Initial structured logging guide for stdout-based architecture
