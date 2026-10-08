---
name: training_progress
description: "Current training level, completed milestones, next steps, and assessment"
metadata:
  node_type: memory
  type: project
  date: 2026-10-06
  current_level: Level 1.5 → Level 2 transition
  originSessionId: 0d69d1f7-66af-4e85-b054-946cd369aa26
  modified: 2026-10-06T20:49:45.962Z
---

## Current Status

**Progress: Level 3 - Advanced AWX Complete ✓**

**Last Session:** 2026-10-08 (Session 3 - Advanced AWX: Dynamic Inventory, RBAC, Workflows)

**Current Level:** 3.0/23 (13% through full curriculum)

### Completed Milestones

✅ **Repository Structure**
- Professional Ansible project layout created
- Git initialized with meaningful commits
- `.gitignore` configured with security considerations

✅ **Reusable Roles**
- `common` role: installs packages, OS-aware (apt/yum)
- `webserver` role: Nginx installation, templating, handlers, idempotency
- Both roles tested successfully on EC2

✅ **Secrets Management**
- Vault encryption implemented
- Encrypted `group_vars/webservers.yml` with database credentials, API keys
- Successfully decrypted at runtime with `--ask-vault-pass`
- Inventory reorganized to `inventories/` with `group_vars/` for dynamic loading

✅ **Static Inventory**
- `inventories/dev.yml` with proper group structure
- Groups mapped to variable files via `group_vars/`
- Variables inherited by group members

✅ **Dynamic AWS Inventory**
- `inventories/aws_ec2.yml` implemented
- EC2 instances auto-discovered from AWS
- Tag-based grouping: `Environment` and `Role` tags
- Group variables applied via `inventories/group_vars/env_dev.yml`
- Playbooks successfully target dynamic groups

✅ **Playbook Execution**
- `playbooks/setup_common.yml` deployed via static inventory
- `playbooks/setup_webserver.yml` tested for idempotency
- `playbooks/deploy_to_aws.yml` deployed via dynamic inventory

### Environment Setup

**AWS:**
- EC2 instance running: `35.181.9.168` (ubuntu 22.04 LTS, t2.medium)
- Instance ID: i-* (7.6GB RAM, 2 vCPU)
- Tags applied: `Environment=dev`, `Role=webserver`
- SSH key: `~/.ssh/my-key.pem`
- SSH user: `ubuntu`
- Region: `eu-west-3`

**Kubernetes & AWX:**
- k3s installed: v1.36.5+k3s1
- AWX deployed via Operator in `awx` namespace
- AWX URL: `http://35.181.9.168:32752`
- AWX admin: `admin` / `AWXpassword123`
- Database: PostgreSQL 15 (persistent)
- Cache: Redis 7

**Local Ansible Setup:**
- Ansible 2.16.3
- AWS collection installed: `amazon.aws`
- Version warning exists but non-blocking
- `ansible.cfg` configured with role paths and inventory defaults

**Project Structure:**
```
ansible-automation/
├── README.md
├── .gitignore
├── ansible.cfg
├── inventories/
│   ├── dev.yml (static inventory)
│   ├── staging.yml (template only)
│   ├── prod.yml (template only)
│   ├── aws_ec2.yml (dynamic AWS inventory)
│   └── group_vars/
│       ├── webservers.yml (vault-encrypted)
│       └── env_dev.yml (dynamic inventory vars)
├── playbooks/
│   ├── setup_common.yml
│   ├── setup_webserver.yml
│   └── deploy_to_aws.yml
└── roles/
    ├── common/
    │   ├── tasks/main.yml (apt/yum update, package install)
    │   └── defaults/main.yml (curl, git, vim)
    └── webserver/
        ├── tasks/main.yml (nginx install, config, service management)
        ├── handlers/main.yml (restart nginx)
        ├── defaults/main.yml (nginx_port: 80, server_name: localhost)
        └── templates/nginx.conf.j2 (valid nginx config with events block)
```

### Git Commits

```
9c2deaf (HEAD -> main) Add vault-encrypted variables and group structure
21fa8ac Add common and webserver roles with Nginx deployment
```

### Skills Demonstrated

- Ansible inventory design (static and dynamic)
- Role creation with tasks, handlers, templates
- Jinja2 templating for configuration files
- Vault encryption for secrets
- AWS EC2 dynamic inventory with tag-based grouping
- Idempotent playbook design
- Git version control of infrastructure code
- Troubleshooting (fixed nginx config syntax, inventory path issues)
- Production mindset (secrets, idempotency, proper structure)

---

## Session 2 Completed ✓

### Accomplished in Session 2

**Assessment Questions:** Answered all 4 questions correctly ✓
- Demonstrated production-thinking (idempotency, secrets, scalability)
- Ready for AWX

**AWX Deployment:** Deployed on k3s (Kubernetes) ✓
- k3s v1.36.5 installed on EC2
- AWX Operator deployed successfully
- AWX running with PostgreSQL + Redis
- Admin user created

**AWX First Steps:** Created all core components ✓
1. **Project** — Connected GitHub repo (zagani212/ansible-automation)
2. **Credentials** — SSH key stored encrypted in AWX
3. **Inventory** — Static inventory with EC2 instance (15.237.143.97)
4. **Job Template** — `Deploy Webserver` configured
5. **First Job Run** — Successfully executed `playbooks/deploy_to_aws.yml`
   - Deployed Nginx to EC2
   - Output: `ok=7 changed=4` (idempotent playbook)
   - Verified with curl: Nginx responding

**Understanding Demonstrated:**
- SSH keys stored securely (encrypted in AWX DB, not in repo)
- Idempotency explained correctly (2nd run = `changed=0`)
- RBAC awareness (users don't need SSH keys)
- Audit trail importance (jobs logged)

---

## Session 3 Completed ✓

### Accomplished in Session 3

**Phase 1: AWS Credentials & Dynamic Inventory** ✓
- Created AWS credential in AWX
- Built dynamic inventory discovering **4 EC2 instances** from AWS
- Configured tag-based auto-grouping (`aws_env_dev`, `aws_role_webserver`)
- Created job template targeting dynamic inventory
- Successfully deployed to 4 instances via dynamic discovery

**Phase 2: RBAC - Role-Based Access Control** ✓
- Created organization: "Lab Operations"
- Created team: "App Deployment Team" with Execute role
- Created limited user: "deploy_user" / "DeployPass123"
- Tested RBAC: limited user sees ONLY authorized template
- Verified credentials remain secure (not visible to limited users)
- Tested job launch by limited user - successful

**Phase 3: Workflows** ✓
- Created verification job template: `Verify Deployment`
- Built workflow: Start → Deploy → Verify (sequential execution)
- Added approval gate: Start → Deploy → Approval → Verify
- Tested approval workflow:
  - Deploy runs automatically
  - Workflow pauses at approval
  - Manual approval required to continue
  - Verification runs after approval
  - All steps completed successfully

**Phase 4: Multi-Environment Deployment** ✓
- Created staging AWS credential: "AWS Staging Credentials"
- Created staging dynamic inventory: "AWS Staging Inventory"
- Created "Deploy to Staging" job template
- Built multi-environment workflow: Start → Deploy Lab → Approval → Deploy Staging → Verify
- Tested workflow:
  - Dev deployment runs automatically
  - Approval required before staging
  - Staging deployment runs after approval
  - Verification runs after staging deployment
  - Workflow completed successfully with all 5 steps

### AWX Components Created (Session 3)

**Organizations:**
- Lab Operations (new)

**Teams:**
- App Deployment Team (Lab Operations org, Execute role on Deploy to AWS Lab Dynamic)

**Users:**
- deploy_user (normal user, assigned to App Deployment Team)

**Credentials:**
- AWS Lab Credentials (existing from Phase 1)
- AWS Staging Credentials (new)

**Inventories:**
- AWS EC2 Lab Inventory (dynamic, eu-west-3, tag-based grouping)
- AWS Staging Inventory (dynamic, eu-west-3, tag-based grouping)

**Job Templates:**
- Deploy to AWS Lab (Dynamic) (targets lab inventory)
- Verify Deployment (verification/test job)
- Deploy to Staging (targets staging inventory)

**Workflows:**
- Multi-Stage Deployment Workflow (Deploy → Approval → Verify)
- Multi-Environment Deploy (Deploy Lab → Approval → Deploy Staging → Verify)

### Skills Demonstrated (Session 3)

✅ AWS credential management in AWX  
✅ Dynamic inventory with tag-based grouping  
✅ Organization and team creation  
✅ RBAC implementation and testing  
✅ Permission scoping (Execute role on specific templates)  
✅ Workflow design with multi-step orchestration  
✅ Approval gates for production safety  
✅ Multi-environment deployment patterns  
✅ Audit trail and approval tracking  
✅ Limited user access and security validation  

---

## Current Environment After Session 3

**AWS:**
- 4 EC2 instances in eu-west-3
- All tagged with Environment and Role tags
- Nginx deployed to all instances

**AWX:**
- URL: `http://35.181.9.168:32752`
- 1 Organization (Lab Operations)
- 1 Team with limited permissions
- 3 Users (admin, deploy_user, + default)
- 4 AWS credentials configured
- 2 Dynamic inventories with tag-based grouping
- 3 Job templates
- 2 Workflows with approval gates

---

## Next Steps (Session 4+)

### Session 3: Advanced AWX (Credentials, RBAC, Workflows)

**1. AWS Dynamic Inventory**
   - Configure AWS credential (access key/secret)
   - Create dynamic inventory that discovers EC2 by tags
   - Auto-group instances by environment

**2. Advanced Credentials**
   - Multiple credential types (Machine, Vault, AWS, GitHub, etc.)
   - Create GitHub token for private repos
   - Credential scoping and permissions

**3. RBAC (Role-Based Access Control)**
   - Organizations, Teams, Users
   - Permissions model: who can run what
   - Create team with limited playbook access

**4. Workflows**
   - Multi-step deployments (database → app → verification)
   - Approval gates (human approval before prod)
   - Error handling in workflows

### Session 4: Production Hardening

**1. Execution Environments**
   - Custom Python packages for playbooks
   - Custom Ansible collections

**2. Job Scheduling**
   - Schedule jobs to run on intervals
   - Recurring deployments

**3. Approvals & Safety**
   - Require approval before prod jobs
   - Notification integration

**4. Backup & Disaster Recovery**
   - Backup AWX database
   - Restore procedures

### Session 5-7: Real-World Scenarios

**Multi-environment deployment:**
- Deploy app to dev/staging/prod via AWX
- Different credentials per environment
- Approval gates for production

**Integration with CI/CD:**
- Trigger AWX jobs from GitHub Actions
- AWX API for automation

---

## Assessment Questions (MUST ANSWER BEFORE CONTINUING)

Before Session 2, answer these:

1. **What is the purpose of `group_vars/` in Ansible?**

2. **Why is idempotency important in automation?**

3. **What's the difference between static and dynamic inventory?**

4. **How would you handle secrets in a CI/CD pipeline?**

(See interview_questions.md for hints and context)

---

## Important Notes

- **Vault password:** Currently using `vault123` for lab (NEVER use in production)
- **AWS credentials:** Using local `~/.aws/credentials` (NEVER commit to Git)
- **SSH keys:** `~/.ssh/my-key.pem` (NEVER commit to Git)
- **Instance lifespan:** EC2 instance will incur charges; remember to stop/terminate if not using
- **Ansible version:** 2.16.3 (AWS collection has non-blocking warning)

---

## Resources

- Ansible documentation: https://docs.ansible.com/
- AWS dynamic inventory: https://docs.ansible.com/ansible/latest/collections/amazon/aws/
- Vault docs: https://docs.ansible.com/ansible/latest/user_guide/vault.html
- AWX project: https://github.com/ansible/awx

---

## Session 3 Resume (Tomorrow)

1. Read TRAINING_RESUME.md (this session's summary)
2. Review this file (current status)
3. Start with advanced AWX credentials
4. Create AWS credential for dynamic inventory
5. Build dynamic inventory that discovers EC2 by tags
6. Test workflow with multiple playbooks

**Production Mindset Check:**
- "How would you handle secrets in a real production environment?"
- "Show me the AWS credential configuration"
- "Create a job that can only be run by approved users"
