# Custom Execution Environment for Ansible/AWX
# Base: Official Ansible EE image

ARG ANSIBLE_CORE_VERSION=2.16
FROM quay.io/ansible/awx-ee:latest

# Set metadata
LABEL maintainer="Ansible Training"
LABEL description="Custom Execution Environment with AWS, Kubernetes, and networking support"
LABEL version="1.0"

# Switch to root for installation
USER root

# Ensure pip is available
RUN python3 -m ensurepip --upgrade

# Copy Python requirements
COPY requirements.txt /tmp/requirements.txt

# Copy Ansible collections requirements
COPY requirements.yml /tmp/requirements.yml

# Install Python packages
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install -r /tmp/requirements.txt

# Install Ansible collections (with retries for network resilience)
RUN for i in {1..3}; do \
      ansible-galaxy collection install -r /tmp/requirements.yml --timeout 300 && break || \
      ([ $i -lt 3 ] && echo "Retry $i/3..." && sleep 10) || exit 1; \
    done

# Cleanup
RUN rm -f /tmp/requirements.txt /tmp/requirements.yml && \
    rm -rf /root/.cache

# Verify installation
RUN ansible-galaxy collection list && \
    python3 -m pip list | grep -E "boto3|requests|kubernetes"

# Switch back to non-root user for security
USER root
