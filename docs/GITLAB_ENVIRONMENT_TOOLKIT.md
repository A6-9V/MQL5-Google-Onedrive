# GitLab Environment Toolkit (GET) Installation & Setup

Complete guide for installing and configuring GitLab Environment Toolkit for the MQL5 Trading System.

## Table of Contents

- [What is GitLab Environment Toolkit?](#what-is-gitlab-environment-toolkit)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)

## What is GitLab Environment Toolkit?

GitLab Environment Toolkit (GET) is a collection of tools from GitLab for deploying and managing GitLab instances and infrastructure. For this project, we use GET for:

- **GitLab Runner deployment**: Automated setup of CI/CD runners
- **Infrastructure as Code**: Terraform/Ansible based deployments
- **Scalable environments**: From development to production
- **Cloud-agnostic**: Works with AWS, GCP, Azure, and on-premise

**Official Repository**: https://gitlab.com/gitlab-org/gitlab-environment-toolkit

## Prerequisites

### Required Software

1. **Git** (>= 2.30)
   ```bash
   git --version
   ```

2. **Terraform** (>= 1.0)
   ```bash
   # macOS
   brew install terraform
   
   # Linux
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   
   # Verify
   terraform --version
   ```

3. **Ansible** (>= 2.9)
   ```bash
   # macOS
   brew install ansible
   
   # Ubuntu/Debian
   sudo apt update
   sudo apt install ansible
   
   # CentOS/RHEL
   sudo yum install ansible
   
   # Verify
   ansible --version
   ```

4. **Python 3** (>= 3.8)
   ```bash
   python3 --version
   pip3 --version
   ```

### Cloud Provider Setup (Choose One)

#### AWS
```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure credentials
aws configure
```

#### GCP
```bash
# Install gcloud SDK
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Authenticate
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

#### Azure
```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login
az login
```

## Installation

### Method 1: Clone GET Repository

```bash
# 1. Clone GitLab Environment Toolkit
cd /opt  # or your preferred location
sudo git clone https://gitlab.com/gitlab-org/gitlab-environment-toolkit.git
cd gitlab-environment-toolkit

# 2. Check out a stable version (recommended)
git checkout v3.0.0  # or latest stable version
git tag -l  # to see available versions

# 3. Verify installation
ls -la
```

### Method 2: Download Release

```bash
# Download specific release
wget https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/archive/v3.0.0/gitlab-environment-toolkit-v3.0.0.tar.gz

# Extract
tar -xzf gitlab-environment-toolkit-v3.0.0.tar.gz
cd gitlab-environment-toolkit-v3.0.0
```

## Configuration

### Step 1: Configure for Your Cloud Provider

#### AWS Example

```bash
cd terraform/environments/aws

# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit configuration
nano terraform.tfvars
```

Example `terraform.tfvars`:
```hcl
# AWS Configuration
aws_region = "us-east-1"
prefix     = "mql5-trading"

# GitLab Runner Configuration
gitlab_url = "https://gitlab.com"
runner_token = "YOUR_RUNNER_REGISTRATION_TOKEN"

# Runner specifications
runner_instance_type = "t3.medium"
runner_count        = 2

# Tags for runner
runner_tags = ["mql5", "python", "docker", "trading"]

# Executor type
runner_executor = "docker"
runner_docker_image = "python:3.12-slim"
```

#### GCP Example

```bash
cd terraform/environments/gcp

# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit configuration
nano terraform.tfvars
```

Example `terraform.tfvars`:
```hcl
# GCP Configuration
gcp_project = "your-project-id"
gcp_region  = "us-central1"
prefix      = "mql5-trading"

# GitLab Runner Configuration
gitlab_url = "https://gitlab.com"
runner_token = "YOUR_RUNNER_REGISTRATION_TOKEN"

# Runner specifications
runner_machine_type = "n1-standard-2"
runner_count       = 2

# Tags
runner_tags = ["mql5", "python", "docker"]
```

### Step 2: Initialize Terraform

```bash
# Initialize Terraform (downloads providers)
terraform init

# Validate configuration
terraform validate

# Preview changes
terraform plan
```

### Step 3: Configure GitLab Runner Registration

Get your runner registration token:

1. Go to GitLab: **Settings** → **CI/CD** → **Runners**
2. Click **New project runner** (or use existing registration token)
3. Copy the registration token
4. Add to your `terraform.tfvars`:
   ```hcl
   runner_token = "glrt-YOUR_REGISTRATION_TOKEN"
   ```

## Usage

### Deploy Infrastructure

```bash
# Apply Terraform configuration
terraform apply

# Confirm with 'yes' when prompted
```

This will:
- Create cloud resources (VMs, networks, etc.)
- Install GitLab Runner
- Register runners with your GitLab project
- Configure runners with specified tags and executors

### Verify Deployment

```bash
# Check Terraform state
terraform show

# List resources
terraform state list

# Get runner IP addresses
terraform output runner_ips
```

In GitLab:
1. Go to **Settings** → **CI/CD** → **Runners**
2. You should see your new runners listed
3. Check they are "online" (green dot)

### Trigger Pipeline

```bash
# Push to GitLab to trigger pipeline
git push gitlab main

# Or manually trigger
glab ci run
```

### Scale Runners

To add more runners:

```bash
# Edit terraform.tfvars
nano terraform.tfvars

# Change runner_count
runner_count = 4  # Increase from 2 to 4

# Apply changes
terraform apply
```

### Update Runners

```bash
# Pull latest GET changes
git pull origin main

# Re-apply configuration
terraform apply
```

## Ansible Playbooks (Advanced)

GET also includes Ansible playbooks for more granular control:

```bash
cd ansible

# List available playbooks
ls playbooks/

# Run a playbook
ansible-playbook -i inventory/hosts.yml playbooks/setup-runner.yml
```

Example inventory file:
```yaml
# inventory/hosts.yml
all:
  hosts:
    runner1:
      ansible_host: 10.0.1.10
      ansible_user: ubuntu
    runner2:
      ansible_host: 10.0.1.11
      ansible_user: ubuntu
  vars:
    gitlab_url: "https://gitlab.com"
    runner_token: "YOUR_TOKEN"
    runner_tags: "mql5,python,docker"
```

## Using Our .get-config.yml

The repository includes a `.get-config.yml` file with project-specific settings:

```bash
# Reference our configuration
cp /path/to/mql5-repo/.get-config.yml environments/custom/

# Use with Terraform
terraform plan -var-file="environments/custom/.get-config.yml"
```

## Cleanup

### Remove Infrastructure

```bash
# Destroy all resources
terraform destroy

# Confirm with 'yes' when prompted
```

This will:
- Deregister runners from GitLab
- Terminate cloud instances
- Delete networks and resources
- Clean up state

⚠️ **Warning**: This is permanent and cannot be undone!

## Troubleshooting

### Issue: Terraform Init Fails

**Solution**:
```bash
# Clear cache
rm -rf .terraform
rm .terraform.lock.hcl

# Re-initialize
terraform init
```

### Issue: Runner Not Appearing in GitLab

**Check**:
1. Verify registration token is correct
2. Check runner logs:
   ```bash
   # SSH into runner
   ssh ubuntu@<runner-ip>
   
   # View logs
   sudo journalctl -u gitlab-runner -f
   ```
3. Verify network connectivity:
   ```bash
   curl https://gitlab.com
   ```

### Issue: Terraform Apply Fails

**Common causes**:
- Insufficient cloud permissions
- Quota limits exceeded
- Invalid configuration

**Debug**:
```bash
# Enable debug logging
export TF_LOG=DEBUG
terraform apply
```

### Issue: Runner Out of Disk Space

**Solution**:
```bash
# SSH to runner
ssh ubuntu@<runner-ip>

# Check disk usage
df -h

# Clean Docker
docker system prune -a --volumes -f

# Or update Terraform to use larger disk
# In terraform.tfvars:
runner_disk_size = 100  # GB
terraform apply
```

## Best Practices

1. **Use separate environments**: Development, staging, production
2. **Version control**: Keep `terraform.tfvars` in version control (without secrets)
3. **Use remote state**: Store Terraform state in S3/GCS
4. **Enable autoscaling**: For variable workloads
5. **Monitor costs**: Cloud resources cost money
6. **Regular updates**: Keep GET and runners updated
7. **Backup configurations**: Save working configurations

## Alternative: Manual Runner Setup

If you don't need full GET, you can setup runners manually:

```bash
# Install GitLab Runner
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
sudo apt-get install gitlab-runner

# Register runner
sudo gitlab-runner register \
  --non-interactive \
  --url "https://gitlab.com/" \
  --registration-token "YOUR_TOKEN" \
  --executor "docker" \
  --docker-image "python:3.12-slim" \
  --description "MQL5 Runner" \
  --tag-list "mql5,python,docker" \
  --run-untagged="false" \
  --locked="false"

# Start runner
sudo gitlab-runner start
```

See [GitLab CI/CD Setup Guide](GITLAB_CI_CD_SETUP.md) for detailed runner setup.

## Resources

- **GET Repository**: https://gitlab.com/gitlab-org/gitlab-environment-toolkit
- **GET Documentation**: https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/tree/main/docs
- **GitLab Runner Docs**: https://docs.gitlab.com/runner/
- **Terraform Docs**: https://www.terraform.io/docs
- **Ansible Docs**: https://docs.ansible.com/

## Related Documentation

- [GitLab CI/CD Setup](GITLAB_CI_CD_SETUP.md) - Main CI/CD guide
- [GitLab Quick Reference](GITLAB_QUICK_REFERENCE.md) - Quick commands
- [API Environment Secrets](API_ENVIRONMENT_SECRETS.md) - Secrets management

---

**Last Updated**: 2026-02-14  
**Version**: 1.0.0
