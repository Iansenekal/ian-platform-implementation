# Audit Event Retention Policy

**Version:** 1.0  
**Last Updated:** 2026-02-13  
**Compliance:** POPIA (Protection of Personal Information Act), data protection regulations

---

## Overview

This document defines how long audit logs and events must be retained, when they can be deleted, and exception processes for legal holds or compliance investigations.

**Core Principle:** Keep events as long as necessary for compliance and incident response; delete promptly when retention period expires to minimize privacy risk and storage costs.

---

## Retention Timelines

### Category 1: Authentication & Session Events

**Applies to:**
- Login attempts (success/failure)
- MFA challenges and verifications
- Session creation/termination
- Token issuance/revocation
- Password resets

**Retention Period:** **365 days** (1 year)

**Rationale:**
- Required for forensic analysis of breaches and unauthorized access
- Supports compliance investigations and audit trails
- Enables detection of long-term compromise patterns
- Per POPIA Principle 7 (Security Safeguards)

**Deletion Rule:**
- Delete events older than 365 days
- Notify data subject upon request (POPIA Principle 6 — Right of Access)
- Purge daily or weekly via automated job

---

### Category 2: Authorization & Access Control Events

**Applies to:**
- Role/group membership changes
- Permission grants/revokes
- Access denied events
- Policy updates

**Retention Period:** **365 days** (1 year)

**Rationale:**
- Audit trail for all privilege changes
- Investigate unauthorized access claims
- Detect permission-based attacks or misconfiguration
- Supports audit requirements (Principle 7)

**Deletion Rule:**
- Delete events older than 365 days
- Automated daily/weekly purge

---

### Category 3: Admin Actions

**Applies to:**
- Config/policy changes
- User account creation/deletion/suspension
- Deployment/service events
- Backup operations
- Privilege escalation attempts

**Retention Period:** **180–365 days** (6–12 months, configurable by event type)

| Event Type | Retention | Reason |
|------------|-----------|--------|
| Config changes | 365 days | Infrastructure audit trail |
| User lifecycle (create/delete) | 365 days | Account accountability, POPIA |
| Service restarts/deployments | 90 days | Operational history, troubleshooting |
| Backup operations | 90 days | Recovery tracking; old backups may be deleted |
| Privilege escalation | 365 days | Security monitoring |

**Deletion Rule:**
- Delete events based on event-type-specific retention
- Automated purge per schedule

---

### Category 4: Data Access Events

**Applies to:**
- File read/write/delete/share
- Document downloads
- API calls
- Search queries
- Database queries

**Retention Period:** **180 days** (6 months, shorter for performance)

**Rationale:**
- Shorter timeline due to high volume (can impact storage costs)
- Still sufficient for breach forensics (180 days = ~6 months)
- Metadata-only (no PII in content), so lower privacy risk after purge
- Balances compliance and operational efficiency

**Deletion Rule:**
- Delete events older than 180 days
- Automated purge (daily or on-demand)
- Can override for legal holds

---

### Category 5: System & Infrastructure Events

**Applies to:**
- Service start/stop/errors
- Health check failures
- Resource exhaustion warnings
- Log rotations

**Retention Period:** **90 days** (3 months, shorter rotation)

**Rationale:**
- Primarily for operational troubleshooting
- Newer data more useful (trend analysis)
- High volume; aggressive purge saves storage
- Historic value decreases rapidly

**Deletion Rule:**
- Delete events older than 90 days
- Automated daily purge
- Archive if needed for long-term trending

---

## Retention Summary Table

| Event Category | Retention Period | Purge Schedule | Archive? |
|---|---|---|---|
| Authentication & Session | 365 days | Daily/Weekly | Optional (1 year) |
| Authorization & Access Control | 365 days | Daily/Weekly | Optional (2 years) |
| Admin Actions | 90–365 days | Daily | Recommended |
| Data Access | 180 days | Daily | Optional (1 year) |
| System & Infrastructure | 90 days | Daily | No |

---

## Regional/Compliance Considerations

### POPIA (South Africa)

**Applicable Principles:**
- **Principle 7 — Security Safeguards:** Adequate security measures including audit logging and retention.
- **Principle 6 — Access to Personal Information:** Right of access implies ability to retrieve logs (must retain long enough).
- **Principle 2 — Conditions for Lawful Processing:** Transparency requires audit trails.

**Implications:**
- Must retain auth/admin events for 12+ months
- Must support data subject requests for their own access logs
- Must be able to produce audit trails on demand for investigations
- Must delete PII-containing logs promptly (use metadata-only logging)

### GDPR (if applicable in future EU operations)

**Applicable Articles:**
- **Article 32 — Security of Processing:** Audit logging required.
- **Article 17 — Right to be Forgotten:** Users can request deletion (conflicts with retention, requires legal hold override).
- **Article 33/34 — Breach Notification:** Audit logs required to detect and report breaches.

**Implications:**
- Longer retention (24 months) for breach forensics
- Ability to identify affected individuals in logs
- Must process deletion requests (except legal hold)

---

## Purge Mechanism

### Automated Purge Job

A scheduled task runs daily (recommended) or weekly to delete events older than retention period.

**Schedule:** Daily at 02:00 Africa/Johannesburg (off-peak)

**Script:** `deploy/audit-log-purge.sh` (to be implemented)

```bash
#!/bin/bash
# Purge old audit events based on retention policy

AUDIT_LOG_DB="audit_events"  # PostgreSQL table or other store
RETENTION_DAYS_AUTH=365
RETENTION_DAYS_DATA_ACCESS=180
RETENTION_DAYS_SYSTEM=90

# Delete authentication events older than 365 days
psql -c "DELETE FROM ${AUDIT_LOG_DB} 
         WHERE event_category = 'authentication' 
         AND timestamp < NOW() - INTERVAL '${RETENTION_DAYS_AUTH} days';"

# Delete data access events older than 180 days
psql -c "DELETE FROM ${AUDIT_LOG_DB} 
         WHERE event_category = 'data_access' 
         AND timestamp < NOW() - INTERVAL '${RETENTION_DAYS_DATA_ACCESS} days'
         AND NOT on_legal_hold;"

# Delete system events older than 90 days
psql -c "DELETE FROM ${AUDIT_LOG_DB} 
         WHERE event_category = 'system' 
         AND timestamp < NOW() - INTERVAL '${RETENTION_DAYS_SYSTEM} days';"

echo "Purge completed at $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
```

**Monitoring:**
- Alert if purge fails (runs, but processes 0 rows unexpectedly)
- Log purge stats (rows deleted per category)
- Require manual approval for bulk deletes (>1M rows)

### Dry-Run Option

Always support safe testing:

```bash
./deploy/audit-log-purge.sh --dry-run
# Output: SELECT (deleted) count(*)... = 10,250 rows would be deleted
```

### Immutable Archive (Optional)

If regulatory requirements demand, archive purged events before deletion:

```
audit-logs/2026/02/ (daily snapshots)
├── 2026-02-01.jsonl.gz
├── 2026-02-02.jsonl.gz
└── ...
```

Archived logs are:
- Compressed (gzip)
- Read-only
- Stored on cheaper long-term storage (if available)
- Cannot be modified (immutability guarantee)

---

## Legal Hold & Exception Process

### When to Apply Legal Hold

A legal hold **suspends deletion** for specified events if:
- Active legal case or investigation involving the data subject
- Regulatory audit or breach investigation
- Law enforcement request
- Internal security incident investigation

### Legal Hold Procedure

1. **Request Legal Hold**
   - Source: Legal, Compliance, or Incident Response team
   - Trigger: Court order, warrant, incident escalation
   - Duration: Until legal case closes or investigation concludes

2. **Apply Hold**
   - Flag affected audit events with `legal_hold: true`
   - Purge job skips events with `legal_hold: true` (regardless of retention date)
   - Log the hold (who, when, reason, duration)

3. **Monitor Hold**
   - Quarterly review of active holds
   - Extend or release as needed

4. **Release Hold**
   - Legal/Compliance signs off: "OK to delete"
   - Update event flags: `legal_hold: false`
   - Schedule purge for next run

**Implementation:**

```sql
-- Table schema includes legal hold flag
CREATE TABLE audit_events (
  event_id UUID PRIMARY KEY,
  timestamp TIMESTAMP NOT NULL,
  event_category VARCHAR(50) NOT NULL,
  ...
  legal_hold BOOLEAN DEFAULT FALSE,
  legal_hold_reason TEXT,
  legal_hold_applied_at TIMESTAMP,
  legal_hold_released_at TIMESTAMP
);

-- Apply hold
UPDATE audit_events 
SET legal_hold = TRUE, 
    legal_hold_reason = 'Case ABC-2026-001',
    legal_hold_applied_at = NOW()
WHERE event_category = 'authentication' 
  AND timestamp > '2026-01-01'::TIMESTAMP;

-- Purge job checks hold flag
DELETE FROM audit_events 
WHERE event_category = 'authentication' 
  AND timestamp < NOW() - INTERVAL '365 days'
  AND legal_hold = FALSE;  -- Skip held events
```

---

## Data Subject Access Requests (Immediate Availability)

When a data subject requests: "Show me all my access logs," you must:

1. **Query audit events** where `actor.id = <subject_id>` (authenticated user request)
2. **Retrieve** all relevant events (auth logins, file access, etc.)
3. **Respond** with events within 30 days (POPIA requirement)
4. **Do NOT delete** if request is pending (implicit legal hold)

**Template Response:**

```
Subject Access Request (SAR) Fulfillment
Requester: alice@company.za
Request Date: 2026-02-13
Data Period Requested: Last 12 months
Provided Events: 1,247 audit entries

Events Include:
- Authentication (logins, logouts, MFA, tokens)
- Authorization (permission checks, access denied)
- Data Access (file reads, downloads, shares)
- Admin Actions (account modifications, if any)

Format: CSV, JSON (choose one)
Redacted: Service-to-service calls, admin-only logs, other users' PII
```

---

## Compliance Verification

### Quarterly Audit

1. **Check retention:** Verify old events are deleted on schedule
   ```sql
   SELECT COUNT(*) FROM audit_events 
   WHERE timestamp < NOW() - INTERVAL '370 days';
   -- Should be 0 (all older events purged)
   ```

2. **Review legal holds:** List active holds and their status
   ```sql
   SELECT event_id, legal_hold_reason, legal_hold_applied_at FROM audit_events 
   WHERE legal_hold = TRUE 
   ORDER BY legal_hold_applied_at;
   ```

3. **Verify purge logs:** Confirm purge jobs ran successfully
   ```bash
   tail -f /var/log/audit-purge.log
   # 2026-02-13 02:00:15: Purge started
   # 2026-02-13 02:00:45: Deleted 12,450 auth events (>365 days)
   # 2026-02-13 02:01:10: Deleted 8,320 data_access events (>180 days)
   # 2026-02-13 02:01:15: Purge completed
   ```

4. **Test SAR process:** Simulate a data subject request
   - Request logs for a test user
   - Verify response completeness and timeliness
   - Ensure no redacted PII of other users included

### Annual Review

- Update retention timelines based on new legal requirements
- Audit purge effectiveness (storage usage, performance)
- Review legal holds (any stuck indefinitely?)
- Assess archive storage costs (if applicable)

---

## Exceptions & Appeals

### Exception: Shorter Retention for High-Volume Events

Some systems generate high-volume, low-value logs (e.g., health checks, automated system calls). **Option:**

- Store in separate table with separate retention policy (30–60 days)
- Exclude from main audit log retention rules
- Document exception and approval

**Approval:** Data Protection Officer + Compliance

### Exception: Longer Retention for Regulatory Requirement

Novel compliance need (e.g., financial audit). **Option:**

- Extend retention for affected event types
- Archive to separate, read-only store
- Implement access controls (DPO/auditor approval)

**Approval:** Legal Counsel + Compliance + CTO

---

## Evidence Preservation (Compliance Pack)

For regulatory/legal scenarios, the compliance team can generate an **evidence pack** (immutable snapshot):

```
compliance-evidence-pack-2026-02-13-breach-investigation.zip
├── audit_events_snapshot.jsonl (all events for date range)
├── metadata.json (created_at, hash, retention_status)
├── legal_hold_status.md (held events, reasons)
└── purge_log_snapshot.txt (recent purge history)
```

This pack is generated on-demand and stored separately (cannot be purged).

---

## Configuration & Customization

Retention timelines can be overridden per environment via `.env` or config:

```bash
# .env.example
AUDIT_RETENTION_AUTH_DAYS=365
AUDIT_RETENTION_AUTHZ_DAYS=365
AUDIT_RETENTION_ADMIN_DAYS=90
AUDIT_RETENTION_DATA_ACCESS_DAYS=180
AUDIT_RETENTION_SYSTEM_DAYS=90
AUDIT_PURGE_SCHEDULE="0 2 * * *"  # Daily at 02:00 (cron)
AUDIT_PURGE_DRY_RUN=false
```

---

## Risk Assessment

### Risk 1: Premature Deletion (Compliance Violation)

**Scenario:** Audit event deleted before retention period, needed for investigation.  
**Mitigation:**
- Purge script enforces retention dates (fail if date < period)
- Dry-run before any bulk delete
- Quarterly audit of purge logs

### Risk 2: Unbounded Storage Growth

**Scenario:** Retention policy not enforced; logs grow unchecked; storage costs explode.  
**Mitigation:**
- Automated purge job (mandatory)
- Monitoring alert if records exceed threshold
- Archive old events to cheaper storage

### Risk 3: Accidental Legal Hold Removal

**Scenario:** Legal hold flag cleared prematurely; evidence deleted.  
**Mitigation:**
- Legal hold can only be released by Legal/Compliance (access control)
- Audit trail of all hold changes
- Require approval from 2 roles (separation of duty)

### Risk 4: Data Subject Request Ignored

**Scenario:** User requests access logs; request is lost; no response.  
**Mitigation:**
- Ticket system tracks SARs (Service Access Requests)
- Automated response workflow
- SLA: Respond within 30 days
- Audit trail of all SARs

---

## References

- [EVENT_SCHEMA.md](./EVENT_SCHEMA.md) — Audit event structure
- [CORRELATION_ID_PATTERN.md](./CORRELATION_ID_PATTERN.md) — Request tracing
- [AUDIT_EVENT_CATALOG.md](./AUDIT_EVENT_CATALOG.md) — Per-system event definitions
- POPIA: Protection of Personal Information Act (South Africa)
- GDPR (if EU operations added)

---

## Version History

- **1.0** (Feb 2026): Initial retention policy specification, POPIA-aligned
