# Session 4: Production Hardening - Assessment & Scenario

## Part 1: Assessment Questions

### Question 1: Execution Environments
**Why use custom Execution Environment instead of installing packages directly in playbooks?**

Using a custom Execution Environment (EE) is superior to installing packages in playbooks because:

1. **Reproducibility**: EEs are immutable containers built once and reused. Playbook-based installs are fragile—packages upgrade, repos change, causing drift over time.

2. **Performance**: Packages are pre-installed in the EE image. Jobs launch instantly without waiting for apt/pip downloads and compiles. At scale (hundreds of jobs/day), this saves hours.

3. **Dependency isolation**: EE bakes in specific versions (e.g., `boto3==1.28.0`, `ansible-core==2.15.0`). Playbook installs fight version conflicts across many jobs.

4. **Auditability**: EE Dockerfile is version-controlled and reviewed like code. Playbook installs are implicit, hidden, and audit-unfriendly.

5. **Security**: Images can be scanned for CVEs before pushing to registry. Playbook installs happen at job runtime—too late to prevent.

6. **Governance**: Admin can lock EE versions (e.g., teams must use `v2.0` until approved). Playbooks give teams free rein to install anything.

**Real example from this session:** Custom EE includes `requests`, `boto3`, AWS CLI, and Slack SDK pre-built. Playbooks just import them—no delay. If we'd installed via playbook, every health check job would spend 30s downloading libraries.

---

### Question 2: Notifications
**Design an alerting strategy for a mission-critical app (consider: severity levels, on-call, escalation, metrics).**

**Alerting Strategy for Mission-Critical App:**

**Severity Levels (4-tier):**
1. **CRITICAL** (P1): Service down, data loss risk, SLA breach imminent
   - Alert: SMS + Slack + PagerDuty (page on-call immediately)
   - Response time: 5 minutes
   - Example: Health check fails for 2 consecutive checks (12 minutes downtime)

2. **HIGH** (P2): Degraded service, SLA at risk
   - Alert: Email + Slack + PagerDuty
   - Response time: 15 minutes
   - Example: Response time > 5 seconds for 5 consecutive checks

3. **MEDIUM** (P3): Minor issues, degradation starting
   - Alert: Email + Slack
   - Response time: 1 hour
   - Example: Backup failed, but previous backup still valid

4. **LOW** (P4): FYI, no action needed immediately
   - Alert: Email only
   - Response time: Next business day
   - Example: Scheduled maintenance completed successfully

**On-Call Routing:**
```
Critical (P1)
  ├─ Try primary on-call (SMS + call)
  └─ After 10 min: escalate to manager (SMS + call)

High (P2)
  ├─ Slack notification (auto-acknowledged)
  └─ PagerDuty incident created
  
Medium/Low
  └─ Email only
```

**Metrics to Monitor:**
- Health check latency (p50, p99)
- Failed deployments (count, trend)
- Backup success rate (must be ≥99%)
- Job execution time (alert if > 2x baseline)
- AWX API errors (rate > 0.5%)

**Implementation in AWX:**
1. Create notification type per severity: `Critical Alerts`, `High Alerts`, `Email Only`
2. Attach to workflows:
   - Deploy workflow: Attach all 4 (critical if fail, high if slow, low if succeed)
   - Backup workflow: Attach critical + high (no medium—backup is non-blocking)
   - Health check: Attach high + medium (low-priority unless repeated failures)
3. Use conditional notifications: Only send "failure" alert if previous 2 jobs also failed (prevent alert fatigue)

**Example escalation rule:**
```
IF health_check fails 3 times in a row
  THEN trigger CRITICAL alert (page on-call)
ELSE IF health_check fails 1-2 times
  THEN trigger HIGH alert (Slack only)
```

---

### Question 3: Scheduling
**When would you schedule recurring jobs vs. use event-driven automation? Give examples.**

**Scheduling (Recurring Jobs):**
Use when you need predictable, regular operations independent of system state.

✅ **Examples:**
- **Health checks** (every 6 hours): Detect slow degradation even if no events occur
- **Backups** (nightly 2 AM): Fixed window minimizes impact, easy to predict recovery time
- **Log rotation** (daily midnight): Prevent disk fill, predictable maintenance window
- **License renewal checks** (weekly Monday): Catch expiration before it happens
- **Cost reports** (daily 6 AM): Regular visibility into spending trends

**Why scheduling works here:** These are "check-in" operations—we care about doing them *at specific times*, not in response to events. Missing a 6-hour health check window is itself a problem (we don't know if system is healthy).

---

**Event-Driven Automation:**
Use when actions must respond *immediately* to state changes, and timing is unpredictable.

✅ **Examples:**
- **Deploy on code push**: GitHub webhook → AWX (must trigger within seconds, can't wait for next scheduled check)
- **Auto-remediate on alert**: Monitoring system detects CPU > 80% → Scale-up job (must act in < 1 minute)
- **Auto-rollback on health check fail**: Health job fails → Immediately trigger rollback (can't wait 6 hours)
- **Slack command trigger**: Team member types `/deploy-staging` → AWX job (immediate feedback required)
- **Webhook from external system**: Payment gateway confirms transaction → Provision account (must be instant)

**Why event-driven works here:** Scheduling would be too slow (would miss the event entirely), or too wasteful (constantly polling for something that happens rarely).

---

**Hybrid Approach (Recommended for Mission-Critical):**
```
1. Schedule health checks every 6 hours (predictable visibility)
2. On health check FAILURE → Event-driven auto-remediation:
   - If reboot fixes it: auto-restart service + alert team
   - If restart fails: trigger CRITICAL alert + escalate to on-call
3. Schedule nightly backups (preventative)
4. On backup FAILURE → Event-driven alert (high priority, but no auto-fix)
```

This combines the reliability of scheduling with the responsiveness of events.

---

### Question 4: Backup & Disaster Recovery
**Define your RTO (Recovery Time Objective) and RPO (Recovery Point Objective). How would you verify backups?**

**For AWX Production System:**

**RTO (Recovery Time Objective): 2 hours**
- Acceptable downtime: AWX offline for max 2 hours before business impact
- Reasoning: Deployments queued during outage; teams blocked after 2 hours
- Constraint: Restore process must complete in < 2 hours (restoring 50 GB database = ~1 hour)

**RPO (Recovery Point Objective): 24 hours**
- Acceptable data loss: Lose at most 1 day of job history
- Reasoning: Job templates and playbooks are version-controlled in Git (no loss). Only job executions/logs at risk.
- Backup frequency: Nightly backups sufficient
- Constraint: If disaster at 11 PM, lose 23 hours of job logs; if at 1 AM, lose 1 hour

**Backup Verification Strategy:**

**1. Automated Verification (Weekly, runs after backup):**
```bash
# Step 1: Backup created and uploaded
$ kubectl exec awx-postgres-15-0 -- pg_dump -U awx awx | aws s3 cp - s3://awx-backup/awx_$(date +%Y%m%d).sql

# Step 2: Verify backup size (sanity check)
$ aws s3 ls s3://awx-backup/awx_YYYYMMDD.sql --region eu-west-3
# Expected: ~500 MB - 2 GB (if < 100 MB or > 5 GB, alert)

# Step 3: Restore to staging database & verify schema
$ CREATE DATABASE awx_staging;
$ psql awx_staging < awx_backup_YYYYMMDD.sql
$ psql awx_staging -c "SELECT COUNT(*) FROM django_content_type;" # Should return ~20+

# Step 4: Verify data integrity (spot check)
$ psql awx_staging -c "SELECT COUNT(*) FROM auth_user;" # Should be > 0
$ psql awx_staging -c "SELECT COUNT(*) FROM main_organization;" # Should be > 0
```

**2. Manual Monthly Restore Drill:**
- Restore latest backup to **staging cluster** (separate K8s namespace)
- Verify AWX UI loads in staging
- Run 2-3 jobs in staging to confirm playbooks work
- Document time taken (should be < 120 minutes for RTO compliance)
- Delete staging database

**3. Metrics to Track:**
- Backup success rate: Must be ≥99% (failing backups are worse than no backup)
- Backup age: Alert if > 26 hours old (approaching RPO)
- Restore test success: 100% (any failure → page on-call)

**4. Alerting Rules:**
```
IF backup fails
  SEND CRITICAL alert (RTO/RPO at risk)
  
IF backup age > 24 hours
  SEND HIGH alert (approaching RPO)
  
IF restore test fails
  SEND CRITICAL alert (DR procedure broken)
```

---

### Question 5: CI/CD Pipeline
**Describe a complete GitHub → AWX → Production pipeline. What are the stages?**

**End-to-End CI/CD Pipeline Architecture:**

```
┌──────────────────────────────────────────────────────────────────┐
│                        GITHUB → AWX → PROD                        │
└──────────────────────────────────────────────────────────────────┘

Stage 1: GITHUB COMMIT
├─ Developer commits playbooks to feature branch
├─ GitHub Actions runs on PR:
│  ├─ Lint: ansible-lint playbooks/
│  ├─ Syntax: ansible-playbook --syntax-check
│  ├─ Test: ansible-playbook -i test_inventory/ --check
│  └─ Pass? → Merge allowed
└─ Developer merges to main branch

Stage 2: GITHUB ACTIONS CI
├─ Trigger: Push to main
├─ Steps:
│  ├─ Lint & syntax check (same as PR)
│  ├─ Build EE: docker build -t ansible-ee-custom:$VERSION .
│  ├─ Push EE: docker push docker.io/username/ansible-ee-custom:$VERSION
│  ├─ Create git tag: v1.2.3
│  ├─ Create GitHub release with changelog
│  └─ Notify: Slack channel #deployments
└─ Output: EE image ready, code tagged

Stage 3: AWX PRE-DEPLOY VALIDATION
├─ Trigger: GitHub Actions calls AWX API
├─ Job: "Validate Playbook (Staging)" 
│  ├─ Uses latest EE (v1.2.3)
│  ├─ Targets staging inventory (dev environment)
│  ├─ Runs with --check flag (no changes applied)
│  └─ Success criteria: 0 failures, 0 errors
└─ If fails: Alert team, stop pipeline

Stage 4: DEPLOYMENT
├─ Trigger: Validation job succeeds
├─ Job: "Deploy to Production"
│  ├─ Target: prod_servers inventory
│  ├─ Playbook: deploy.yml (configures app, updates config)
│  ├─ Strategy: Rolling (1 server at a time, 30s health check between)
│  ├─ Backoff: If server fails health check, rollback to previous version
│  └─ Approval: Manual gate (approval from oncall engineer)
└─ During: Real-time output to Slack

Stage 5: POST-DEPLOY VERIFICATION
├─ Trigger: Deploy job completes
├─ Job: "Health Check (Immediate)"
│  ├─ Runs 2x in rapid succession (prove stability)
│  ├─ Checks: API responsive, DB reachable, metrics normal
│  ├─ If pass → Proceed to Stage 6
│  └─ If fail → Auto-rollback to Stage 6 (Rollback)
└─ Duration: ~5 minutes

Stage 6: AUTOMATED BACKUP
├─ Trigger: Health checks pass
├─ Job: "Backup Production Database"
│  ├─ Backup current version (known-good state)
│  ├─ Upload to S3
│  ├─ Verify backup integrity
│  └─ Store in: s3://prod-backups/v1.2.3-TIMESTAMP.sql
└─ Duration: ~15 minutes

Stage 7: MONITORING & ALERTING
├─ Trigger: All jobs complete
├─ Continuous monitoring (beyond pipeline):
│  ├─ Recurring health checks every 6 hours
│  ├─ Alert if anomalies detected
│  └─ Auto-remediate if possible
└─ Manual rollback available 24/7

OPTIONAL - Stage 8: SCHEDULED MAINTENANCE
├─ Every Saturday 2 AM (low-traffic window)
├─ Job: "Maintenance Deployment"
│  ├─ Run DB optimizations
│  ├─ Cleanup old logs
│  └─ Verify system health
└─ If fails: Alert on-call, do NOT retry automatically
```

---

**Failure Handling (Rollback Scenarios):**

```
IF linting fails
  → Stop, notify team in Slack #deployments, require manual fix

IF staging validation fails  
  → Stop, do NOT deploy, create GitHub issue, notify team

IF deployment fails (mid-roll)
  → Stop rolling, revert last server, alert on-call, wait for manual decision

IF health checks fail post-deploy
  → Auto-rollback to previous version, create incident, notify on-call

IF backup fails
  → Alert CRITICAL (disaster recovery broken), do NOT clean old backups
```

---

**Pipeline Characteristics:**

| Aspect | Value |
|--------|-------|
| **Trigger** | Push to main branch (automatic) |
| **Total duration** | ~45 minutes (CI + deploy + verify + backup) |
| **Rollback** | < 5 minutes (automated health-check failure) |
| **Approval gates** | 1 manual gate before production deploy |
| **Concurrency** | Sequential (each stage waits for previous) |
| **Notifications** | Slack updates at each stage |
| **Audit trail** | Git commits + AWX job history |

---

## Part 2: Real-World Scenario - Multi-Tier Deployment Workflow

### Scenario Setup

**Business Context:**
You're deploying a 3-tier web application to production:
- **Web tier** (3 servers): nginx + app server
- **Database tier** (1 server): PostgreSQL  
- **Monitoring** (1 server): Prometheus + Grafana

**Requirements:**
1. Deploy must happen in order: DB → Web → Monitoring
2. Health checks at each tier before proceeding
3. If any tier fails: rollback all
4. Success → backup database
5. Success → email notification to #ops team

### Implementation Plan

**Step 1: Create 3 Job Templates**

1. `Deploy DB` (playbook: deploy_database.yml)
   - Notification: HIGH severity
   - On success: Proceed to Deploy Web

2. `Deploy Web Tier` (playbook: deploy_web.yml)
   - Depends on: Deploy DB success
   - Notification: HIGH severity
   - On success: Proceed to Deploy Monitoring

3. `Deploy Monitoring` (playbook: deploy_monitoring.yml)
   - Depends on: Deploy Web success
   - Notification: HIGH severity
   - On success: Proceed to Backup

4. `Backup Database` (playbook: awx_backup.yml)
   - Depends on: Deploy Monitoring success
   - Notification: MEDIUM severity

**Step 2: Create Workflow**

In AWX UI:
- Create new Workflow: `Production Multi-Tier Deployment`
- Add jobs in sequence (not parallel):
  - Node 1: Deploy DB
  - Node 2: Deploy Web Tier (on success of Node 1)
  - Node 3: Deploy Monitoring (on success of Node 2)
  - Node 4: Backup Database (on success of Node 3)
- Link failure paths → Notification (alert team)

**Step 3: Add Health Checks**

Insert health check jobs between deploy steps:
- After Deploy DB: Job `Health Check - Database`
- After Deploy Web: Job `Health Check - Web`
- After Deploy Monitoring: Job `Health Check - Monitoring`

**Step 4: Attach Notifications**

- Success of entire workflow → Email `ops@company.com` + Slack `#deployment-success`
- Failure of any step → Email `oncall@company.com` + Slack `#deployment-alerts`

**Step 5: Test End-to-End**

1. Push dummy changes to GitHub (e.g., update README)
2. GitHub Actions triggers AWX workflow
3. Workflow runs all steps
4. Monitor AWX Jobs page for completion
5. Verify email notification received
6. Verify database backup created

---

## Success Checklist for Phase 6

- [x] Question 1: EE advantages explained
- [x] Question 2: Alerting strategy with severity levels
- [x] Question 3: Scheduling vs. event-driven comparison
- [x] Question 4: RTO/RPO defined with backup verification
- [x] Question 5: CI/CD pipeline stages with rollback handling
- [ ] Real-world workflow created in AWX (in progress)
- [ ] Workflow includes deploy → health check → backup chain
- [ ] Notifications attached to workflow
- [ ] End-to-end test: GitHub push → workflow completion
- [ ] Email notification verified
- [ ] Final commit created

---

## Next: Implement Real-World Scenario in AWX

The assessment answers above define the *strategy*. Next session, implement the workflow in AWX UI and test end-to-end.

