---
name: interview_questions
description: Assessment questions to gauge readiness for AWX and identify knowledge gaps
metadata:
  node_type: memory
  type: feedback
  date: 2026-10-06
  purpose: readiness_assessment
  originSessionId: 0d69d1f7-66af-4e85-b054-946cd369aa26
  modified: 2026-10-06T20:49:56.450Z
---

## Assessment Questions

Answer these thoughtfully before starting Session 2. These are NOT pass/fail — they show where your knowledge is strong and where we should focus deeper training.

### Question 1: `group_vars/` Purpose

**What is the purpose of `group_vars/` in Ansible?**

**Context you've experienced:**
- You created `inventories/group_vars/webservers.yml` with encrypted secrets
- You created `inventories/group_vars/env_dev.yml` with SSH credentials
- Ansible automatically applied these variables to hosts in those groups

**What to think about:**
- How does Ansible know which variables to apply to which hosts?
- Why not just put all variables in the inventory file?
- How does this scale when you have 100 groups with different configs?

**Answer:**

[Your answer here]

---

### Question 2: Idempotency Importance

**Why is idempotency important in automation?**

**Context you've experienced:**
- Your webserver playbook returned `changed=0` on second run
- Nothing re-installed, no services restarted unnecessarily
- Running it 10 times had the same result as running it once

**What to think about:**
- What could go wrong if a playbook is NOT idempotent?
- Imagine running this playbook at 2am via a scheduled job
- Imagine someone accidentally running it manually twice
- In production with 500 servers?

**Answer:**

[Your answer here]

---

### Question 3: Static vs Dynamic Inventory

**What's the difference between static and dynamic inventory?**

**Context you've experienced:**
- Static: `inventories/dev.yml` with manually-listed hosts
- Dynamic: `inventories/aws_ec2.yml` querying AWS in real-time

**What to think about:**
- What happens if you launch a new EC2 instance with the static inventory?
- What happens with the dynamic inventory?
- At what scale does static inventory become a problem?
- What are the tradeoffs (pros and cons of each)?

**Answer:**

[Your answer here]

---

### Question 4: Secrets in CI/CD

**How would you handle secrets in a CI/CD pipeline?**

**Context:**
- You use Ansible Vault with `--ask-vault-pass` locally
- But a CI/CD pipeline can't interactively enter a password
- Your CI/CD system needs to deploy infrastructure automatically

**What to think about:**
- How would a GitHub Actions workflow decrypt your vault file?
- What are the security implications?
- How would AWX handle this?
- What are alternatives to Vault?

**Answer:**

[Your answer here]

---

## How to Submit Your Answers

When ready for Session 2:
1. Write your answers above (replace `[Your answer here]`)
2. Save this file
3. Show it to your mentor
4. Mentor will evaluate depth of understanding and adjust training accordingly

---

## Evaluation Criteria (For Mentor)

**Strong answer shows:**
- Understanding of the "why" not just the "what"
- Thinking about production scenarios
- Awareness of tradeoffs
- Connecting to real experience from this session

**Weak answer shows:**
- Only regurgitating documentation
- No connection to practical experience
- Missing the broader context
- Surface-level understanding

---

## Hints (Use only if stuck)

**Hint for Q1:**
Think: "If I have 50 groups and each needs different NTP servers, SSL certificates, and firewall rules, where do I put that configuration so it's maintainable?"

**Hint for Q2:**
Think: "What if a playbook that creates users was NOT idempotent, and it ran twice?"

**Hint for Q3:**
Think: "In 2 years, your company might have 1000 EC2 instances. How would you manage inventory?"

**Hint for Q4:**
Think: "GitHub Actions runs in a container. How does it get the vault password? How does it avoid storing the password in the repo?"
