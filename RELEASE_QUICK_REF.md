# Release Quick Reference

Quick commands for creating and managing releases.

## Creating a Release

### Option 1: Automated (Recommended)

```bash
# Interactive menu
bash scripts/prepare_release.sh

# Or run full release preparation
bash scripts/prepare_release.sh --full
```

This will guide you through the entire process.

### Option 2: Manual Steps

```bash
# 1. Update version in CHANGELOG.md and VERSION file
echo "1.22.0" > VERSION

# 2. Validate
python3 scripts/ci_validate_repo.py
bash scripts/prepare_release.sh --test

# 3. Package
bash scripts/package_mt5.sh

# 4. Commit changes
git add CHANGELOG.md VERSION
git commit -m "Prepare release v1.22.0"
git push

# 5. Create and push tag
git tag -a v1.22.0 -m "Release v1.22.0"
git push origin v1.22.0
```

GitHub Actions will automatically create the release.

## Useful Commands

### Check Current Version
```bash
cat VERSION
grep "#property version" mt5/MQL5/Experts/SMC_TrendBreakout_MTF_EA.mq5
```

### List Releases
```bash
git tag -l
gh release list  # if GitHub CLI is installed
```

### Download Release
```bash
# Latest release
wget https://github.com/A6-9V/MQL5-Google-Onedrive/releases/latest/download/Exness_MT5_MQL5.zip

# Specific version
wget https://github.com/A6-9V/MQL5-Google-Onedrive/releases/download/v1.21.0/Exness_MT5_MQL5.zip
```

### Verify Package
```bash
# Check contents
unzip -l Exness_MT5_MQL5.zip

# Verify checksum
sha256sum -c Exness_MT5_MQL5.zip.sha256
```

### View Release Workflow Status
```bash
# Using GitHub CLI
gh run list --workflow=release.yml

# Or visit
open https://github.com/A6-9V/MQL5-Google-Onedrive/actions
```

## Quick Validation

```bash
# All-in-one validation
bash scripts/prepare_release.sh --check && \
bash scripts/prepare_release.sh --validate && \
bash scripts/prepare_release.sh --test && \
bash scripts/prepare_release.sh --package
```

## Release Preparation Script Options

```bash
bash scripts/prepare_release.sh --help
```

Available options:
- `--full` - Run complete release preparation
- `--check` - Check prerequisites only
- `--validate` - Validate repository only
- `--test` - Run tests only
- `--package` - Package MT5 files only
- `--tag [VER]` - Create release tag
- `--help` - Show help

## Version Format

- Git tags: `v1.21.0` (with 'v' prefix)
- VERSION file: `1.21.0` (without 'v')
- MQL5 EA: `"1.21"` (two digits)

## Release Types

### Major Release (X.0.0)
Breaking changes or major new features
```bash
git tag -a v2.0.0 -m "Release v2.0.0"
```

### Minor Release (0.X.0)
New features, backwards compatible
```bash
git tag -a v1.22.0 -m "Release v1.22.0"
```

### Patch Release (0.0.X)
Bug fixes only
```bash
git tag -a v1.21.1 -m "Release v1.21.1"
```

### Pre-release
Beta, RC, or alpha versions
```bash
git tag -a v1.22.0-beta.1 -m "Release v1.22.0-beta.1"
```

## Docker Images

```bash
# Pull latest
docker pull ghcr.io/a6-9v/mql5-google-onedrive:latest

# Pull specific version
docker pull ghcr.io/a6-9v/mql5-google-onedrive:v1.21.0

# List available images
gh api repos/A6-9V/MQL5-Google-Onedrive/packages
```

## Rollback

```bash
# Checkout previous version
git checkout v1.20.0

# Or download previous release
wget https://github.com/A6-9V/MQL5-Google-Onedrive/releases/download/v1.20.0/Exness_MT5_MQL5.zip
```

## Hotfix Process

```bash
# Create hotfix branch from tag
git checkout -b hotfix/v1.21.1 v1.21.0

# Make fixes
# ... edit files ...

# Update version
echo "1.21.1" > VERSION

# Commit
git commit -am "Fix critical bug"

# Tag hotfix
git tag -a v1.21.1 -m "Hotfix v1.21.1"
git push origin v1.21.1

# Merge back to main
git checkout main
git merge hotfix/v1.21.1
git push
```

## Troubleshooting

### Delete and Recreate Tag
```bash
# Local
git tag -d v1.21.0

# Remote
git push origin :refs/tags/v1.21.0

# Recreate
git tag -a v1.21.0 -m "Release v1.21.0"
git push origin v1.21.0
```

### Failed Workflow
1. Check Actions tab for errors
2. Fix the issue
3. Delete tag if needed
4. Recreate and push tag

### Package Build Failed
```bash
# Check repository
python3 scripts/ci_validate_repo.py

# Verify files exist
ls -R mt5/MQL5/

# Try manual build
bash scripts/package_mt5.sh
```

## Important Files

- `CHANGELOG.md` - Version history
- `VERSION` - Current version
- `docs/RELEASE_PROCESS.md` - Detailed documentation
- `.github/RELEASE_CHECKLIST.md` - Release checklist
- `.github/workflows/release.yml` - Release workflow
- `scripts/prepare_release.sh` - Release tool

## Support

- Issues: https://github.com/A6-9V/MQL5-Google-Onedrive/issues
- Actions: https://github.com/A6-9V/MQL5-Google-Onedrive/actions
- Releases: https://github.com/A6-9V/MQL5-Google-Onedrive/releases
