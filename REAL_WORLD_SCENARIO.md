# Session 4: Real-World Scenario - Multi-Tier Production Deployment

## Overview

This scenario demonstrates an enterprise-grade multi-tier application deployment using AWX, combining all production hardening concepts from Session 4:

- ✅ Custom Execution Environment
- ✅ Notifications (email + Slack)
- ✅ Health checks at each tier
- ✅ Automatic backups post-deployment
- ✅ GitHub Actions integration
- ✅ Workflow automation and chaining

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Multi-Tier Application                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Database Tier (PostgreSQL)                                      │
│  ├─ 1 server running PostgreSQL 15                              │
│  ├─ appdb database with appuser account                         │
│  └─ Backup to S3 after deployment                               │
│                                                                  │
│  Web Tier (Nginx + App)                                         │
│  ├─ 3 servers (rolling deployment)                              │
│  ├─ Nginx reverse proxy to app on :8080                         │
│  └─ Health checks between server updates                        │
│                                                                  │
│  Monitoring Tier (Prometheus + Grafana)                         │
│  ├─ 1 server aggregating metrics                                │
│  ├─ Prometheus on :9090, Grafana on :3000                       │
│  └─ Node Exporter on all servers (:9100)                        │
│                                                                  │
│  Notifications                                                  │
│  ├─ Email: ops@company.com (success), oncall@company.com (fail) │
│  └─ Slack: #deployment-success, #deployment-alerts             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Playbooks Created

All playbooks are idempotent and test-safe (use `--check` mode):

| Playbook | Host Group | Purpose | Status |
|----------|-----------|---------|--------|
| `deploy_database.yml` | db_servers | Install/configure PostgreSQL | ✅ Ready |
| `deploy_web_tier.yml` | web_servers | Deploy app tier (rolling) | ✅ Ready |
| `deploy_monitoring.yml` | monitoring_servers | Deploy Prometheus + Grafana | ✅ Ready |
| `health_check_database.yml` | db_servers | Verify DB connectivity | ✅ Ready |
| `health_check_web.yml` | web_servers | Verify app health | ✅ Ready |
| `health_check_monitoring.yml` | monitoring_servers | Verify metrics collection | ✅ Ready |
| `awx_backup.yml` | localhost | Backup AWX DB to S3 | ✅ Existing |

---

## Step-by-Step AWX Setup

### Step 1: Create Inventory

In AWX, create a new **Inventory** called `Production Multi-Tier`:

```
[db_servers]
db-prod-01.example.com

[web_servers]
web-prod-01.example.com
web-prod-02.example.com
web-prod-03.example.com

[monitoring_servers]
monitoring-prod-01.example.com

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/var/lib/awx/.ssh/id_rsa
```

**Note:** Replace hostnames with your actual servers or IP addresses.

---

### Step 2: Create Credentials

Create these credentials in AWX:

1. **Machine Credential: `Production SSH Key`**
   - Type: Machine
   - Username: `ubuntu`
   - Private key: (your SSH private key)

2. **Vault Credential (Optional): `Database Credentials`**
   - For storing `DB_PASSWORD` securely

3. **AWS Credential (Optional): `AWS S3 Backups`**
   - Access key + secret key for backup uploads

---

### Step 3: Create Project

Create a new **Project** called `Ansible Automation - Session 4`:
- SCM Type: Git
- Repository URL: `https://github.com/YOUR_USERNAME/ansible-automation.git`
- Execution Environment: `Custom EE v1.0` (from previous session)

---

### Step 4: Create Job Templates

Create 7 job templates as shown below:

#### Job Template 1: `Deploy Database`
- Name: `Deploy Database`
- Project: `Ansible Automation - Session 4`
- Playbook: `playbooks/deploy_database.yml`
- Inventory: `Production Multi-Tier`
- Credentials: `Production SSH Key`
- Execution Environment: `Custom EE v1.0`
- Concurrency: 1 (serial execution)
- **On Success:** Link to `Health Check - Database`
- **On Failure:** Send "Failed" notification → oncall@company.com

#### Job Template 2: `Health Check - Database`
- Name: `Health Check - Database`
- Project: `Ansible Automation - Session 4`
- Playbook: `playbooks/health_check_database.yml`
- Inventory: `Production Multi-Tier`
- Credentials: `Production SSH Key`
- Execution Environment: `Custom EE v1.0`
- **On Success:** Link to `Deploy Web Tier`
- **On Failure:** Send "Failed" notification → oncall@company.com, **STOP workflow**

#### Job Template 3: `Deploy Web Tier`
- Name: `Deploy Web Tier`
- Project: `Ansible Automation - Session 4`
- Playbook: `playbooks/deploy_web_tier.yml`
- Inventory: `Production Multi-Tier`
- Credentials: `Production SSH Key`
- Execution Environment: `Custom EE v1.0`
- Concurrency: 1 (serial execution - rolling deploy)
- **On Success:** Link to `Health Check - Web`
- **On Failure:** Send "Failed" notification, **STOP workflow**

#### Job Template 4: `Health Check - Web`
- Name: `Health Check - Web`
- Project: `Ansible Automation - Session 4`
- Playbook: `playbooks/health_check_web.yml`
- Inventory: `Production Multi-Tier`
- Credentials: `Production SSH Key`
- Execution Environment: `Custom EE v1.0`
- **On Success:** Link to `Deploy Monitoring`
- **On Failure:** Send "Failed" notification, **STOP workflow**

#### Job Template 5: `Deploy Monitoring`
- Name: `Deploy Monitoring`
- Project: `Ansible Automation - Session 4`
- Playbook: `playbooks/deploy_monitoring.yml`
- Inventory: `Production Multi-Tier`
- Credentials: `Production SSH Key`
- Execution Environment: `Custom EE v1.0`
- **On Success:** Link to `Health Check - Monitoring`
- **On Failure:** Send "Failed" notification, **STOP workflow**

#### Job Template 6: `Health Check - Monitoring`
- Name: `Health Check - Monitoring`
- Project: `Ansible Automation - Session 4`
- Playbook: `playbooks/health_check_monitoring.yml`
- Inventory: `Production Multi-Tier`
- Credentials: `Production SSH Key`
- Execution Environment: `Custom EE v1.0`
- **On Success:** Link to `Backup Database`
- **On Failure:** Send "Failed" notification, **STOP workflow**

#### Job Template 7: `Backup Database`
- Name: `Backup Database`
- Project: `Ansible Automation - Session 4`
- Playbook: `playbooks/awx_backup.yml`
- Inventory: `Localhost` (or any)
- Credentials: `AWS S3 Backups` (if available)
- Execution Environment: `Custom EE v1.0`
- **On Success:** Send "Success" notification
- **On Failure:** Send "Failed" notification

---

### Step 5: Create Workflow

In AWX, create a new **Workflow Template** called `Production Multi-Tier Deployment`:

**Workflow Nodes (in order):**

```
Node 1: Deploy Database
├─ On Success → Node 2
└─ On Failure → Node 9 (Failure Notification)

Node 2: Health Check - Database
├─ On Success → Node 3
└─ On Failure → Node 9

Node 3: Deploy Web Tier
├─ On Success → Node 4
└─ On Failure → Node 9

Node 4: Health Check - Web
├─ On Success → Node 5
└─ On Failure → Node 9

Node 5: Deploy Monitoring
├─ On Success → Node 6
└─ On Failure → Node 9

Node 6: Health Check - Monitoring
├─ On Success → Node 7
└─ On Failure → Node 9

Node 7: Backup Database
├─ On Success → Node 8 (Success Notification)
└─ On Failure → Node 9

Node 8: Success Notification
(Terminal node)

Node 9: Failure Notification
(Terminal node)
```

**Workflow Notifications:**

Attach to the workflow template:
- **Success notification:** Email `ops@company.com` + Slack `#deployment-success`
- **Failure notification:** Email `oncall@company.com` + Slack `#deployment-alerts`

---

### Step 6: Configure GitHub Actions Integration

Update `.github/workflows/deploy.yml` to trigger the new workflow:

```yaml
- name: Trigger AWX Workflow
  run: |
    curl -X POST \
      -H "Authorization: Bearer ${{ secrets.AWX_TOKEN }}" \
      -H "Content-Type: application/json" \
      -d '{"extra_vars": {"github_commit": "${{ github.sha }}", "github_branch": "${{ github.ref }}"}}' \
      http://13.37.248.85:32752/api/v2/workflow_templates/Production%20Multi-Tier%20Deployment/launch/
```

---

## Testing the End-to-End Pipeline

### Test 1: Dry-Run (No Changes)

```bash
# In AWX, for each job template, set:
# - Extra variables: --check=true
# Run the workflow once to verify all playbooks are valid
```

### Test 2: One-Tier Deploy

```bash
# Test database deployment only:
1. Go to AWX Jobs page
2. Click "Deploy Database" job template
3. Click Launch
4. Monitor output
5. Verify database deployed successfully
```

### Test 3: Full Workflow

```bash
# Test complete workflow:
1. Go to AWX Workflows page
2. Click "Production Multi-Tier Deployment"
3. Click Launch
4. Monitor each node as it completes
5. After all nodes complete, check:
   - AWX job history (7 jobs should be listed)
   - Email inbox (notification received)
   - Slack channels (#deployment-success or #deployment-alerts)
   - S3 bucket (backup file created)
```

### Test 4: Failure Scenario

```bash
# Test rollback behavior:
1. Temporarily make health_check_web.yml fail (e.g., health endpoint unavailable)
2. Launch workflow
3. Verify workflow stops at Health Check - Web
4. Verify failure notification sent
5. Verify subsequent nodes NOT executed
6. Verify manual rollback option available
```

---

## Monitoring the Workflow

### AWX Dashboard View

```
Workflows
├─ Production Multi-Tier Deployment
│  ├─ Last Run: 2026-10-13 14:23:45
│  ├─ Status: Successful
│  ├─ Duration: 45 min 32 sec
│  └─ Latest Job Runs:
│     ├─ Deploy Database: ✅ 5 min
│     ├─ Health Check - Database: ✅ 2 min
│     ├─ Deploy Web Tier: ✅ 12 min (rolling: 3 servers × 4 min)
│     ├─ Health Check - Web: ✅ 3 min
│     ├─ Deploy Monitoring: ✅ 10 min
│     ├─ Health Check - Monitoring: ✅ 2 min
│     └─ Backup Database: ✅ 6 min
```

### Key Metrics to Track

| Metric | Acceptable | Alert |
|--------|-----------|-------|
| Total workflow duration | < 1 hour | > 90 min |
| Deploy database | < 10 min | > 15 min |
| Deploy web tier | < 15 min | > 20 min |
| Health checks | < 5 min each | > 10 min |
| Backup time | < 10 min | > 15 min |
| Failure rate | 0% (prod) | Any failure |

---

## Troubleshooting

### Issue: Workflow fails at "Deploy Database"

```bash
# Check job output in AWX Jobs page
# Common causes:
1. SSH credentials incorrect → Verify "Production SSH Key" credential
2. PostgreSQL already running → Playbook is idempotent, should handle this
3. Database user conflict → Check pg_hba.conf permissions
4. Network issue → Verify DNS resolution for db-prod-01.example.com

# Debug command:
ansible-playbook -i production_multi_tier.ini playbooks/deploy_database.yml -vv
```

### Issue: Health checks pass, but app not responding

```bash
# Check health check output in AWX
# Common causes:
1. App not started on :8080 → Check nginx configuration
2. Firewall blocking :8080 → Verify security groups
3. Wrong health endpoint → Update health_check_web.yml endpoint URL

# Manual test:
curl http://web-prod-01.example.com:8080/health
```

### Issue: Backup fails

```bash
# Check awx_backup.yml output
# Common causes:
1. kubectl not in EE → Add to Dockerfile (see Session 4 blockers)
2. S3 credentials missing → Add "AWS S3 Backups" credential
3. S3 bucket doesn't exist → Create in AWS: s3://awx-bucket-backup-11-10-2026

# Manual backup:
kubectl exec -it awx-postgres-15-0 -n awx -- pg_dump -U awx awx > backup.sql
aws s3 cp backup.sql s3://awx-bucket-backup-11-10-2026/ --region eu-west-3
```

---

## Post-Deployment Verification

After a successful workflow run:

✅ **Database Tier**
```bash
psql -h db-prod-01 -U appuser -d appdb -c "SELECT COUNT(*) FROM information_schema.tables;"
```

✅ **Web Tier**
```bash
curl -I http://web-prod-01.example.com:8080/health
curl -I http://web-prod-02.example.com:8080/health
curl -I http://web-prod-03.example.com:8080/health
```

✅ **Monitoring Tier**
```bash
curl http://monitoring-prod-01:9090/-/healthy
curl http://monitoring-prod-01:3000/api/health
```

✅ **Backups**
```bash
aws s3 ls s3://awx-bucket-backup-11-10-2026/ --region eu-west-3
```

---

## Continuous Improvement

For future enhancements:

1. **Canary Deployments:** Deploy to 1 web server, run health checks, then deploy to remaining 2
2. **Automated Rollback:** If health checks fail 2x in a row, auto-trigger rollback job
3. **Blue-Green Deployment:** Maintain 2 production environments, switch on success
4. **Performance Validation:** Include performance benchmarks in health checks (response time, throughput)
5. **Cost Optimization:** Schedule non-production tiers to scale down after hours
6. **Multi-Region Deployment:** Extend workflow to deploy across AWS regions

---

## Success Criteria (Phase 6 Complete)

✅ All 7 job templates created  
✅ Workflow template created with proper sequencing  
✅ Notifications configured (email + Slack)  
✅ GitHub Actions integration updated  
✅ Dry-run test successful  
✅ Full workflow test successful (7/7 nodes passed)  
✅ Notifications verified  
✅ Backup confirmed in S3  
✅ Session 4 assessment completed  

---

## Next Steps

**Session 5 will cover:**
1. Real-World Multi-Tier Application (advanced deployments)
2. Advanced Playbook Patterns (handlers, loops, conditionals)
3. Error Handling in Workflows (failure branches, retries, recovery)
4. Performance Optimization (large inventory handling)

