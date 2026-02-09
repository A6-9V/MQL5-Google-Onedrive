# CD Workflow Guide

## Overview

The Continuous Deployment (CD) workflow automates the deployment of the MQL5 SMC + Trend Breakout Trading System across multiple platforms.

## Workflow File

**Location:** `.github/workflows/cd.yml`

## Triggers

The CD workflow is triggered by:

1. **Push to main branch** - Automatically deploys to all platforms
2. **Tag creation** (v*.*.*) - Creates a GitHub release with assets
3. **Manual dispatch** - Allows targeted deployment via GitHub Actions UI

## Deployment Targets

### 1. All (Default)
Deploys to all platforms:
- Builds MT5 package
- Builds Docker images
- Deploys to cloud platforms
- Deploys dashboard to GitHub Pages
- Creates release (if triggered by tag)

### 2. Docker
- Builds and pushes Docker images to GitHub Container Registry
- Tags: `latest`, version tags, branch tags

### 3. Cloud
- Deploys to Fly.io (if FLY_API_TOKEN configured)
- Notifies Render.com (auto-deploys via GitHub integration)
- Notifies Railway.app (auto-deploys via GitHub integration)

### 4. Dashboard
- Deploys dashboard to GitHub Pages
- Available at: https://[username].github.io/[repo]

### 5. Release
- Creates GitHub release with MT5 package
- Includes checksums and Docker images
- Extracts release notes from CHANGELOG.md

## Jobs Overview

### 1. validate
- Validates repository structure
- Checks shell script syntax
- Ensures code quality

### 2. build-mt5-package
- Packages MT5 indicators and Expert Advisors
- Generates SHA256 checksums
- Uploads artifacts

### 3. build-docker-images
- Builds multi-platform Docker images (amd64, arm64)
- Pushes to GitHub Container Registry
- Uses build cache for efficiency

### 4. deploy-cloud
- Deploys to cloud platforms
- Validates deployment configurations
- Executes platform-specific deployments

### 5. deploy-dashboard
- Deploys dashboard to GitHub Pages
- Configures GitHub Pages environment

### 6. create-release
- Creates GitHub release
- Attaches MT5 package and checksums
- Extracts changelog for release notes

### 7. deployment-summary
- Generates deployment summary
- Shows status of all jobs
- Lists available deployments

## Usage

### Automatic Deployment

Push to main branch:
```bash
git add .
git commit -m "Update feature"
git push origin main
```

### Manual Deployment

1. Go to repository → **Actions** tab
2. Select **CD - Continuous Deployment** workflow
3. Click **Run workflow**
4. Select:
   - **Branch**: main
   - **Deployment target**: Choose from dropdown
   - **Environment**: production or staging
5. Click **Run workflow**

### Create Release

Tag and push:
```bash
# Create annotated tag
git tag -a v1.22.0 -m "Release v1.22.0"

# Push tag
git push origin v1.22.0
```

This will:
1. Trigger CD workflow
2. Build and package MT5 files
3. Build Docker images
4. Create GitHub release
5. Upload release assets

## Environment Variables

### Required
- `GITHUB_TOKEN` - Auto-provided by GitHub Actions

### Optional (for cloud deployment)
- `FLY_API_TOKEN` - For Fly.io deployment
- `RENDER_API_KEY` - For Render.com API access
- `RAILWAY_TOKEN` - For Railway.app API access

## Permissions

The workflow requires:
- `contents: write` - Create releases, push tags
- `packages: write` - Push Docker images
- `pages: write` - Deploy to GitHub Pages
- `id-token: write` - GitHub Pages deployment

## Artifacts

The workflow produces:

1. **MT5 Package** (`mt5-package`)
   - `Exness_MT5_MQL5.zip`
   - `Exness_MT5_MQL5.zip.sha256`
   - Retention: 90 days

2. **Docker Images**
   - `ghcr.io/[owner]/[repo]:latest`
   - `ghcr.io/[owner]/[repo]:v[version]`
   - `ghcr.io/[owner]/[repo]:[branch]-[sha]`

## Monitoring

### Check Workflow Status

```bash
# List recent workflow runs
gh run list --workflow=cd.yml

# View specific run
gh run view [run-id]

# Watch run in real-time
gh run watch [run-id]
```

### View Deployment Summary

After workflow completes:
1. Go to Actions tab
2. Click on workflow run
3. View "Deployment Summary" step
4. See status of all components

## Troubleshooting

### Validation Fails
- Check `scripts/ci_validate_repo.py` output
- Ensure shell scripts have correct syntax
- Verify repository structure

### Docker Build Fails
- Check Dockerfile syntax
- Verify base image availability
- Review build logs

### Cloud Deployment Fails
- Verify API tokens are set in secrets
- Check platform-specific configurations
- Review deployment logs

### Release Creation Fails
- Ensure tag follows semantic versioning (v*.*.*)
- Check CHANGELOG.md format
- Verify permissions

## Best Practices

1. **Test locally** before pushing to main
2. **Update CHANGELOG.md** before creating releases
3. **Use semantic versioning** for tags
4. **Monitor deployments** via Actions tab
5. **Review deployment summary** after each run

## Integration with Other Workflows

The CD workflow complements:
- `ci.yml` - Continuous Integration
- `release.yml` - Dedicated release process
- `deploy-cloud.yml` - Standalone cloud deployment
- `deploy-dashboard.yml` - Standalone dashboard deployment

## Security Considerations

1. **Secrets Management**
   - Never commit secrets to repository
   - Use GitHub Secrets for sensitive data
   - Rotate tokens regularly

2. **Branch Protection**
   - Enable branch protection for main
   - Require reviews before merge
   - Require status checks to pass

3. **Container Security**
   - Scan Docker images for vulnerabilities
   - Use official base images
   - Keep dependencies updated

## Support

For issues or questions:
1. Check workflow logs in Actions tab
2. Review this documentation
3. Consult [CI/CD Setup Guide](GITHUB_CI_CD_SETUP.md)
4. Open an issue on GitHub

## Quick Reference

| Task | Command |
|------|---------|
| Manual deploy | Actions → CD workflow → Run workflow |
| Create release | `git tag -a vX.Y.Z -m "..."` then `git push origin vX.Y.Z` |
| View runs | `gh run list --workflow=cd.yml` |
| Watch run | `gh run watch [run-id]` |
| Pull Docker image | `docker pull ghcr.io/[owner]/[repo]:latest` |
| View dashboard | https://[username].github.io/[repo]/dashboard |

## See Also

- [Release Checklist](../.github/RELEASE_CHECKLIST.md)
- [Cloud Deployment Guide](Cloud_Deployment_Guide.md)
- [CI/CD Setup Guide](GITHUB_CI_CD_SETUP.md)
- [Release Process](RELEASE_PROCESS.md)
