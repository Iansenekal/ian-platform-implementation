# Structured Logging Integration Guide

**Quick Reference for Service Developers**

---

## TL;DR - Minimal Setup

### 1. Emit JSON to stdout (one object per line)

```json
{"timestamp":"2026-02-13T10:25:43.123Z","level":"info","service":"my-service","correlation_id":"req-abc123","message":"Hello"}
```

### 2. Include every log

- `timestamp` (UTC, ISO 8601)
- `level` (info, warn, error, critical)
- `service` (your service name)
- `correlation_id` (from request header or generate)
- `message` (human-readable)
- Context fields (user_id, duration_ms, etc. as needed)

### 3. Never log

- ❌ Passwords, tokens, API keys
- ❌ Secrets (mask as `***`)
- ❌ File contents or request payloads
- ❌ PII without purpose (email, phone)
- ❌ To files (stdout only)

---

## Quickstart by Language

### Python (Flask)
```python
import json, sys, datetime, uuid
from flask import request, g

@app.before_request
def set_cid():
    g.cid = request.headers.get('X-Correlation-ID', f'req-{uuid.uuid4().hex}')

def log(level, msg, **extra):
    entry = {
        "timestamp": datetime.datetime.utcnow().isoformat() + "Z",
        "level": level,
        "service": "my-service",
        "correlation_id": g.get("cid", "unknown"),
        "message": msg,
        **extra
    }
    print(json.dumps(entry), flush=True)

log("info", "User login", user_id="alice", duration_ms=245)
```

### Node.js (Express)
```javascript
const express = require('express');
const { v4: uuidv4 } = require('uuid');

const app = express();

app.use((req, res, next) => {
  global.cid = req.headers['x-correlation-id'] || `req-${uuidv4()}`;
  next();
});

function log(level, msg, extra = {}) {
  console.log(JSON.stringify({
    timestamp: new Date().toISOString(),
    level,
    service: "my-service",
    correlation_id: global.cid,
    message: msg,
    ...extra
  }));
}

log("info", "User login", { user_id: "alice", duration_ms: 245 });
```

### Go
```go
import ("encoding/json"; "fmt"; "os"; "time")

func log(level, msg string, extra map[string]interface{}) {
  entry := map[string]interface{}{
    "timestamp": time.Now().UTC().Format(time.RFC3339Nano),
    "level": level,
    "service": "my-service",
    "correlation_id": getCorrelationID(),
    "message": msg,
  }
  for k, v := range extra {
    entry[k] = v
  }
  data, _ := json.Marshal(entry)
  fmt.Fprintln(os.Stdout, string(data))
}

log("info", "User login", map[string]interface{}{"user_id": "alice", "duration_ms": 245})
```

### Bash
```bash
log() {
  local level=$1 msg=$2; shift 2
  echo "{\"timestamp\":\"$(date -u +'%Y-%m-%dT%H:%M:%S.000Z')\",\"level\":\"$level\",\"service\":\"my-service\",\"correlation_id\":\"${CID:-unknown}\",\"message\":\"$msg\"}" | jq -c '.'
}

log info "User login" user_id alice duration_ms 245
```

---

## Passing Correlation ID

**HTTP Request:**
```http
GET /api/data
X-Correlation-ID: req-abc123
```

**HTTP Response (echo it back):**
```http
HTTP/1.1 200 OK
X-Correlation-ID: req-abc123
```

**Service-to-Service Call:**
```
Always pass the original X-Correlation-ID header to downstream services
```

**Message Queue (RabbitMQ, Kafka):**
```
Store correlation_id in message headers or metadata
```

---

## Log Levels at a Glance

| Level | When | Example |
|-------|------|---------|
| **debug** | Troubleshooting only | `Checking cache for user X` |
| **info** | Normal operations | `User login successful` |
| **warn** | Unexpected but OK | `Retry 3 of 5` |
| **error** | Something failed | `Database timeout` |
| **critical** | Security/outage | `Unauthorized access detected` |

---

## Masking Examples

```python
# ✅ Good masking
log_data = {
  "password": "***",
  "api_key": "sk-" + key[-8:] if key else "***",
  "session_token": "***",
}

# ✅ PII-free logging
log_data = {
  "user_id": "user-123",  # OK (ID, not email)
  "login_method": "email",  # OK (metadata)
  "mfa_type": "totp",  # OK (no secret)
}

# ❌ Bad (never do this)
log_data = {
  "password": "mypassword123",
  "ccn": "4532-****-****-1234",
  "email": "user@example.com",  # Unless needed for support
}
```

---

## Verifying Your Logs

### Check Format
```bash
# Run your service and check a few lines
python my_service.py 2>&1 | head -5 | jq '.'
# Should pretty-print correctly; no errors = valid JSON
```

### Check for Secrets
```bash
python my_service.py 2>&1 | grep -E '(password|token|key|secret)' | grep -vE '(masked|redacted|\*\*\*)'
# Should return nothing (no unmasked secrets)
```

### Check Correlation ID
```bash
python my_service.py 2>&1 | head -20 | jq '.correlation_id'
# Should show same ID for related logs in single request
```

---

## References

- Full guide: [STRUCTURED_LOGGING.md](./STRUCTURED_LOGGING.md)
- Audit events: [../audit-events/EVENT_SCHEMA.md](../audit-events/EVENT_SCHEMA.md)
- Correlation IDs: [../audit-events/CORRELATION_ID_PATTERN.md](../audit-events/CORRELATION_ID_PATTERN.md)
