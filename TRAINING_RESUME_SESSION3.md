# Training Resume — Session 3

**Date:** 2026-10-08  
**Trainer:** Senior Ansible/AWX Mentor (Claude Haiku 4.5)  
**Trainee:** You  
**Current Level:** Level 3.0 (Advanced AWX - Complete ✓)  

---

## What We Accomplished Today (Session 3)

### 1. AWS Dynamic Inventory ✅

**Setup:**
- Created AWS credential in AWX with access key/secret
- Built dynamic inventory source that auto-discovers EC2 instances
- Configured tag-based auto-grouping (Environment, Role tags)
- Discovered 4 EC2 instances from AWS

**Result:** 
- Inventory auto-discovers 2-4 instances
- Tag-based groups created: `aws_env_dev`, `aws_role_webserver`
- Groups automatically populated based on EC2 tags

### 2. Dynamic Inventory Job Execution ✅

**Template:** "Deploy to AWS Lab (Dynamic)"
- Targets AWS EC2 Lab Inventory (dynamic)
- Runs playbooks/deploy_to_aws.yml
- Deployed Nginx to all 4 discovered instances

**Result:**
```
Deploy Job Output:
- 4 instances discovered dynamically
- Nginx installed on all 4
- Services started and enabled
- Idempotent: running again = changed=0
```

### 3. Role-Based Access Control (RBAC) ✅

**Organization:**
- Name: "Lab Operations"
- Purpose: Container for teams and users

**Team:**
- Name: "App Deployment Team"
- Organization: Lab Operations
- Permissions: Execute role on "Deploy to AWS Lab (Dynamic)" template ONLY

**User:**
- Username: deploy_user
- Password: DeployPass123
- Type: Normal User
- Team: App Deployment Team

**RBAC Testing:**
- Logged in as deploy_user
- Verified: Can see ONLY "Deploy to AWS Lab (Dynamic)" template
- Verified: CANNOT access Settings/Administration
- Verified: CANNOT see credentials list
- Verified: CAN launch the authorized template successfully
- Verified: Admin user sees ALL templates and full access

**Key Finding:** Limited users cannot modify templates even if they can add credentials (because credentials are pre-configured in templates)

### 4. Workflows with Approval Gates ✅

**Workflow 1: Multi-Stage Deployment Workflow**
```
Start → Deploy to AWS Lab (Dynamic) → Approval → Verify Deployment
```

**Workflow 2: Multi-Environment Deploy**
```
Start → Deploy to AWS Lab (Dynamic) → Approval → Deploy to Staging → Verify Deployment
```

**Approval Gate Details:**
- Prompt: "Approve deployment to staging?"
- Timeout: 3600 seconds (1 hour)
- Workflow pauses and waits for manual approval
- User must explicitly approve to continue
- If denied: workflow stops

**Testing Results:**
- Dev deployment runs automatically ✓
- Workflow pauses at approval ✓
- Manual approval required ✓
- After approval, staging deployment runs ✓
- Verification runs after staging ✓
- Audit trail records who approved and when ✓

### 5. Multi-Environment Setup ✅

**Staging Credential:**
- Name: "AWS Staging Credentials"
- Same AWS keys (simulates different account in production)

**Staging Inventory:**
- Name: "AWS Staging Inventory"
- Dynamic source with tag-based grouping
- Discovers same 4 instances (in prod: different AWS account)

**Staging Job Template:**
- Name: "Deploy to Staging"
- Targets "AWS Staging Inventory"
- Uses same playbook, different target environment

---

## Production Skills Learned (Session 3)

✅ AWS credential management in centralized system  
✅ Dynamic inventory auto-discovery  
✅ Tag-based resource grouping at scale  
✅ Organization/Team/User hierarchy  
✅ Fine-grained RBAC (role-based access control)  
✅ Permission scoping to specific resources  
✅ Workflow orchestration (multi-step automation)  
✅ Approval gates for production safety  
✅ Multi-environment deployment patterns  
✅ Audit trail for compliance  
✅ Testing RBAC boundaries  

---

## Current AWX Setup

**URL:** http://35.181.9.168:32752

**Organizations:**
- Default
- Lab Operations

**Teams:**
- App Deployment Team (Execute on Deploy to AWS Lab Dynamic)

**Users:**
- admin / AWXpassword123 (full access)
- deploy_user / DeployPass123 (limited - template only)

**Credentials:**
- AWS Lab Credentials
- AWS Staging Credentials
- AWS EC2 SSH Key

**Inventories:**
- AWS EC2 Lab Inventory (dynamic, 4 instances)
- AWS Staging Inventory (dynamic)

**Job Templates:**
- Deploy to AWS Lab (Dynamic)
- Verify Deployment
- Deploy to Staging

**Workflows:**
- Multi-Stage Deployment Workflow
- Multi-Environment Deploy

---

## Key Understanding Demonstrated

**Question 1: Why is RBAC important?**
- Answer: Prevents mistakes by limiting who can run what
- **Correct.** You verified that deploy_user could only see/run one template
- **Production mindset:** Separation of concerns - deployment team doesn't need admin access

**Question 2: Workflows vs. single templates?**
- Answer: Workflows chain multiple jobs; templates run single playbook
- **Correct.** Saw benefit when approval gate paused workflow between dev/staging
- **Demonstrated:** Multi-step deployment with conditional progression

**Question 3: Approval gate pattern use case?**
- Answer: Manual approval before production changes
- **Correct.** You tested approval gate stopping workflow until approved
- **Production safety:** Human oversight before staging/production

**Question 4: Dynamic vs. Static inventory at scale?**
- Answer: Dynamic discovers instances automatically; static is manual list
- **Correct.** Saw 4 instances auto-discovered without manual entry
- **Scaling awareness:** Dynamic scales to 100s-1000s of instances

**Assessment:** 100% ready for Session 4 (Production Hardening)

---

## Session 4 Preview

### Topics (not covered yet)

**1. Execution Environments (30 min)**
   - Custom Python packages
   - Custom Ansible collections
   - Build custom execution environment image

**2. Job Scheduling (20 min)**
   - Schedule jobs to run on intervals
   - Recurring deployments (daily, weekly)

**3. Notifications (20 min)**
   - Slack, email notifications
   - Alert on job success/failure

**4. Backup & Disaster Recovery (20 min)**
   - Backup AWX database
   - Restore procedures
   - Disaster recovery planning

**5. Advanced: CI/CD Integration (optional)**
   - Trigger AWX jobs from GitHub Actions
   - AWX API usage

---

## Session 3 Success Metrics

- [x] Phase 1: AWS Dynamic Inventory (45 min) ✓
- [x] Phase 2: RBAC Implementation (40 min) ✓
- [x] Phase 3: Workflows with Approval (40 min) ✓
- [x] Phase 4: Multi-Environment Setup (30 min) ✓
- [x] All workflows tested and working ✓
- [x] RBAC tested and verified ✓
- [x] Approval gates functional ✓

**Total Session Time:** ~2.5 hours  
**Difficulty:** Intermediate/Advanced  
**Concepts Mastered:** RBAC, Workflows, Multi-environment, Approval gates

---

## How to Resume for Session 4

1. **Read these files:**
   - This file (TRAINING_RESUME_SESSION3.md)
   - TRAINING_PROGRESS.md (current status)

2. **Access AWX:**
   - URL: http://35.181.9.168:32752
   - Login: admin / AWXpassword123

3. **Verify current state:**
   - Check that workflows are saved
   - Test one workflow to confirm still operational
   - Review team permissions

4. **Start Session 4:**
   - Pick up with Execution Environments
   - Build custom Python environment
   - Schedule first recurring job

---

## Important Reminders

### Security

🔒 **Credentials:** Never commit AWS keys to Git  
🔒 **SSH Keys:** Keep ~/.ssh/my-key.pem private  
🔒 **AWX Secrets:** Database credentials and vault passwords are sensitive  
🔒 **User Passwords:** deploy_user password is lab-only, never production  

### AWS Costs

💰 **4 EC2 instances running** - incur charges  
💰 **Remember to stop/terminate** when not in use  
💰 **Monitor AWS billing** to avoid surprise charges  

### Concepts to Review Before Session 4

⚠️ Custom Python packages in execution environments  
⚠️ Job scheduling patterns (cron-like)  
⚠️ Notification integrations  
⚠️ Database backup/restore procedures  

---

## Git Status After Session 3

```bash
git log --oneline
# Should show Session 2 commits

git status
# Should be clean (no uncommitted changes)
```

If you've made changes to playbooks/inventories:
```bash
git add -A
git commit -m "Session 3: Add staging environment and workflows"
```

---

## Congratulations! 🎉

You've mastered:
- Production-grade RBAC
- Multi-step workflow orchestration
- Approval-driven deployments
- Multi-environment infrastructure automation

**You're now at Level 3.0 — Ready for production hardening.**

See you in Session 4 for Execution Environments and Job Scheduling!

---

**Maintained by:** Senior Ansible/AWX Mentor  
**Last updated:** 2026-10-08  
**Next session:** Session 4 (Production Hardening)
