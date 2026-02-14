# Audit Event Schema

**Version:** 1.0  
**Last Updated:** 2026-02-13  
**Timezone:** Africa/Johannesburg (UTC+2, no DST)  
**Compliance:** POPIA, LAN-only

---

## Overview

This schema defines the standard structure for all audit events across the platform. Every service, system component, and application **must** emit audit events following this schema for compliance, incident response, and forensics.

**Core Principle:** Audit events contain metadata only (who, when, what, where, result) — never payloads, file contents, or PII.

---

## Standard Event Fields

Every audit event **must** include these fields:

```json
{
  "timestamp": "2026-02-13T10:25:43.123Z",
  "timestamp_tz": "Africa/Johannesburg",
  "event_id": "uuid-v4",
  "correlation_id": "request-id-from-caller",
  "source_system": "auth-service",
  "event_type": "authentication.login_success",
  "event_category": "authentication",
  "actor": {
    "id": "user-id",
    "type": "human|service|system",
    "name": "alice@example.com",
    "source_ip": "192.0.2.100"
  },
  "target": {
    "type": "application|service|resource|user|role|group|config",
    "id": "keycloak",
    "name": "Keycloak Identity Provider",
    "resource_path": "/auth/realms/main"
  },
  "action": "login",
  "outcome": "success|failure|partial",
  "outcome_reason": "MFA verification successful",
  "severity": "info|warning|error|critical",
  "metadata": {
    "mfa_method": "totp",
    "session_id": "sess-abc123",
    "duration_ms": 245
  }
}
```

---

## Field Definitions

### Timestamp Fields
- **timestamp** (ISO 8601 UTC): When the event occurred. Always UTC; convert local time to UTC.
- **timestamp_tz** (string): Timezone identifier for local time context. Use `Africa/Johannesburg`.

### Identification Fields
- **event_id** (UUID v4): Unique identifier for this event. Generate server-side; never reuse.
- **correlation_id** (string): Trace ID from the request context (if part of a larger flow). Allows linking related events. Format: alphanumeric, URL-safe.

### Source Fields
- **source_system** (string): Name of the system/service emitting the event (e.g., `auth-service`, `nextcloud`, `gateway`, `keycloak`).
- **event_type** (string): Fully qualified event type using dot notation: `<category>.<action>`. Examples:
  - `authentication.login_success`
  - `authorization.permission_denied`
  - `admin.config_change`
  - `data_access.file_read`
- **event_category** (string): High-level category. Must be one of:
  - `authentication` — login, logout, session, MFA, token events
  - `authorization` — role, group, permission changes; access denied
  - `admin` — config, deployment, user/service management
  - `data_access` — file/document/API access metadata
  - `system` — service start/stop, errors, health

### Actor (Who)
- **actor.id** (string): Unique identifier (user ID, service name, system ID).
- **actor.type** (enum): `human`, `service`, or `system`.
  - `human` — user account (has source_ip)
  - `service` — service-to-service auth (API key, certificate)
  - `system` — automated process or job (no source_ip)
- **actor.name** (string): Human-readable name (user email, service name, job name).
- **actor.source_ip** (string, optional): IP address of the actor. Only for `human`. Required for authentication events. Use IPv4 or IPv6.

### Target (What)
- **target.type** (enum): What resource was acted upon:
  - `application` — app instance (e.g., Keycloak, Nextcloud)
  - `service` — microservice or component
  - `resource` — file, document, API endpoint
  - `user` — user account
  - `role` — RBAC role
  - `group` — user group
  - `config` — configuration file or setting
  - `api_endpoint` — REST/GraphQL endpoint
- **target.id** (string): Unique identifier of the target.
- **target.name** (string): Human-readable name.
- **target.resource_path** (string, optional): Path to the resource (e.g., file path, URL, config key). Never include file contents.

### Action & Outcome
- **action** (string): Verb describing the action (e.g., `login`, `upload`, `delete`, `modify`, `deny`). Should be consistent across the platform.
- **outcome** (enum): Result of the action:
  - `success` — completed as intended
  - `failure` — attempt failed (e.g., wrong password)
  - `partial` — partially completed (e.g., MFA skipped for trusted device)
- **outcome_reason** (string, optional): Brief explanation. E.g., "Invalid credentials", "Account locked", "MFA verification successful".
- **severity** (enum): Importance level:
  - `info` — routine operations
  - `warning` — unusual but not critical (e.g., multiple failed logins)
  - `error` — error state (e.g., service unavailable)
  - `critical` — security incident (e.g., unauthorized access, privilege escalation)

### Metadata (Optional Context)
- **metadata** (object): Additional context specific to the event type. Examples:
  - `mfa_method`: "totp", "webauthn", "email"
  - `session_id`: Session identifier
  - `duration_ms`: Execution time
  - `bytes_transferred`: For data access events
  - `error_code`: System error code
  - `retry_count`: Number of retries
  - `source_system_version`: Service version

---

## Event Type Catalog

Below are the recommended event types. Services **must** emit events for security-critical and compliance-relevant actions.

### Authentication Events (`authentication.*`)

| Event Type | Actor | Target | When | Metadata |
|------------|-------|--------|------|----------|
| `authentication.login_attempt` | human | application | User submits credentials | mfa_required: bool |
| `authentication.login_success` | human | application | Credentials valid + MFA passed | mfa_method, session_id, duration_ms |
| `authentication.login_failure` | human | application | Credentials invalid or account locked | failure_reason (invalid_creds, account_locked, mfa_failed) |
| `authentication.logout` | human | application | User logs out | session_id |
| `authentication.session_start` | human | application | Session created | session_id, ip_address |
| `authentication.session_end` | human | application | Session expires or is terminated | session_id, duration_minutes |
| `authentication.mfa_challenge` | human | application | MFA prompt sent | mfa_method |
| `authentication.mfa_success` | human | application | MFA verification passed | mfa_method |
| `authentication.mfa_failure` | human | application | MFA verification failed | mfa_method, reason |
| `authentication.token_issued` | service | application | API/service token generated | token_type (jwt, api_key), expiry_hours |
| `authentication.token_refresh` | service | application | Token refreshed | token_type |
| `authentication.token_revoked` | human\|service | application | Token invalidated | reason (logout, expiry, revocation) |
| `authentication.password_change` | human | user | User changes own password | — |
| `authentication.password_reset_requested` | human | user | User requests password reset | reset_method (email, sms) |
| `authentication.password_reset_completed` | human | user | Password reset link used successfully | — |

### Authorization Events (`authorization.*`)

| Event Type | Actor | Target | When | Metadata |
|------------|-------|--------|------|----------|
| `authorization.role_assigned` | human | role | Admin assigns role to user | role_name, effective_date |
| `authorization.role_revoked` | human | role | Admin removes role from user | role_name, effective_date |
| `authorization.group_membership_added` | human | group | User added to group (manual or automatic) | group_name |
| `authorization.group_membership_removed` | human | group | User removed from group | group_name |
| `authorization.permission_granted` | human | resource | Permission granted to user/group | permission_level (read, write, admin) |
| `authorization.permission_revoked` | human | resource | Permission revoked | permission_level |
| `authorization.access_denied` | human | resource | Access attempt denied (after auth) | reason (permission_denied, resource_not_found) |
| `authorization.permission_changed` | human | config | Permission/RBAC policy updated | policy_name, change_summary |

### Admin Events (`admin.*`)

| Event Type | Actor | Target | When | Metadata |
|------------|-------|--------|------|----------|
| `admin.user_created` | human | user | New user account created | user_id, user_name |
| `admin.user_modified` | human | user | User account details changed (email, phone, etc.) | user_id, modified_fields (email, phone, status) |
| `admin.user_suspended` | human | user | User account suspended | user_id, reason |
| `admin.user_deleted` | human | user | User account deleted | user_id |
| `admin.config_change` | human | config | Configuration setting modified | config_key, old_value (masked), new_value (masked) |
| `admin.policy_updated` | human | config | Security/compliance policy updated | policy_name, version |
| `admin.deployment_initiated` | human\|service | service | Deployment or release started | deployment_id, version, target_env |
| `admin.deployment_completed` | human\|service | service | Deployment completed | deployment_id, status (success\|failure), duration_minutes |
| `admin.service_restarted` | human\|system | service | Service/application restarted | reason (maintenance, crash, admin) |
| `admin.backup_initiated` | human\|system | service | Backup job started | backup_id, target_system |
| `admin.backup_completed` | human\|system | service | Backup completed | backup_id, status, size_GB |
| `admin.privilege_escalation_attempted` | human | application | Attempt to elevate privileges | escalation_type (sudo, admin mode), success: bool |
| `admin.api_key_created` | human | service | API key generated | api_key_id (masked), service_name, expiry_date |
| `admin.api_key_revoked` | human | service | API key invalidated | api_key_id (masked), reason |

### Data Access Events (`data_access.*`)

Metadata-only; never log file contents or PII.

| Event Type | Actor | Target | When | Metadata |
|------------|-------|--------|------|----------|
| `data_access.file_accessed` | human | resource | File/document read | file_id, file_path, bytes_read |
| `data_access.file_created` | human | resource | File created | file_id, file_path, file_type |
| `data_access.file_modified` | human | resource | File updated | file_id, file_path, bytes_written |
| `data_access.file_deleted` | human | resource | File deleted (or moved to trash) | file_id, file_path |
| `data_access.file_shared` | human | resource | File shared with user/group | file_id, recipient_id, permission_level |
| `data_access.download` | human | resource | File downloaded | file_id, file_size_MB, download_duration_s |
| `data_access.upload` | human | resource | File uploaded | file_id, file_size_MB, upload_duration_s |
| `data_access.search_query` | human | application | Search executed | query_terms (non-sensitive only), num_results |
| `data_access.api_call` | service | api_endpoint | API endpoint invoked | endpoint_path, method (GET, POST, etc.), response_code, duration_ms |
| `data_access.database_query` | service | service | Database query (admin visibility only, anonymized) | query_type (SELECT, INSERT, UPDATE, DELETE), table_name, duration_ms |

### System Events (`system.*`)

| Event Type | Actor | Target | When | Metadata |
|------------|-------|--------|------|----------|
| `system.service_started` | system | service | Service/component started | service_name, version |
| `system.service_stopped` | human\|system | service | Service/component stopped | service_name, reason (maintenance, crash) |
| `system.service_error` | system | service | Service error or exception | service_name, error_code, error_message (sanitized), duration_until_recovery_s |
| `system.healthcheck_failed` | system | service | Health check failed | service_name, check_type, threshold_values |
| `system.resource_exhaustion` | system | service | CPU, memory, disk space high | service_name, resource_type (cpu, memory, disk), usage_percent |

---

## Logging Standards

### DO ✅

- **Log metadata only**: who, when, what, where, result
- **Use UTC timestamps** and include timezone for context
- **Include correlation IDs** for tracing across services
- **Mask sensitive values**: passwords, API keys, tokens (log as `***` or hash)
- **Sanitize error messages**: no stack traces with secrets
- **Mark severity** appropriately (info, warning, error, critical)
- **Emit to stdout** (container stdout, no file I/O)
- **Use structured JSON** format
- **Enforce timezone** conversion to Africa/Johannesburg for display

### DON'T ❌

- **Never log payloads**: no request/response bodies, file contents, or messages
- **Never log PII**: no names (except actor.name), email addresses, phone numbers, addresses
- **Never log secrets**: no passwords, API keys, tokens, or encryption keys
- **Never log to files** within the container (use stdout for aggregation by infra)
- **Never include stack traces** in audit logs
- **Never use local time** without UTC; always emit UTC timestamps

---

## Example Events

### Example 1: Successful Login with MFA

```json
{
  "timestamp": "2026-02-13T10:25:43.123Z",
  "timestamp_tz": "Africa/Johannesburg",
  "event_id": "550e8400-e29b-41d4-a716-446655440001",
  "correlation_id": "req-abc123",
  "source_system": "keycloak",
  "event_type": "authentication.login_success",
  "event_category": "authentication",
  "actor": {
    "id": "user-456",
    "type": "human",
    "name": "alice@company.za",
    "source_ip": "192.0.2.100"
  },
  "target": {
    "type": "application",
    "id": "keycloak",
    "name": "Keycloak Identity Provider",
    "resource_path": "/auth/realms/main"
  },
  "action": "login",
  "outcome": "success",
  "outcome_reason": "MFA verification passed",
  "severity": "info",
  "metadata": {
    "mfa_method": "totp",
    "session_id": "sess-xyz789",
    "duration_ms": 245
  }
}
```

### Example 2: Unauthorized File Access Attempt

```json
{
  "timestamp": "2026-02-13T10:26:15.456Z",
  "timestamp_tz": "Africa/Johannesburg",
  "event_id": "550e8400-e29b-41d4-a716-446655440002",
  "correlation_id": "req-def456",
  "source_system": "nextcloud",
  "event_type": "authorization.access_denied",
  "event_category": "authorization",
  "actor": {
    "id": "user-789",
    "type": "human",
    "name": "bob@company.za",
    "source_ip": "192.0.2.101"
  },
  "target": {
    "type": "resource",
    "id": "file-555",
    "name": "Project Budget 2026",
    "resource_path": "/documents/finance/budget.xlsx"
  },
  "action": "access",
  "outcome": "failure",
  "outcome_reason": "User lacks read permission for this folder",
  "severity": "warning",
  "metadata": {}
}
```

### Example 3: Admin Config Change

```json
{
  "timestamp": "2026-02-13T10:27:30.789Z",
  "timestamp_tz": "Africa/Johannesburg",
  "event_id": "550e8400-e29b-41d4-a716-446655440003",
  "correlation_id": "req-ghi789",
  "source_system": "keycloak",
  "event_type": "admin.config_change",
  "event_category": "admin",
  "actor": {
    "id": "admin-001",
    "type": "human",
    "name": "charlie@company.za",
    "source_ip": "192.0.2.102"
  },
  "target": {
    "type": "config",
    "id": "mfa-policy",
    "name": "MFA Policy",
    "resource_path": "/policies/authentication/mfa"
  },
  "action": "modify",
  "outcome": "success",
  "outcome_reason": "MFA policy updated: TOTP grace period increased from 30s to 60s",
  "severity": "warning",
  "metadata": {
    "policy_name": "MFA",
    "change_summary": "totp_grace_period: 30s → 60s"
  }
}
```

---

## Implementation Notes

### For Service Developers

1. **Initialize correlation ID** at the entry point (HTTP request handler, message queue consumer).
2. **Propagate correlation ID** in all downstream calls (HTTP headers, message headers).
3. **Generate event_id** server-side using a UUID v4 library.
4. **Emit to stdout** using structured JSON logging (stdout only, no file I/O).
5. **Mask sensitive fields** (passwords, tokens) in metadata.
6. **Use UTC timestamps** via `datetime.utcnow()` or `new Date().toISOString()`.

### For Operators

1. **Collect logs** from service stdout (container runtime, log drivers).
2. **Forward to audit log store** (syslog, log aggregator, audit database).
3. **Enforce timezone conversion** for display/queries (show times in Africa/Johannesburg).
4. **Verify schema compliance** with JSON schema validation or parsing checks.
5. **Implement retention policies** per [RETENTION_POLICY.md](./RETENTION_POLICY.md).

---

## Versioning

- **Version 1.0:** Initial schema (Feb 2026)
- Changes must be backward-compatible or include migration guidance
- Update version field in this document when schema evolves

---

## References

- POPIA (Protection of Personal Information Act)
- [RETENTION_POLICY.md](./RETENTION_POLICY.md) — log retention timelines
- [CORRELATION_ID_PATTERN.md](./CORRELATION_ID_PATTERN.md) — request ID generation & propagation
- [AUDIT_EVENT_CATALOG.md](./AUDIT_EVENT_CATALOG.md) — detailed per-system event definitions
