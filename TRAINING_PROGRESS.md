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

**Progress: ~50% of Level 1 → Level 2**

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
- EC2 instance running: `ec2-13-38-83-237.eu-west-3.compute.amazonaws.com`
- Instance ID: i-* (ubuntu 22.04 LTS, t2.micro)
- Tags applied: `Environment=dev`, `Role=webserver`
- SSH key: `~/.ssh/my-key.pem`
- SSH user: `ubuntu`
- Region: `eu-west-3`

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

## Next Steps (PRIORITY ORDER)

### Session 2: Deep Dive into Ansible (Before AWX)

**1. Answer assessment questions** (see: interview_questions.md)
   - Gauge readiness for AWX
   - Identify knowledge gaps

**2. Advanced Ansible Topics** (if ready)
   - Ansible Vault password files (avoid `--ask-vault-pass` in automation)
   - Variables: precedence, fact caching
   - Conditionals: `when:` statements, complex logic
   - Loops: `loop`, `with_items`, etc.
   - Error handling: `failed_when`, `changed_when`, `ignore_errors`
   - Block execution

**3. Real-World Scenario: Multi-tier Application Deployment**
   - Create roles: `database`, `app_server`, `load_balancer`
   - Create a workflow playbook that deploys all three
   - Use variables for configuration across environments
   - Implement rollback logic

**4. Git Integration**
   - Move ansible-automation repo to real Git hosting (GitHub/GitLab)
   - Set up SSH key authentication
   - Practice branches and merges

### Session 3: AWX Introduction

**Prerequisites:** Complete assessment questions with strong answers

**Topics:**
- What is AWX?
- How AWX differs from Ansible CLI
- AWX components: web UI, API, task execution, database
- Projects vs Playbooks vs Job Templates vs Workflows
- Organizations, Users, Teams, RBAC
- Credentials management in AWX

**First AWX Task:**
- Deploy AWX in a Kubernetes environment (Kind or k3s)
- Create first Organization/User/Team
- Connect Git project (your ansible-automation repo)
- Create first Job Template
- Execute a job

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

## Tomorrow's Start

1. Read this file
2. Read mentor_instructions.md to recall the training philosophy
3. Answer the 4 interview questions (record your answers)
4. Then: Proceed with Session 2 based on assessment results
