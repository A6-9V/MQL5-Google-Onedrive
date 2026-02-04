# Release Process Documentation

This document describes the release process for the MQL5 SMC + Trend Breakout Trading System.

## Quick Release

For a standard release, use the automated release preparation script:

```bash
# Interactive menu
bash scripts/prepare_release.sh

# Or run full release preparation in one command
bash scripts/prepare_release.sh --full
```

The script will:
1. Check prerequisites
2. Validate repository structure
3. Run all tests
4. Package MT5 files
5. Create and push a release tag
6. Trigger the automated release workflow

## Manual Release Process

If you prefer to do each step manually:

### 1. Prerequisites

Ensure you have the following installed:
- Git
- Python 3.x
- GitHub CLI (optional, for creating releases from CLI)

### 2. Update Version Information

Update the version in the following files:
- `mt5/MQL5/Experts/SMC_TrendBreakout_MTF_EA.mq5` - Update `#property version`
- `CHANGELOG.md` - Add a new version section with changes

### 3. Validate Repository

```bash
# Run repository validation
python3 scripts/ci_validate_repo.py

# Validate shell scripts
bash -n scripts/package_mt5.sh
bash -n scripts/deploy_mt5.sh

# Run automation tests
python3 scripts/test_automation.py
```

### 4. Commit Changes

```bash
git add .
git commit -m "Prepare release v1.21.0"
git push origin main
```

### 5. Create Release Tag

```bash
# Create annotated tag
git tag -a v1.21.0 -m "Release v1.21.0"

# Push tag to trigger release workflow
git push origin v1.21.0
```

### 6. Monitor Release Workflow

The GitHub Actions workflow will automatically:
- Validate the repository
- Build the MT5 package
- Create Docker images
- Create a GitHub release with assets

Monitor the workflow at: https://github.com/A6-9V/MQL5-Google-Onedrive/actions

## Release Workflow

The release process is automated via GitHub Actions (`.github/workflows/release.yml`):

### Triggered By
- Pushing a tag matching `v*.*.*` (e.g., `v1.21.0`)
- Manual workflow dispatch with version input

### Workflow Steps

1. **Validate** - Runs repository validation and shell script checks
2. **Package** - Creates `Exness_MT5_MQL5.zip` with all MT5 source files
3. **Build Docker** - Builds and pushes Docker images to GitHub Container Registry
4. **Create Release** - Creates GitHub release with:
   - Release notes extracted from CHANGELOG.md
   - MT5 package (`.zip`)
   - Package checksums (`.sha256`)
   - Docker image reference

### Release Assets

Each release includes:
- **Exness_MT5_MQL5.zip** - Complete MT5 source package
  - Contains all `.mq5` indicator files
  - Contains all `.mq5` Expert Advisor files
  - Contains all `.mqh` include files
- **Exness_MT5_MQL5.zip.sha256** - SHA256 checksum for verification
- **Docker Images** - Available at `ghcr.io/a6-9v/mql5-google-onedrive:VERSION`

## Version Numbering

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR** version (X.0.0) - Incompatible API changes
- **MINOR** version (0.X.0) - New functionality in a backwards compatible manner
- **PATCH** version (0.0.X) - Backwards compatible bug fixes

### Version Format
- Git tags: `v1.21.0` (with 'v' prefix)
- MQL5 property: `"1.21"` (without 'v', may use two digits)
- Docker images: `1.21.0` (without 'v')

## Release Checklist

Before creating a release, ensure:

- [ ] All changes are committed and pushed
- [ ] Version updated in MQL5 EA file
- [ ] CHANGELOG.md updated with new version section
- [ ] All tests passing locally
- [ ] Documentation updated if needed
- [ ] No uncommitted or unstaged changes
- [ ] Working tree is clean

## Testing a Release

### Test MT5 Package

```bash
# Build package locally
bash scripts/package_mt5.sh

# Verify package contents
unzip -l dist/Exness_MT5_MQL5.zip

# Verify checksums
cd dist
sha256sum -c Exness_MT5_MQL5.zip.sha256
```

### Test Docker Image

```bash
# Pull the release image
docker pull ghcr.io/a6-9v/mql5-google-onedrive:v1.21.0

# Run the container
docker run --rm ghcr.io/a6-9v/mql5-google-onedrive:v1.21.0 python3 -c "import sys; print(sys.version)"
```

### Test Installation

1. **Manual MT5 Installation**:
   ```bash
   # Download from GitHub releases
   wget https://github.com/A6-9V/MQL5-Google-Onedrive/releases/download/v1.21.0/Exness_MT5_MQL5.zip
   
   # Extract to MT5 data folder
   unzip Exness_MT5_MQL5.zip -d "/path/to/MT5/Data/Folder/"
   
   # Compile in MetaEditor
   # Open MT5 -> F4 (MetaEditor) -> Compile all files
   ```

2. **Automated Installation**:
   ```bash
   # Use deployment script
   bash scripts/deploy_mt5.sh "/path/to/MT5/Data/Folder"
   ```

## Hotfix Releases

For urgent bug fixes:

1. Create a hotfix branch from the release tag:
   ```bash
   git checkout -b hotfix/v1.21.1 v1.21.0
   ```

2. Make the fix and commit:
   ```bash
   git commit -m "Fix critical bug in position management"
   ```

3. Update version and changelog:
   - Update version to `1.21.1`
   - Add hotfix section to CHANGELOG.md

4. Create hotfix tag:
   ```bash
   git tag -a v1.21.1 -m "Hotfix v1.21.1"
   git push origin v1.21.1
   ```

5. Merge back to main:
   ```bash
   git checkout main
   git merge hotfix/v1.21.1
   git push origin main
   ```

## Pre-releases

To create a pre-release (beta, RC, etc.):

1. Use pre-release version format:
   ```bash
   git tag -a v1.22.0-beta.1 -m "Release v1.22.0-beta.1"
   git push origin v1.22.0-beta.1
   ```

2. Or use workflow dispatch with "pre-release" option checked

Pre-releases are marked accordingly on GitHub and are not shown as "Latest" release.

## Rollback

To rollback to a previous release:

1. Find the previous release tag:
   ```bash
   git tag -l
   ```

2. Checkout the tag:
   ```bash
   git checkout v1.20.0
   ```

3. For production environments, download the specific release package:
   ```bash
   wget https://github.com/A6-9V/MQL5-Google-Onedrive/releases/download/v1.20.0/Exness_MT5_MQL5.zip
   ```

## Release Announcement

After a successful release:

1. Update README.md if needed
2. Announce in relevant channels:
   - GitHub Discussions
   - Project documentation
   - WhatsApp community
3. Update any external documentation or websites

## Troubleshooting

### Tag Already Exists

If you need to recreate a tag:
```bash
# Delete local tag
git tag -d v1.21.0

# Delete remote tag
git push origin :refs/tags/v1.21.0

# Recreate and push
git tag -a v1.21.0 -m "Release v1.21.0"
git push origin v1.21.0
```

### Workflow Failed

If the release workflow fails:

1. Check the Actions tab for error logs
2. Fix the issue locally
3. Delete the failed release (if created)
4. Delete and recreate the tag
5. Push the tag again

### Package Build Failed

If packaging fails:
```bash
# Check for missing files
python3 scripts/ci_validate_repo.py

# Verify all MT5 files exist
ls -R mt5/MQL5/

# Try building manually
bash scripts/package_mt5.sh
```

## Support

For issues with the release process:
- Open an issue: https://github.com/A6-9V/MQL5-Google-Onedrive/issues
- Check documentation: `docs/INDEX.md`
- Review workflow logs: GitHub Actions tab
