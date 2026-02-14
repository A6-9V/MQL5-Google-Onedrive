# GitLab CI/CD Quick Reference

Quick commands and references for working with GitLab CI/CD.

## 🚀 Quick Start

```bash
# 1. Setup GitLab repository (choose one)
git remote add gitlab git@gitlab.com:username/mql5-google-onedrive.git
git push gitlab main --all

# 2. Install glab CLI
brew install glab           # macOS
# or download from https://gitlab.com/gitlab-org/cli

# 3. Authenticate
glab auth login

# 4. Configure secrets
cp config/gitlab_vault.json.example config/gitlab_vault.json
# Edit config/gitlab_vault.json with your credentials
bash scripts/set_gitlab_secrets.sh gitlab_vault

# 5. Trigger pipeline
git push gitlab main
```

## 📋 Common Commands

### GitLab CLI (glab)

```bash
# View pipelines
glab ci view
glab ci list

# View specific pipeline
glab ci view 123456

# Trigger pipeline
glab ci run

# Cancel pipeline
glab ci cancel 123456

# Retry failed jobs
glab ci retry 123456

# View job logs
glab ci trace <job-id>

# List variables
glab variable list

# Set variable
glab variable set KEY "value" --masked --protected

# Delete variable
glab variable delete KEY
```

### Git Commands

```bash
# Add GitLab remote
git remote add gitlab git@gitlab.com:user/repo.git

# Push to GitLab
git push gitlab main

# Push all branches
git push gitlab --all

# Push tags
git push gitlab --tags

# Create and push tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push gitlab v1.0.0
```

## 🔧 Pipeline Management

### View Pipeline Status

```bash
# Web UI
https://gitlab.com/<username>/<repo>/-/pipelines

# CLI
glab ci view
```

### Manual Job Triggers

Jobs marked with `when: manual`:
1. Go to pipeline view
2. Click ▶️ play button on job
3. Or use CLI: `glab ci run --manual <job-name>`

### Download Artifacts

```bash
# Web UI: Pipeline → Job → Download artifacts

# CLI
glab ci artifact <job-id> <file-path>
```

## 🔐 Variables Management

### Set Variable (Web UI)

1. **Settings** → **CI/CD** → **Variables**
2. Click **Add variable**
3. Configure flags:
   - ✅ **Masked**: Hide in logs
   - ✅ **Protected**: Only on protected branches
   - ⬜ **Expand**: Allow variable references

### Set Variable (CLI)

```bash
# Basic variable
glab variable set MY_VAR "value"

# Masked variable
glab variable set SECRET "value" --masked

# Protected variable
glab variable set PROD_KEY "value" --protected

# Both masked and protected
glab variable set API_KEY "value" --masked --protected

# Environment-specific
glab variable set STAGING_URL "https://staging.example.com" --env staging
```

### Bulk Set Variables

```bash
# Using script
bash scripts/set_gitlab_secrets.sh gitlab_vault

# Or manually
while IFS='=' read -r key value; do
    glab variable set "$key" "$value" --masked
done < variables.txt
```

## 📦 Package & Release

### Create Release

```bash
# 1. Create tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push gitlab v1.0.0

# 2. Release job runs automatically
# 3. View release
glab release view v1.0.0

# 4. Manual release creation
glab release create v1.0.0 \
  --name "Release v1.0.0" \
  --notes "Release notes here" \
  --asset-link='{"name":"MT5 Package","url":"https://..."}'
```

### Download Artifacts

```bash
# MT5 Package
glab ci artifact <job-id> dist/Exness_MT5_MQL5.zip

# Or from web UI: Pipelines → Job → Artifacts → Download
```

## 🐳 Docker Registry

### Login to GitLab Registry

```bash
docker login registry.gitlab.com -u <username> -p <access-token>
```

### Pull Image

```bash
docker pull registry.gitlab.com/<username>/mql5-google-onedrive:latest
```

### Push Image (done by CI)

```bash
# Tagged by commit
docker push registry.gitlab.com/<username>/mql5-google-onedrive:<commit-sha>

# Latest
docker push registry.gitlab.com/<username>/mql5-google-onedrive:latest
```

## 🧪 Testing

### Validate Pipeline Locally

```bash
# Install gitlab-runner
brew install gitlab-runner  # macOS
# or https://docs.gitlab.com/runner/install/

# Run job locally
gitlab-runner exec docker validate:repository
gitlab-runner exec docker test:automation
gitlab-runner exec docker package:mt5
```

### Lint Pipeline Configuration

```bash
# Web UI: CI/CD → Pipeline Editor → Validate

# CLI
glab ci lint .gitlab-ci.yml

# Or using API
curl --header "PRIVATE-TOKEN: <token>" \
  "https://gitlab.com/api/v4/ci/lint" \
  --form "content=@.gitlab-ci.yml"
```

## 🔍 Debugging

### View Job Logs

```bash
# CLI
glab ci trace <job-id>

# Web UI
Pipeline → Click on job name
```

### Enable Debug Mode

In `.gitlab-ci.yml`:
```yaml
variables:
  CI_DEBUG_TRACE: "true"
```

Or per-job:
```yaml
job_name:
  variables:
    CI_DEBUG_TRACE: "true"
```

### Re-run Failed Jobs

```bash
# CLI
glab ci retry <pipeline-id>

# Web UI
Pipeline → Retry failed
```

## 📊 Monitoring

### Pipeline Status

```bash
# List recent pipelines
glab ci list

# View specific pipeline
glab ci view <pipeline-id>

# Pipeline status badge (add to README)
[![Pipeline Status](https://gitlab.com/<username>/<repo>/badges/main/pipeline.svg)](https://gitlab.com/<username>/<repo>/-/pipelines)
```

### Job Logs

```bash
# View logs
glab ci trace <job-id>

# Follow logs (live)
glab ci trace <job-id> --follow
```

## 🌐 Environments

### View Environments

```bash
# Web UI: Deployments → Environments

# CLI
glab environment list
```

### Deploy to Environment

```bash
# Staging (manual)
glab ci run --manual deploy:staging

# Production (manual, tags only)
glab ci run --manual deploy:production
```

## 📝 Pipeline Configuration

### Common Job Patterns

#### Only run on main branch
```yaml
rules:
  - if: '$CI_COMMIT_BRANCH == "main"'
```

#### Only run on tags
```yaml
rules:
  - if: '$CI_COMMIT_TAG'
```

#### Only run on merge requests
```yaml
rules:
  - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
```

#### Manual trigger
```yaml
rules:
  - if: '$CI_COMMIT_BRANCH == "main"'
    when: manual
```

## 🛠️ GitLab Runner Management

### View Runners

```bash
# Web UI: Settings → CI/CD → Runners

# List all runners (if you're admin)
glab runner list
```

### Register Runner

```bash
sudo gitlab-runner register \
  --url https://gitlab.com \
  --registration-token <token> \
  --executor docker \
  --docker-image python:3.12-slim \
  --tag-list "mql5,python,docker"
```

### Manage Runner

```bash
# Start
sudo gitlab-runner start

# Stop
sudo gitlab-runner stop

# Restart
sudo gitlab-runner restart

# Status
sudo gitlab-runner status

# List configured runners
sudo gitlab-runner list
```

## 📚 Useful Links

- **GitLab Docs**: https://docs.gitlab.com/ee/ci/
- **glab CLI**: https://gitlab.com/gitlab-org/cli
- **GitLab Runner**: https://docs.gitlab.com/runner/
- **CI/CD Variables**: https://docs.gitlab.com/ee/ci/variables/
- **Pipeline Reference**: https://docs.gitlab.com/ee/ci/yaml/

## 🔗 Related Files

- `.gitlab-ci.yml` - Main CI/CD configuration
- `.get-config.yml` - GitLab Environment Toolkit config
- `config/gitlab_vault.json.example` - Secrets template
- `scripts/set_gitlab_secrets.sh` - Secrets setup script
- `docs/GITLAB_CI_CD_SETUP.md` - Detailed setup guide
- `docs/API_ENVIRONMENT_SECRETS.md` - API credentials guide

---

**Quick Help**: For detailed setup, see [GitLab CI/CD Setup Guide](GITLAB_CI_CD_SETUP.md)
