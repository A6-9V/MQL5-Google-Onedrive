# Jules Execution Guide

This guide explains how to use Jules CLI to execute tasks and automate GitHub workflows for this repository.

## What is Jules?

Jules is a Google CLI tool that provides AI-powered GitHub automation. It can help with:
- Code reviews
- Pull request management
- Issue triage
- Repository automation
- Task execution

## Setup

### 1. Install Jules

```bash
npm install -g @google/jules
```

### 2. Authenticate

```bash
jules login
```

This will open a browser for Google authentication.

### 3. Authorize GitHub Access

For organization repositories (like A6-9V):
1. Go to GitHub → Organization Settings → GitHub Apps
2. Find "Jules" and install it
3. Grant access to repositories (or all repos)
4. Ensure full `repo` permissions for private repos

### 4. Verify Setup

```bash
jules version
jules remote list --repo
```

## Using Jules with This Repository

### Repository Information

- **Repository**: `A6-9V/MQL5-Google-Onedrive`
- **Main Branch**: `main`
- **Remote**: `origin`

### Common Jules Commands

**Check repository access:**
```bash
jules remote list --repo A6-9V/MQL5-Google-Onedrive
```

**Create a new task:**
```bash
jules new --repo A6-9V/MQL5-Google-Onedrive "Task description"
```

**Review pull requests:**
```bash
jules review --repo A6-9V/MQL5-Google-Onedrive
```

**Execute automation:**
```bash
jules execute --repo A6-9V/MQL5-Google-Onedrive --task "task-name"
```

### Using the Helper Script

We've created a helper script to make Jules execution easier:

```bash
python scripts/jules_execute.py
```

This script will:
- Check if Jules is installed
- Verify authentication
- List available repositories
- Show available commands

## Integration with GitHub Actions

Jules can be integrated with GitHub Actions workflows. Example workflow:

```yaml
name: Jules Automation

on:
  workflow_dispatch:
  pull_request:
    types: [opened, synchronize]

jobs:
  jules-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
      - run: npm install -g @google/jules
      - run: jules review --repo ${{ github.repository }}
        env:
          JULES_TOKEN: ${{ secrets.JULES_TOKEN }}
```

## Common Use Cases

### 1. Automated Code Review

After pushing commits, use Jules to review:
```bash
jules review --repo A6-9V/MQL5-Google-Onedrive --pr <PR_NUMBER>
```

### 2. Issue Triage

Automatically categorize and assign issues:
```bash
jules triage --repo A6-9V/MQL5-Google-Onedrive
```

### 3. Task Execution

Execute specific tasks:
```bash
# Deploy cloud configurations
jules execute --repo A6-9V/MQL5-Google-Onedrive --task "deploy-cloud"

# Sync to GitHub Pages
jules execute --repo A6-9V/MQL5-Google-Onedrive --task "sync-pages"
```

### 4. Repository Maintenance

Automated maintenance tasks:
```bash
jules maintain --repo A6-9V/MQL5-Google-Onedrive
```

## Troubleshooting

### Jules Not Found

If `jules` command is not found:
1. Verify npm installation: `npm --version`
2. Install Jules: `npm install -g @google/jules`
3. Check PATH: `where jules` (Windows) or `which jules` (Linux/Mac)

### Authentication Issues

If authentication fails:
```bash
jules logout
jules login
```

### Repository Access Denied

If you can't access the repository:
1. Verify GitHub App is installed for organization
2. Check repository permissions in GitHub App settings
3. Refresh Jules: `jules logout && jules login`

### Permission Errors

For private repositories:
- Ensure GitHub App has full `repo` access
- Check organization settings
- Verify repository is included in app permissions

## Best Practices

1. **Always verify** before executing: Use `--dry-run` when available
2. **Review changes** before committing: Let Jules review PRs
3. **Monitor execution**: Check logs and outputs
4. **Keep Jules updated**: `npm update -g @google/jules`

## Integration Examples

### After Push to Main

```bash
# After pushing commits
git push origin main

# Use Jules to review and execute tasks
jules execute --repo A6-9V/MQL5-Google-Onedrive --auto
```

### Automated Workflow

Create `.github/workflows/jules-automation.yml`:

```yaml
name: Jules Automation

on:
  push:
    branches: [main]

jobs:
  jules-execute:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
      - run: npm install -g @google/jules
      - run: jules execute --repo ${{ github.repository }}
        env:
          JULES_TOKEN: ${{ secrets.JULES_TOKEN }}
```

## Support

For Jules-specific issues:
- Jules Documentation: https://github.com/google/jules
- GitHub App: Check organization settings
- This Repository: Create an issue with `@jules` tag

For repository-specific issues:
- Email: Lengkundee01.org@domain.com
- GitHub Issues: https://github.com/A6-9V/MQL5-Google-Onedrive/issues
