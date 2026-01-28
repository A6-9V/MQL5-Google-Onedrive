# GitHub CI/CD Setup for Docker Dev Deployment

This guide explains how to set up GitHub Actions for automated Docker development deployment.

## Prerequisites

1. **GitHub Account**: Your GitHub account
2. **Docker Desktop** installed and running
3. **GitHub Repository** with Actions enabled

## Step 1: Configure GitHub Secrets

Go to your repository → **Settings** → **Secrets and variables** → **Actions**

### Required Secrets

Add the following secrets:

#### 1. GitHub Token (Auto-generated)
- **Name**: `GITHUB_TOKEN`
- **Value**: Automatically provided by GitHub Actions
- **Note**: No action needed, already available

#### 2. Docker Hub Credentials (Optional)
If deploying to Docker Hub:
- **Name**: `DOCKER_USERNAME`
- **Value**: Your Docker Hub username
- **Name**: `DOCKER_PASSWORD`
- **Value**: Your Docker Hub password/token

#### 3. Fly.io Token (For cloud deployment)
- **Name**: `FLY_API_TOKEN`
- **Value**: Get from `flyctl auth token` or Fly.io dashboard

#### 4. Email Credentials (For notifications)
- **Name**: `GITHUB_EMAIL`
- **Value**: your-email@example.com
- **Name**: `GITHUB_PASSWORD`
- **Value**: [YOUR_PASSWORD]
- **Note**: ⚠️ **SECURITY WARNING** - Use GitHub Personal Access Token instead of password!

### Recommended: Use Personal Access Token

Instead of using your password, create a GitHub Personal Access Token:

1. Go to: https://github.com/settings/tokens
2. Click **Generate new token (classic)**
3. Select scopes:
   - `repo` (Full control of private repositories)
   - `workflow` (Update GitHub Action workflows)
   - `write:packages` (Upload packages to GitHub Container Registry)
4. Copy the token
5. Add as secret:
   - **Name**: `GH_PAT`
   - **Value**: Your personal access token

## Step 2: Enable GitHub Actions

1. Go to repository → **Settings** → **Actions** → **General**
2. Enable:
   - ✅ Allow all actions and reusable workflows
   - ✅ Allow actions to create and approve pull requests
3. Save changes

## Step 3: Configure Self-Hosted Runner (For Docker Desktop)

If you want to deploy to your local Docker Desktop:

### Option A: Use GitHub-hosted Runner (Recommended)

The workflow will build the image, but deployment to Docker Desktop requires a self-hosted runner.

### Option B: Set Up Self-Hosted Runner

1. **Download runner**:
   ```powershell
   # Create folder
   mkdir actions-runner
   cd actions-runner

   # Download (Windows)
   Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-win-x64-2.311.0.zip -OutFile actions-runner-win-x64.zip

   # Extract
   Expand-Archive -Path actions-runner-win-x64.zip -DestinationPath .
   ```

2. **Configure runner**:
   ```powershell
   .\config.cmd --url https://github.com/YOUR_USERNAME/MQL5-Google-Onedrive --token YOUR_TOKEN
   ```

3. **Run as service**:
   ```powershell
   .\run.cmd
   ```

## Step 4: Workflow Files

The following workflows are configured:

### 1. `ci-cd-docker-dev.yml`
- Builds Docker dev image
- Runs tests
- Deploys to GitHub Container Registry
- Triggers on push to `main` or `develop`

### 2. `docker-dev-desktop.yml`
- Builds Docker dev image
- Deploys to Docker Desktop (requires self-hosted runner)
- Can be triggered manually

## Step 5: Test the Workflow

1. **Make a change** to trigger the workflow:
   ```powershell
   git add .
   git commit -m "Test CI/CD workflow"
   git push origin develop
   ```

2. **Check workflow status**:
   - Go to repository → **Actions** tab
   - Click on the running workflow
   - Monitor build and deployment steps

## Step 6: Manual Deployment

You can also trigger workflows manually:

1. Go to **Actions** tab
2. Select workflow (e.g., "Docker Dev Desktop Deployment")
3. Click **Run workflow**
4. Select branch and options
5. Click **Run workflow**

## Troubleshooting

### Workflow Fails to Start

- Check if Actions are enabled in repository settings
- Verify workflow file syntax (YAML)
- Check branch protection rules

### Docker Build Fails

- Verify `Dockerfile.dev` exists
- Check Docker syntax
- Review build logs in Actions tab

### Deployment Fails

- Ensure Docker Desktop is running (for local deployment)
- Check self-hosted runner status
- Verify secrets are set correctly

### Authentication Errors

- Verify GitHub token has correct permissions
- Check if secrets are set correctly
- Ensure email/password are correct (or use PAT)

## Security Best Practices

1. ✅ **Use Personal Access Token** instead of password
2. ✅ **Never commit secrets** to repository
3. ✅ **Use environment-specific secrets**
4. ✅ **Review workflow permissions** regularly
5. ✅ **Enable branch protection** for main branch

## Next Steps

- [Development Container Setup](./DEV_CONTAINER_SETUP.md)
- [Cloud Deployment Guide](./CLOUD_DEPLOYMENT.md)
- [Local Development Guide](./LOCAL_DEVELOPMENT.md)

## Support

If you encounter issues:
1. Check GitHub Actions logs
2. Verify all secrets are set
3. Ensure Docker Desktop is running
4. Review workflow file syntax
