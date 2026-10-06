# Training Resume — Session 1

**Date:** 2026-10-06  
**Trainer:** Senior Ansible/AWX Mentor (Claude Haiku 4.5)  
**Trainee:** You  
**Current Level:** Level 1.5 → Level 2 (60% complete)  

---

## What We Accomplished Today

### 1. Professional Ansible Repository ✅

Created `ansible-automation` with production-grade structure:

```
ansible-automation/
├── .gitignore              # Security: Python, IDE, SSH keys, vault
├── README.md               # Project documentation
├── ansible.cfg             # Ansible configuration
├── inventories/
│   ├── dev.yml             # Static inventory (Ubuntu instance)
│   ├── staging.yml         # Template for future use
│   ├── prod.yml            # Template for future use
│   ├── aws_ec2.yml         # Dynamic AWS EC2 inventory
│   └── group_vars/
│       ├── webservers.yml  # ENCRYPTED vault file with secrets
│       └── env_dev.yml     # SSH credentials for dynamic group
├── playbooks/
│   ├── setup_common.yml    # Deploy common tools
│   ├── setup_webserver.yml # Deploy Nginx
│   └── deploy_to_aws.yml   # Deploy via dynamic inventory
└── roles/
    ├── common/             # Common tools (curl, git, vim)
    └── webserver/          # Nginx installation & config
```

**Git commits:**
- `21fa8ac` — Add common and webserver roles with Nginx deployment
- `9c2deaf` — Add vault-encrypted variables and group structure

### 2. Reusable Roles ✅

**`roles/common/`** — OS-aware package installation
- Detects OS (Debian vs RedHat) automatically
- Installs curl, git, vim
- Idempotent: running multiple times = same result

**`roles/webserver/`** — Production Nginx deployment
- Installs Nginx package
- Generates config from Jinja2 template with variables
- Manages service (start, enable)
- Uses handlers to restart only when config changes
- Idempotent: verified by running playbook twice

### 3. Secrets Management with Vault ✅

- Created `group_vars/webservers.yml` with credentials
- Encrypted with `ansible-vault encrypt`
- Decrypted at runtime with `--ask-vault-pass`
- Verified variables loaded correctly via `ansible-inventory --list`

**Files encrypted:** Database password, API keys, SSL cert paths

### 4. Static Inventory ✅

- Created `inventories/dev.yml` with host and group structure
- Used `group_vars/` for automatic variable inheritance
- Set up SSH credentials and Python interpreter
- Tested connectivity: `ansible all -m ping` ✅

### 5. Dynamic AWS Inventory ✅

- Created `inventories/aws_ec2.yml` with AWS EC2 plugin
- Configured region: `eu-west-3`
- Tag-based automatic grouping: `Environment` and `Role`
- EC2 instance auto-discovered from AWS
- Groups created: `@env_dev`, `@role_webserver`
- Tested connectivity through dynamic inventory ✅

### 6. Playbook Execution ✅

**Via Static Inventory:**
```bash
ansible-playbook -i inventories/dev.yml playbooks/setup_webserver.yml
# Result: Nginx installed, running, and accessible
```

**Via Dynamic Inventory:**
```bash
ansible-playbook -i inventories/aws_ec2.yml playbooks/deploy_to_aws.yml
# Result: Both common and webserver roles deployed successfully
```

**Idempotency verified:** Running playbooks multiple times = `changed=0` on second run

---

## Production Skills Learned

✅ Professional repository structure for teams  
✅ Role design for reusability at scale  
✅ Secrets management (never commit passwords)  
✅ Static vs dynamic inventory concepts  
✅ AWS EC2 auto-discovery  
✅ Jinja2 templating for configurations  
✅ Handlers for efficient resource management  
✅ Idempotent automation (critical for production)  
✅ Git version control of infrastructure code  
✅ Troubleshooting methodology  

---

## Current AWS Environment

**Instance running:**
```
Public DNS: ec2-13-38-83-237.eu-west-3.compute.amazonaws.com
Private IP: 172.31.15.169
OS: Ubuntu 22.04 LTS
Instance Type: t2.micro (free tier)
Region: eu-west-3
Tags: Environment=dev, Role=webserver
SSH: ubuntu user, ~/.ssh/my-key.pem key
```

**Services running on instance:**
- Nginx web server (port 80)
- SSH server (port 22)

---

## Assessment: Ready for Next Level?

You will answer 4 interview questions:

1. **What is the purpose of `group_vars/` in Ansible?**
2. **Why is idempotency important in automation?**
3. **What's the difference between static and dynamic inventory?**
4. **How would you handle secrets in a CI/CD pipeline?**

**Location:** See `/home/abdelhak_unix/.claude/projects/-home-abdelhak-unix-github-awx/memory/interview_questions.md`

These answers will determine whether we:
- Deep-dive into advanced Ansible topics (loops, conditionals, error handling, blocks)
- Continue with real-world multi-tier deployment scenarios
- Jump directly to AWX deployment and configuration

---

## Next Session Plan

### Before Starting (5 min)

1. Read `training_progress.md` (where we left off)
2. Read `mentor_instructions.md` (remember training philosophy)
3. Review interview questions

### Session 2 Structure (Depends on Your Answers)

**Option A: Deep Ansible (if answers show gaps)**
- Vault password files (non-interactive automation)
- Variable precedence and scope
- Conditionals: `when:` statements
- Loops: `loop`, `with_items`
- Error handling: `failed_when`, `changed_when`
- Block execution

**Option B: Real-World Scenario (if answers are strong)**
- Create multi-role application deployment
- Build database, app_server, load_balancer roles
- Create orchestration playbook
- Implement environment-specific configs

**Option C: AWX Jump (if answers demonstrate mastery)**
- Jump directly to AWX deployment
- Start Level 2/3

The trainer will assess your answers and adapt.

---

## Important Reminders

### Security

🔒 **Vault password:** Currently `vault123` (lab only, never production)  
🔒 **AWS credentials:** Never commit `~/.aws/credentials`  
🔒 **SSH keys:** Never commit `~/.ssh/my-key.pem`  
🔒 **Secrets in code:** NEVER hardcode passwords, API keys, etc.

### AWS Costs

💰 **Running EC2 instance incurs charges** (even small ones add up)  
💰 Remember to stop/terminate when not using  
💰 Use free tier responsibly

### Version Awareness

⚠️ Ansible 2.16.3 (AWS collection has non-blocking warning)  
⚠️ Ubuntu 26.04 LTS (very new, some tools may need updates)  
⚠️ Always check official docs for version compatibility

---

## How to Resume Tomorrow

1. **Read these files in order:**
   - `TRAINING_RESUME.md` (this file)
   - `/memory/training_progress.md`
   - `/memory/interview_questions.md`
   - `/memory/mentor_instructions.md`

2. **Answer the 4 interview questions:**
   - Write answers in `interview_questions.md`
   - Show them to your mentor at session start

3. **Start fresh at Session 2:**
   - Mentor will assess your answers
   - Adapt training path accordingly
   - Pick up where you left off

---

## Git Commands Reference

If you need to review what you've built:

```bash
# See project structure
tree -L 2

# See Git commits
git log --oneline

# See current changes
git status

# View a specific file
cat roles/webserver/tasks/main.yml

# View encrypted vault file
ansible-vault view inventories/group_vars/webservers.yml
# Password: vault123
```

---

## Congratulations! 🎉

You've completed the foundation of production Ansible automation. You're now 60% through Level 1 and ready to learn advanced concepts or jump to AWX.

Your next task: **Answer the 4 assessment questions thoughtfully.**

See you tomorrow for Session 2!

---

**Maintained by:** Senior Ansible/AWX Mentor  
**Last updated:** 2026-10-06  
**Next update:** After Session 2 assessment  
