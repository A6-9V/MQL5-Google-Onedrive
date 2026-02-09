# Quick CD Reference

## Run CD Workflow

### Via GitHub Actions UI
1. Go to **Actions** tab
2. Select **CD - Continuous Deployment**
3. Click **Run workflow**
4. Choose options:
   - Branch: `main`
   - Deployment target: `all`, `docker`, `cloud`, `dashboard`, or `release`
   - Environment: `production` or `staging`
5. Click **Run workflow**

### Via GitHub CLI
```bash
# Deploy to all platforms
gh workflow run cd.yml

# Deploy specific target
gh workflow run cd.yml -f deployment_target=docker -f environment=production
gh workflow run cd.yml -f deployment_target=cloud -f environment=production
gh workflow run cd.yml -f deployment_target=dashboard -f environment=production

# View workflow runs
gh run list --workflow=cd.yml

# Watch latest run
gh run watch
```

### Via Git Tag (Create Release)
```bash
# Create and push tag
git tag -a v1.22.0 -m "Release v1.22.0"
git push origin v1.22.0

# The CD workflow will automatically:
# - Build MT5 package
# - Build Docker images
# - Create GitHub release with assets
```

## Deployment Targets

| Target | Description |
|--------|-------------|
| `all` | Deploy to all platforms (default) |
| `docker` | Build and push Docker images only |
| `cloud` | Deploy to cloud platforms (Render, Railway, Fly.io) |
| `dashboard` | Deploy dashboard to GitHub Pages |
| `release` | Create GitHub release with MT5 package |

## What Gets Deployed

### Docker Images
- **Registry**: GitHub Container Registry (ghcr.io)
- **Images**:
  - `ghcr.io/a6-9v/mql5-google-onedrive:latest`
  - `ghcr.io/a6-9v/mql5-google-onedrive:main-[sha]`
  - `ghcr.io/a6-9v/mql5-google-onedrive:v[version]` (on tag)

### Cloud Platforms
- **Render.com**: Auto-deploys from main branch
- **Railway.app**: Auto-deploys from main branch  
- **Fly.io**: Requires `FLY_API_TOKEN` secret

### Dashboard
- **URL**: https://a6-9v.github.io/MQL5-Google-Onedrive/dashboard
- **Content**: Trading dashboard and monitoring tools

### Releases
- **MT5 Package**: `Exness_MT5_MQL5.zip`
- **Checksums**: `Exness_MT5_MQL5.zip.sha256`
- **Docker Images**: Multi-platform images

## Monitoring

```bash
# Check workflow status
gh run list --workflow=cd.yml --limit 5

# View specific run
gh run view [run-id]

# Download logs
gh run download [run-id]

# Cancel running workflow
gh run cancel [run-id]

# Re-run failed workflow
gh run rerun [run-id]
```

## Common Tasks

### Deploy to Production
```bash
# Automatic on push to main
git push origin main

# Manual dispatch
gh workflow run cd.yml -f deployment_target=all -f environment=production
```

### Create Release
```bash
# Update VERSION file
echo "1.22.0" > VERSION

# Update CHANGELOG.md
# ... add release notes ...

# Commit changes
git add VERSION CHANGELOG.md
git commit -m "Prepare release v1.22.0"
git push origin main

# Create and push tag
git tag -a v1.22.0 -m "Release v1.22.0"
git push origin v1.22.0
```

### Deploy Only Docker
```bash
gh workflow run cd.yml -f deployment_target=docker -f environment=production
```

### Deploy to Staging
```bash
gh workflow run cd.yml -f deployment_target=all -f environment=staging
```

## Troubleshooting

### Workflow Not Appearing
- Ensure `.github/workflows/cd.yml` is pushed to repository
- Check workflow file syntax (YAML validation)
- Verify Actions are enabled in repository settings

### Deployment Fails
- Check workflow logs in Actions tab
- Verify required secrets are set (FLY_API_TOKEN, etc.)
- Ensure deployment configs are valid (Dockerfile, render.yaml, etc.)

### Docker Build Fails
- Check Dockerfile syntax
- Verify all files referenced in Dockerfile exist
- Review Docker build logs

### Cloud Deployment Not Working
- Render/Railway: Verify GitHub integration is connected
- Fly.io: Ensure FLY_API_TOKEN is set in secrets
- Check platform-specific logs

## Required Secrets

Set in: Repository → Settings → Secrets and variables → Actions

| Secret | Required For | Description |
|--------|-------------|-------------|
| `GITHUB_TOKEN` | All | Auto-provided by GitHub |
| `FLY_API_TOKEN` | Fly.io | API token from `flyctl auth token` |
| `RENDER_API_KEY` | Render.com | Optional, for API access |
| `RAILWAY_TOKEN` | Railway.app | Optional, for API access |

## See Also

- [CD Workflow Guide](CD_WORKFLOW_GUIDE.md) - Detailed documentation
- [CI/CD Setup](GITHUB_CI_CD_SETUP.md) - Configuration guide
- [Release Checklist](../.github/RELEASE_CHECKLIST.md) - Release process
- [Cloud Deployment Guide](Cloud_Deployment_Guide.md) - Platform details
