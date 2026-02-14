# GitLab CI/CD Setup Guide

This guide explains how to set up GitLab CI/CD for the MQL5 Trading System repository using GitLab Environment Toolkit (GET).

## Table of Contents

- [Prerequisites](#prerequisites)
- [GitLab Repository Setup](#gitlab-repository-setup)
- [CI/CD Pipeline Overview](#cicd-pipeline-overview)
- [Environment Variables & Secrets](#environment-variables--secrets)
- [GitLab Runner Setup](#gitlab-runner-setup)
- [GitLab Environment Toolkit (GET)](#gitlab-environment-toolkit-get)
- [Deployment Configuration](#deployment-configuration)
- [Testing the Pipeline](#testing-the-pipeline)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before setting up GitLab CI/CD, ensure you have:

1. **GitLab Account** - Create an account at [GitLab.com](https://gitlab.com)
2. **GitLab Repository** - Either create a new repository or mirror from GitHub
3. **GitLab Runner** - Access to GitLab shared runners or your own runner
4. **Docker** (Optional) - For containerized builds and deployments
5. **API Tokens** - For deployment to cloud platforms

## GitLab Repository Setup

### Option 1: Mirror from GitHub

If you're using GitHub as the primary repository:

1. **Create a new GitLab project**:
   - Go to GitLab → **New Project** → **Import Project**
   - Select **Repository by URL**
   - Enter your GitHub repository URL: `https://github.com/A6-9V/MQL5-Google-Onedrive.git`
   - Choose visibility level (Private recommended)

2. **Set up repository mirroring** (Optional):
   - Go to **Settings** → **Repository** → **Mirroring repositories**
   - Add GitHub URL with credentials
   - Enable "Mirror only protected branches"
   - Set up push mirroring to keep GitHub updated

### Option 2: Push Existing Repository

```bash
# Add GitLab as a remote
git remote add gitlab git@gitlab.com:your-username/mql5-google-onedrive.git

# Push to GitLab
git push gitlab main

# Optional: Push all branches
git push gitlab --all
```

## CI/CD Pipeline Overview

The `.gitlab-ci.yml` file defines a multi-stage pipeline:

### Pipeline Stages

1. **Validate** - Repository structure, scripts, and security checks
2. **Build** - Documentation and artifacts
3. **Test** - Automation tests
4. **Package** - MT5 files and Docker images
5. **Deploy** - Deploy to staging, production, and cloud platforms

### Key Jobs

| Job | Description | Trigger |
|-----|-------------|---------|
| `validate:repository` | Validates MQL5 files structure | Every push, MR |
| `validate:scripts` | Validates shell script syntax | Every push, MR |
| `validate:secrets` | Scans for accidentally committed secrets | Every push, MR |
| `test:automation` | Runs automation tests | Every push, MR |
| `package:mt5` | Creates MT5 source package | Main branch, tags, MR |
| `package:docker` | Builds Docker image | Main branch, tags |
| `deploy:staging` | Deploys to staging | Manual (main branch) |
| `deploy:production` | Deploys to production | Manual (tags only) |
| `deploy:cloud` | Deploys to cloud platforms | Manual |

## Environment Variables & Secrets

### Required Variables

Go to **Settings** → **CI/CD** → **Variables** and add:

#### Basic Configuration

| Variable | Value | Protected | Masked | Description |
|----------|-------|-----------|--------|-------------|
| `CI_REGISTRY` | `registry.gitlab.com` | No | No | GitLab Container Registry |
| `CI_REGISTRY_IMAGE` | Auto-generated | No | No | Your project's registry path |

#### Cloud Deployment (Optional)

| Variable | Value | Protected | Masked | Description |
|----------|-------|-----------|--------|-------------|
| `RENDER_API_KEY` | Your Render API key | Yes | Yes | For Render.com deployment |
| `RAILWAY_TOKEN` | Your Railway token | Yes | Yes | For Railway.app deployment |
| `FLY_API_TOKEN` | Your Fly.io token | Yes | Yes | For Fly.io deployment |
| `DOCKER_USERNAME` | Docker Hub username | No | No | For Docker Hub push |
| `DOCKER_PASSWORD` | Docker Hub token | Yes | Yes | For Docker Hub push |

#### API & Bot Configuration

| Variable | Value | Protected | Masked | Description |
|----------|-------|-----------|--------|-------------|
| `TELEGRAM_BOT_TOKEN` | Bot token from BotFather | Yes | Yes | Telegram bot authentication |
| `TELEGRAM_ALLOWED_USER_IDS` | Comma-separated IDs | Yes | No | Authorized users |
| `GEMINI_API_KEY` | Google Gemini API key | Yes | Yes | AI trade filtering |
| `JULES_API_KEY` | Jules AI API key | Yes | Yes | Alternative AI provider |
| `GITHUB_PAT` | GitHub Personal Access Token | Yes | Yes | For GitHub integration |

#### Cloudflare (Optional)

| Variable | Value | Protected | Masked | Description |
|----------|-------|-----------|--------|-------------|
| `CLOUDFLARE_ZONE_ID` | Your zone ID | Yes | No | Cloudflare zone |
| `CLOUDFLARE_ACCOUNT_ID` | Your account ID | Yes | No | Cloudflare account |
| `CLOUDFLARE_API_TOKEN` | API token | Yes | Yes | Cloudflare API access |
| `DOMAIN_NAME` | Your domain | No | No | Domain name |

### Setting Variables via GitLab CLI

If you have `glab` CLI installed:

```bash
# Install glab CLI
# macOS: brew install glab
# Linux: See https://gitlab.com/gitlab-org/cli

# Authenticate
glab auth login

# Set variables
glab variable set TELEGRAM_BOT_TOKEN "your_token_here" --masked --protected
glab variable set RENDER_API_KEY "your_key_here" --masked --protected
glab variable set FLY_API_TOKEN "your_token_here" --masked --protected
```

### Using the Automated Script

Create a `config/gitlab_vault.json` file (copy from example):

```bash
cp config/vault.json.example config/gitlab_vault.json
# Edit gitlab_vault.json with your credentials
```

Then use the script to sync secrets:

```bash
# Create a script to set GitLab variables
bash scripts/set_gitlab_secrets.sh gitlab_vault
```

## GitLab Runner Setup

### Using Shared Runners

GitLab.com provides free shared runners. Enable them:

1. Go to **Settings** → **CI/CD** → **Runners**
2. Enable **Shared runners**
3. View available runners and their tags

### Setting Up Your Own Runner

For better performance or specific requirements:

#### 1. Install GitLab Runner

**Ubuntu/Debian:**
```bash
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
sudo apt-get install gitlab-runner
```

**macOS:**
```bash
brew install gitlab-runner
```

**Docker:**
```bash
docker run -d --name gitlab-runner --restart always \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:latest
```

#### 2. Register the Runner

```bash
# Get registration token from Settings → CI/CD → Runners
sudo gitlab-runner register

# Follow prompts:
# - GitLab instance URL: https://gitlab.com
# - Registration token: [from GitLab]
# - Description: My MQL5 Runner
# - Tags: mql5,docker,python
# - Executor: docker
# - Default Docker image: python:3.12-slim
```

#### 3. Start the Runner

```bash
sudo gitlab-runner start
```

#### 4. Verify Runner

Check **Settings** → **CI/CD** → **Runners** to see your runner listed.

## GitLab Environment Toolkit (GET)

GitLab Environment Toolkit (GET) is a collection of tools for deploying GitLab in various environments.

### Installing GET

```bash
# Clone the GitLab Environment Toolkit
git clone https://gitlab.com/gitlab-org/gitlab-environment-toolkit.git
cd gitlab-environment-toolkit

# Install dependencies
terraform --version  # Should be >= 1.0
ansible --version    # Should be >= 2.9
```

### GET for CI/CD Runners

If you want to deploy a scalable runner infrastructure:

1. **Choose your platform** (AWS, GCP, Azure)
2. **Configure Terraform** for your environment
3. **Deploy runners** using GET automation

Example for AWS:

```bash
cd gitlab-environment-toolkit/terraform/environments/aws
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your settings

terraform init
terraform plan
terraform apply
```

### GET Configuration Files

Create `.get-config.yml` in your repository root:

```yaml
# GitLab Environment Toolkit Configuration
gitlab:
  version: "16.0"
  
runners:
  count: 2
  type: docker
  tags:
    - mql5
    - python
    - docker
  
deployment:
  staging:
    enabled: true
    url: "https://staging.example.com"
  production:
    enabled: true
    url: "https://production.example.com"
```

## Deployment Configuration

### Staging Deployment

Staging deployments are manual by default:

1. Go to **CI/CD** → **Pipelines**
2. Find your pipeline
3. Click the **play** button on `deploy:staging`

### Production Deployment

Production deployments require a tag:

```bash
# Create a release tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# In GitLab, manually trigger deploy:production
```

### Cloud Platform Deployment

Configure cloud platform credentials, then:

1. Ensure variables are set (`RENDER_API_KEY`, etc.)
2. Manual trigger `deploy:cloud` job
3. Monitor deployment logs

## Testing the Pipeline

### Local Testing with GitLab Runner

Test your pipeline locally before pushing:

```bash
# Install gitlab-runner locally
# Then run:
gitlab-runner exec docker validate:repository
gitlab-runner exec docker test:automation
gitlab-runner exec docker package:mt5
```

### Validate Configuration

```bash
# Install GitLab CI Linter
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  "https://gitlab.com/api/v4/ci/lint" \
  --form "content=@.gitlab-ci.yml"
```

Or use the web interface:
- Go to **CI/CD** → **Pipeline editor**
- Paste your `.gitlab-ci.yml` content
- Click **Validate**

### Running the Full Pipeline

1. Push changes to main branch or create a merge request
2. Go to **CI/CD** → **Pipelines**
3. View the running pipeline
4. Click on jobs to see logs

## Troubleshooting

### Common Issues

#### 1. Runner Not Picking Up Jobs

**Solution:**
- Check runner status: `sudo gitlab-runner status`
- Verify runner tags match job tags
- Check runner is enabled in GitLab UI

#### 2. Docker Permission Denied

**Solution:**
```bash
sudo usermod -aG docker gitlab-runner
sudo gitlab-runner restart
```

#### 3. Secret Not Found

**Solution:**
- Verify variable name matches exactly (case-sensitive)
- Check variable is not protected when running on unprotected branch
- Ensure variable is marked as "masked" if it contains sensitive data

#### 4. Package Upload Fails

**Solution:**
- Check artifact size limits: **Settings** → **CI/CD** → **General pipelines**
- Verify `dist/` directory exists and has correct permissions
- Check job artifacts path matches created files

#### 5. Docker Image Push Fails

**Solution:**
- Verify `CI_REGISTRY_IMAGE` variable is set
- Check container registry is enabled: **Settings** → **Packages and registries**
- Ensure Docker login credentials are correct

### Debug Mode

Enable debug mode for more verbose logs:

```yaml
variables:
  CI_DEBUG_TRACE: "true"
```

Or set per job:

```yaml
job_name:
  variables:
    CI_DEBUG_TRACE: "true"
  script:
    - echo "Debug enabled"
```

### Getting Help

- **GitLab Documentation**: https://docs.gitlab.com/ee/ci/
- **GitLab Forum**: https://forum.gitlab.com/
- **GET Documentation**: https://gitlab.com/gitlab-org/gitlab-environment-toolkit
- **Support**: Open an issue in your repository

## Next Steps

After setting up GitLab CI/CD:

1. **Review the pipeline** - Check all jobs run successfully
2. **Configure notifications** - Set up Slack/email for pipeline status
3. **Set up environments** - Configure staging and production environments
4. **Enable auto-deployment** - For automatic deployments on main branch
5. **Monitor performance** - Use GitLab's CI/CD analytics

## Related Documentation

- [GitHub CI/CD Setup](GITHUB_CI_CD_SETUP.md) - GitHub Actions configuration
- [Cloud Deployment Guide](Cloud_Deployment_Guide.md) - Deploy to cloud platforms
- [Secrets Management](Secrets_Management.md) - Managing credentials securely
- [Release Process](RELEASE_PROCESS.md) - Creating releases

## Security Best Practices

1. **Never commit secrets** - Use GitLab CI/CD variables
2. **Enable protected branches** - Require reviews for main
3. **Use masked variables** - Hide sensitive values in logs
4. **Enable secret detection** - GitLab can auto-detect secrets
5. **Rotate credentials regularly** - Update tokens periodically
6. **Limit runner access** - Use project-specific runners when possible
7. **Enable dependency scanning** - Automatically scan for vulnerabilities

---

**Last Updated**: 2026-02-14  
**Version**: 1.0.0
