# GitHub Pages Sync Configuration

This document explains how to configure the automatic sync to GitHub Pages.

## Overview

The `github-pages-sync.yml` workflow automatically syncs MQL5 files, documentation, and README to an external GitHub Pages repository whenever changes are pushed to the main branch.

## Configuration

### 1. Set Up Personal Access Token

The workflow requires a Personal Access Token (PAT) to push to the external GitHub Pages repository.

**Why is this needed?**
- The default `GITHUB_TOKEN` provided by GitHub Actions only has permissions for the current repository
- To push to another repository (like a GitHub Pages repo), you need a PAT with `repo` scope

**Steps to create PAT:**

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
   - URL: https://github.com/settings/tokens
2. Click **Generate new token (classic)**
3. Give it a descriptive name: `GitHub Pages Sync Token`
4. Select scopes:
   - ✅ `repo` (Full control of private repositories)
5. Set expiration (recommend 90 days or 1 year)
6. Click **Generate token**
7. **Copy the token immediately** (you won't be able to see it again)

### 2. Add Token as Repository Secret

1. Go to your repository → **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Name: `PAGES_SYNC_TOKEN`
4. Value: Paste the PAT you created
5. Click **Add secret**

### 3. Configure Target Repository

The target repository is configured in the workflow file:

```yaml
env:
  PAGES_REPO: Mouy-leng/-LengKundee-mql5.github.io.git
  PAGES_BRANCH: main
```

To change the target repository, edit `.github/workflows/github-pages-sync.yml`.

## Behavior

### With Token Configured
When `PAGES_SYNC_TOKEN` is configured:
1. ✅ Workflow checks out the main repository
2. ✅ Clones the GitHub Pages repository
3. ✅ Syncs MQL5 files to `mql5/` directory
4. ✅ Syncs documentation to `docs/` directory
5. ✅ Copies README.md
6. ✅ Commits and pushes changes
7. ✅ Shows success summary

### Without Token Configured
When `PAGES_SYNC_TOKEN` is not configured:
1. ⚠️ Workflow detects missing token
2. ⚠️ Logs: "Skipping GitHub Pages sync: PAGES_SYNC_TOKEN not configured"
3. ✅ Workflow exits gracefully with success (does not fail)
4. ✅ No error in CI/CD pipeline

## Triggering the Sync

The sync is triggered automatically on:
- Push to `main` branch
- Changes to:
  - `mt5/MQL5/**`
  - `docs/**`
  - `README.md`
  - `.github/workflows/github-pages-sync.yml`

Manual trigger:
- Go to **Actions** tab → **Sync to GitHub Pages** → **Run workflow**

## Troubleshooting

### Error: "could not read Password"
**Symptom:** 
```
fatal: could not read Password for 'https://***@github.com': No such device or address
```

**Solution:** The `PAGES_SYNC_TOKEN` secret is not configured. Follow the setup steps above.

### Error: "Permission denied"
**Symptom:** Push fails with permission denied error

**Solution:** 
1. Verify the PAT has `repo` scope
2. Ensure the PAT hasn't expired
3. Check that the target repository exists and you have write access

### Sync is skipped
**Symptom:** Workflow logs show "Skipping GitHub Pages sync"

**Solution:** This is expected if `PAGES_SYNC_TOKEN` is not configured. The workflow will skip gracefully without failing.

## Security Notes

- ✅ Token is stored as a secret and never exposed in logs
- ✅ Token is masked in workflow outputs (`***`)
- ✅ Only repository admins can view/edit secrets
- ✅ Rotate token periodically for security
- ⚠️ Never commit the token to the repository

## Related Documentation

- [GitHub CI/CD Setup](./GITHUB_CI_CD_SETUP.md)
- [Cloud Deployment Guide](./CLOUD_DEPLOYMENT.md)
