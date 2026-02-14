# Audit Event Catalog

**Version:** 1.0  
**Last Updated:** 2026-02-13  
**Scope:** All systems, services, and platforms running on ian-platform-implementation
**Reference:** [EVENT_SCHEMA.md](./EVENT_SCHEMA.md) for field definitions

---

## Overview

This catalog lists **all audit events that the platform must or should emit**, organized by system/component. Each entry specifies:
- Event type (fully qualified name)
- When it occurs
- Required fields
- Optional metadata
- System owning the event

Use this as a **checklist for service implementation** and **audit verification**.

---

## Legend

- **MUST** — Mandatory; all systems will emit this event
- **SHOULD** — Highly recommended; required for compliance
- **MAY** — Optional; enhanced observability

---

## System Events

### Keycloak (Identity Provider)

**Owner:** Identity Platform Team  
**Reference:** Phase 4 (31–35)

| Event | Frequency | Priority | When |
|-------|-----------|----------|------|
| `authentication.login_attempt` | High | MUST | User submits credentials at /token |
| `authentication.login_success` | High | MUST | Credentials + MFA validated |
| `authentication.login_failure` | High | MUST | Invalid credentials, locked account, or MFA failure |
| `authentication.logout` | Medium | MUST | User logs out or token revoked |
| `authentication.session_start` | High | MUST | Session created after login |
| `authentication.session_end` | High | MUST | Session expires or user logs out |
| `authentication.mfa_challenge` | High | MUST | MFA prompt sent (TOTP, WebAuthn, email) |
| `authentication.mfa_success` | High | MUST | MFA verification passed |
| `authentication.mfa_failure` | High | MUST | MFA code incorrect or expired |
| `authentication.token_issued` | High | SHOULD | API token / refresh token generated |
| `authentication.token_refresh` | High | SHOULD | Refresh token redeemed for new access token |
| `authentication.token_revoked` | Medium | SHOULD | Token manually or automatically revoked |
| `authentication.password_change` | Low | SHOULD | User successfully changes password |
| `authentication.password_reset_requested` | Low | SHOULD | User initiates password reset flow |
| `authentication.password_reset_completed` | Low | SHOULD | Password reset via email link verified |
| `authorization.role_assigned` | Medium | MUST | Admin assigns role to user/group |
| `authorization.role_revoked` | Medium | MUST | Admin removes role from user/group |
| `authorization.group_membership_added` | Medium | MUST | User added to group (manual or sync from AD) |
| `authorization.group_membership_removed` | Medium | MUST | User removed from group |
| `admin.user_created` | Low | MUST | Admin creates new user account |
| `admin.user_modified` | Low | SHOULD | Admin modifies user attributes (email, phone, status) |
| `admin.user_suspended` | Low | SHOULD | Admin suspends user account |
| `admin.user_deleted` | Low | MUST | Admin deletes user account |
| `admin.config_change` | Low | SHOULD | Admin modifies realm/client config (passwords, URLs, flows) |
| `admin.policy_updated` | Low | SHOULD | Admin updates MFA policy, session timeout, or password policy |

**Metadata Examples:**
```json
{
  "authentication.login_success": {
    "mfa_method": "totp|webauthn|email",
    "session_id": "sess-abc123",
    "duration_ms": 245
  },
  "authorization.role_assigned": {
    "role_name": "admin|user|reviewer",
    "effective_date": "2026-02-13"
  }
}
```

---

### API Gateway (Ingress / Reverse Proxy)

**Owner:** Infrastructure Team  
**Reference:** Phase 5 (36–39)

| Event | Frequency | Priority | When |
|-------|-----------|----------|------|
| `authentication.token_validation_success` | Very High | MUST | Token provided in request is valid |
| `authentication.token_validation_failure` | High | MUST | Token missing, expired, or invalid |
| `authorization.access_denied` | Medium | MUST | User authenticated but lacks permission for endpoint |
| `data_access.api_call` | Very High | SHOULD | API endpoint invoked (GET, POST, etc.) |
| `admin.config_change` | Low | SHOULD | Gateway rules, rate limiting, or routes modified |
| `system.healthcheck_failed` | Medium | SHOULD | Health check endpoint (e.g., /healthz) failed |

**Metadata Examples:**
```json
{
  "data_access.api_call": {
    "endpoint_path": "/api/documents",
    "method": "GET",
    "response_code": 200,
    "duration_ms": 150,
    "bytes_transferred": 4096
  },
  "authentication.token_validation_failure": {
    "failure_reason": "token_expired|token_invalid|token_not_provided"
  }
}
```

---

### Nextcloud (Document Management)

**Owner:** Document Management Team  
**Reference:** Phase 6 (40–45)

| Event | Frequency | Priority | When |
|-------|-----------|----------|------|
| `authentication.login_success` | High | MUST | User logs in to Nextcloud web/mobile app |
| `authentication.login_failure` | Medium | MUST | Failed login attempt |
| `authentication.logout` | Medium | MUST | User logs out |
| `authorization.permission_granted` | Medium | MUST | File/folder permission set by owner/admin |
| `authorization.permission_revoked` | Medium | MUST | File/folder permission removed |
| `authorization.access_denied` | Medium | MUST | User attempted to access file/folder without permission |
| `data_access.file_created` | Very High | SHOULD | File uploaded or created in Nextcloud |
| `data_access.file_modified` | Very High | SHOULD | File edited (content or metadata) |
| `data_access.file_deleted` | High | SHOULD | File deleted (or moved to trash) |
| `data_access.file_accessed` | Very High | MAY | File read/viewed (high volume, consider sampling) |
| `data_access.file_shared` | Medium | SHOULD | File shared with user/group/public link |
| `data_access.download` | High | SHOULD | File downloaded to local device |
| `admin.user_created` | Low | SHOULD | Admin creates Nextcloud user |
| `admin.user_modified` | Low | SHOULD | Admin modifies user settings |
| `admin.user_deleted` | Low | SHOULD | Admin deletes user |
| `admin.config_change` | Low | MAY | Admin changes Nextcloud config (quotas, sharing rules) |

**Metadata Examples:**
```json
{
  "data_access.file_created": {
    "file_id": "file-123",
    "file_path": "/documents/report.pdf",
    "file_type": "application/pdf",
    "file_size_bytes": 2048576
  },
  "data_access.file_shared": {
    "file_id": "file-123",
    "recipient_id": "user-456",
    "permission_level": "edit|view|share"
  }
}
```

---

### Search & Knowledge Graph

**Owner:** Search & Analytics Team  
**Reference:** Phase 6 (43–45)

| Event | Frequency | Priority | When |
|-------|-----------|----------|------|
| `data_access.search_query` | Very High | SHOULD | User executes search (may sample/aggregate) |
| `data_access.api_call` | High | SHOULD | Graph API queried (node retrieval, linking) |
| `admin.config_change` | Low | MAY | Search index mapping or analyzer changed |
| `system.service_error` | Medium | SHOULD | Indexer failure or query timeout |

**Metadata Examples:**
```json
{
  "data_access.search_query": {
    "query_terms": "budget 2026",  // Non-sensitive terms only
    "num_results": 42,
    "duration_ms": 350,
    "user_id": "user-123"  // For analytics
  }
}
```

---

### Voice Ingestion Service

**Owner:** Voice/AI Team  
**Reference:** Phase 7 (60–63)

| Event | Frequency | Priority | When |
|-------|-----------|----------|------|
| `data_access.upload` | Medium | MUST | Audio file uploaded for transcription |
| `data_access.file_created` | Medium | SHOULD | Transcription output file created |
| `authorization.permission_granted` | Low | SHOULD | Transcription shared with user/group |
| `authorization.access_denied` | Medium | SHOULD | User lacks permission to access transcript |
| `admin.config_change` | Low | MAY | Transcription model or settings changed |
| `system.service_error` | Medium | SHOULD | Transcription timeout or processing error |

**Metadata Examples:**
```json
{
  "data_access.upload": {
    "file_id": "voice-456",
    "file_type": "audio/mpeg",
    "duration_seconds": 120,
    "upload_duration_s": 15
  }
}
```

---

### Workflow Engine

**Owner:** Workflow/Document Team  
**Reference:** Phase 8 (70–75)

| Event | Frequency | Priority | When |
|-------|-----------|----------|------|
| `data_access.file_accessed` | Medium | MUST | Document retrieved for approval workflow |
| `authorization.permission_granted` | Low | SHOULD | Approver role assigned to user |
| `data_access.api_call` | High | SHOULD | Workflow action invoked (approve, reject, escalate) |
| `admin.config_change` | Low | MAY | Approval chain or workflow rules modified |
| `system.service_error` | Medium | SHOULD | Workflow step timed out or failed |

**Metadata Examples:**
```json
{
  "data_access.api_call": {
    "endpoint_path": "/api/approve",
    "method": "POST",
    "response_code": 200,
    "duration_ms": 200,
    "action": "approve|reject|escalate"
  }
}
```

---

### Notification Service (Email/SMTP)

**Owner:** Notification Team  
**Reference:** Phase 8 (71–75)

| Event | Frequency | Priority | When |
|-------|-----------|----------|------|
| `data_access.api_call` | High | SHOULD | Email send request processed |
| `admin.config_change` | Low | MAY | SMTP config or templates modified |
| `system.service_error` | Medium | SHOULD | Mail server failure or delivery timeout |

**Metadata Examples:**
```json
{
  "data_access.api_call": {
    "endpoint_path": "/api/send-email",
    "recipient_count": 3,
    "duration_ms": 450,
    "status": "queued|sent|failed"
  }
}
```

---

### Automation Engine (n8n or Windmill)

**Owner:** Automation Team  
**Reference:** Phase 9 (76–77, optional)

| Event | Frequency | Priority | When |
|-------|-----------|----------|------|
| `data_access.api_call` | High | SHOULD | Automation workflow step executed |
| `admin.config_change` | Low | SHOULD | Workflow definition or trigger modified |
| `admin.policy_updated` | Low | SHOULD | Execution policy or credentials updated |
| `system.service_error` | Medium | SHOULD | Workflow step failed or timed out |

---

### Monitoring Stack (Prometheus / Grafana)

**Owner:** Operations Team  
**Reference:** Phase 10 (80–82)

| Event | Frequency | Priority | When |
|-------|-----------|----------|------|
| `data_access.api_call` | Very High | SHOULD | Metrics scraped or queried (may sample) |
| `admin.config_change` | Low | SHOULD | Alert rule or dashboard modified |
| `authentication.login_success` | Low | SHOULD | User logs in to Grafana |
| `authorization.permission_granted` | Low | SHOULD | Dashboard access granted to user |

---

### Backup & Disaster Recovery

**Owner:** Operations Team  
**Reference:** Phase 11 (90–99)

| Event | Frequency | Priority | When |
|-------|-----------|----------|------|
| `admin.backup_initiated` | Low | MUST | Backup job starts |
| `admin.backup_completed` | Low | MUST | Backup job completes (success or failure) |
| `admin.config_change` | Low | MAY | Backup schedule or retention policy modified |
| `system.service_error` | Medium | SHOULD | Backup failure or data validation error |

**Metadata Examples:**
```json
{
  "admin.backup_initiated": {
    "backup_id": "backup-20260213-001",
    "target_system": "nextcloud",
    "backup_type": "full|incremental"
  },
  "admin.backup_completed": {
    "backup_id": "backup-20260213-001",
    "status": "success|failure",
    "size_gb": 42.5,
    "duration_minutes": 125
  }
}
```

---

## Cross-Cutting Service Events

Events that **all services** should emit:

### System Events (Every Service)

| Event | Frequency | Priority | When |
|-------|-----------|----------|------|
| `system.service_started` | Low | SHOULD | Service/container starts up |
| `system.service_stopped` | Low | SHOULD | Service/container shuts down gracefully |
| `system.service_error` | High | SHOULD | Unhandled exception, panic, or critical error |
| `system.healthcheck_failed` | Medium | SHOULD | Health check endpoint (/health) fails |
| `system.resource_exhaustion` | Medium | SHOULD | CPU, memory, or disk space exceeds threshold |

### Data Access Events (Every Service with APIs)

| Event | Frequency | Priority | When |
|-------|-----------|----------|------|
| `data_access.api_call` | Very High | SHOULD | API endpoint invoked (all GET, POST, DELETE, etc.) |

---

## Sampling & Aggregation

Some events are **very high frequency** and will overwhelm the audit log. Best practices:

### Sample Events

**Event:** `data_access.file_accessed` (Nextcloud)  
**Volume:** ~10,000/day per active user  
**Strategy:** Sample 10% or log only on errors

**Event:** `data_access.api_call` (Gateway)  
**Volume:** Hundreds/second  
**Strategy:** Aggregate by endpoint/hour or sample errors + slow calls

**Event:** `system.healthcheck_failed` (Every service)  
**Volume:** Hundreds/day  
**Strategy:** Aggregate (log once per hour if repeated) or sample

### Aggregate Events

Instead of logging 1,000 identical login attempts for user A:
```json
// Individual (verbose)
{ "event_type": "authentication.login_failure", "outcome_reason": "invalid_creds", "actor.id": "user-123", ... }
{ "event_type": "authentication.login_failure", "outcome_reason": "invalid_creds", "actor.id": "user-123", ... }
{ "event_type": "authentication.login_failure", "outcome_reason": "invalid_creds", "actor.id": "user-123", ... }

// Aggregated (efficient)
{ 
  "event_type": "authentication.login_failure_aggregated", 
  "outcome_reason": "invalid_creds",
  "actor.id": "user-123",
  "count": 1000,
  "time_window": "2026-02-13T10:00:00Z to 2026-02-13T11:00:00Z",
  "severity": "warning"  // Escalated due to count
}
```

---

## Implementation Checklist

Use this as a **per-service verification checklist** during Phase 2–11:

### Phase 4 (Keycloak)
- [ ] All auth events emit to stdout (structured JSON)
- [ ] Correlation ID included in all events
- [ ] Login failures include failure_reason (invalid_creds, account_locked, etc.)
- [ ] MFA events tagged with mfa_method
- [ ] Role/group changes emit authorization events
- [ ] Admin config changes logged with old/new values (masked)

### Phase 6 (Nextcloud)
- [ ] File created/modified/deleted events include file_id and file_path (no content)
- [ ] Permission changes track recipient and permission_level
- [ ] Access denied events include reason
- [ ] Download/upload events include file_size_bytes and duration_s
- [ ] User lifecycle events (create/delete/modify) logged

### Phase 7 (Voice)
- [ ] Upload events include file_type and duration_seconds
- [ ] Permission/access events track sharing and recipients

### Phase 8 (Workflow)
- [ ] Approval actions (approve/reject/escalate) logged as api_call events
- [ ] Document access tracked before approval
- [ ] Final outcome (approved/rejected) logged with timestamp

### Phase 10 (Monitoring)
- [ ] Metrics scraped with query details (may be sampled)
- [ ] Alert rule changes logged
- [ ] Dashboard modifications tracked

### All Services
- [ ] Correlation ID in all logs and events
- [ ] Service start/stop logged
- [ ] Errors logged with sanitized messages (no secrets, no stack traces)

---

## Event Evolution

As the platform grows, this catalog evolves. New events added:

1. **Propose** new event type in GitHub issue
2. **Review** for compliance impact
3. **Document** in this catalog
4. **Implement** in service (start logging)
5. **Verify** in audit pipeline (event schema validation)

---

## References

- [EVENT_SCHEMA.md](./EVENT_SCHEMA.md) — Field definitions and structure
- [RETENTION_POLICY.md](./RETENTION_POLICY.md) — How long events are kept
- [CORRELATION_ID_PATTERN.md](./CORRELATION_ID_PATTERN.md) — How to trace requests
- System-specific phase documentation (31–99 in PLATFORM_ROADMAP.md)

---

## Version History

- **1.0** (Feb 2026): Initial audit event catalog covering Phases 4–11
