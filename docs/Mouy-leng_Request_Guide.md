# Mouy-leng Request Processing Guide

This guide explains how to handle requests and tasks for @Mouy-leng and the GitHub Pages integration.

## Overview

The repository is integrated with Mouy-leng's GitHub Pages repository:
- **GitHub Pages Repo**: https://github.com/Mouy-leng/-LengKundee-mql5.github.io.git
- **Purpose**: Hosts web interface and documentation for the trading system
- **Integration**: Automated sync workflow available

## Request Types

### 1. GitHub Issues
Use the issue templates in `.github/ISSUE_TEMPLATE/`:
- **Bug Report**: For reporting bugs
- **Feature Request**: For new features
- **Custom Template**: For general requests/questions (assigned to @Mouy-leng)

### 2. GitHub Pages Sync Requests
When MQL5 files or documentation need to be synced to GitHub Pages:

**Automatic Sync (GitHub Actions):**
- Triggered automatically on push to `main` branch
- Syncs `mt5/MQL5/`, `docs/`, and `README.md`
- Workflow: `.github/workflows/github-pages-sync.yml`

**Manual Sync (Local Script):**
```bash
# Dry run (see what would be synced)
python scripts/sync_github_pages.py --dry-run

# Actual sync
python scripts/sync_github_pages.py
```

### 3. Integration Requests
For ZOLO plugin or Soloist.ai endpoint changes:
- Check `docs/ZOLO_Plugin_Integration.md`
- Update EA parameters if needed
- Test web request functionality

## Processing Workflow

### Step 1: Receive Request
- Check GitHub Issues (assigned to @Mouy-leng)
- Review pull requests
- Check email: Lengkundee01.org@domain.com

### Step 2: Categorize Request
- **Documentation**: Update docs in `docs/` directory
- **MQL5 Code**: Update files in `mt5/MQL5/`
- **Automation**: Update scripts in `scripts/`
- **GitHub Pages**: Use sync workflow/script
- **Integration**: Update ZOLO plugin docs

### Step 3: Implement Changes
- Make changes in appropriate directory
- Test changes locally
- Update documentation if needed

### Step 4: Sync to GitHub Pages (if needed)
- If changes affect MQL5 files or docs, sync to GitHub Pages:
  ```bash
  python scripts/sync_github_pages.py
  ```

### Step 5: Commit and Push
- Commit changes with descriptive message
- Push to main branch
- GitHub Actions will auto-sync to Pages repo

## Quick Reference

### Common Tasks

**Update MQL5 Indicator/EA:**
1. Edit files in `mt5/MQL5/`
2. Test in MT5
3. Commit and push
4. Auto-sync to GitHub Pages

**Update Documentation:**
1. Edit files in `docs/`
2. Update README.md if needed
3. Commit and push
4. Auto-sync to GitHub Pages

**Handle GitHub Pages Request:**
1. Review request details
2. Make changes in main repo
3. Run sync script: `python scripts/sync_github_pages.py`
4. Verify sync completed

**Process Issue:**
1. Read issue description
2. Check if assigned to @Mouy-leng
3. Implement fix/feature
4. Test changes
5. Update issue with progress
6. Close issue when complete

## Automation

### GitHub Actions Workflows

1. **CI Workflow** (`.github/workflows/ci.yml`)
   - Validates repository structure
   - Packages MQL5 files
   - Runs on every push/PR

2. **GitHub Pages Sync** (`.github/workflows/github-pages-sync.yml`)
   - Syncs MQL5 files and docs to Pages repo
   - Runs automatically on push to main
   - Can be triggered manually

3. **OneDrive Sync** (`.github/workflows/onedrive-sync.yml`)
   - Syncs MQL5 files to OneDrive
   - Uses rclone configuration

## Contact & Support

- **Email**: Lengkundee01.org@domain.com
- **GitHub**: @Mouy-leng
- **WhatsApp**: [Agent community](https://chat.whatsapp.com/DYemXrBnMD63K55bjUMKYF)

## Notes

- All requests should be tracked via GitHub Issues
- Use appropriate labels for categorization
- Keep documentation updated with changes
- Test changes before syncing to GitHub Pages
- Follow the existing code style and conventions
