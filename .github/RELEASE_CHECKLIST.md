# Release Checklist Template

Use this checklist when preparing a new release.

## Release Information

- **Version:** _____________
- **Release Date:** _____________
- **Release Manager:** _____________
- **Type:** [ ] Major [ ] Minor [ ] Patch [ ] Hotfix [ ] Pre-release

## Pre-Release Checklist

### Code Quality
- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Code review completed
- [ ] No critical security vulnerabilities
- [ ] No known critical bugs

### Documentation
- [ ] CHANGELOG.md updated with new version
- [ ] README.md updated (if needed)
- [ ] Version number updated in MQL5 files
- [ ] Documentation reflects new features/changes
- [ ] API changes documented (if applicable)

### Testing
- [ ] Manual testing completed
- [ ] MT5 indicator compiles without errors
- [ ] MT5 EA compiles without errors
- [ ] Strategy tester validation (if applicable)
- [ ] Demo account testing completed
- [ ] All deployment scripts tested

### Repository
- [ ] Working directory is clean (no uncommitted changes)
- [ ] All changes merged to main branch
- [ ] Branch protection rules respected
- [ ] All CI/CD checks passing

### Release Assets
- [ ] MT5 package builds successfully
- [ ] Package contents verified
- [ ] Checksums generated
- [ ] Docker images build successfully (if applicable)
- [ ] All release assets prepared

## Release Execution

- [ ] Create release tag: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
- [ ] Push release tag: `git push origin vX.Y.Z`
- [ ] GitHub Actions workflow triggered successfully
- [ ] Release created on GitHub
- [ ] Release assets uploaded correctly

## Post-Release Checklist

### Verification
- [ ] Release page accessible on GitHub
- [ ] Download links working
- [ ] Checksums match
- [ ] Docker images available in registry
- [ ] Installation instructions tested

### Communication
- [ ] Release notes reviewed
- [ ] Announcement prepared
- [ ] Community notified (if applicable)
- [ ] Documentation site updated (if applicable)

### Monitoring
- [ ] Monitor for bug reports
- [ ] Check download statistics
- [ ] Monitor user feedback
- [ ] Watch for critical issues

## Rollback Plan (if needed)

- [ ] Previous version identified: _____________
- [ ] Rollback procedure documented
- [ ] Stakeholders notified

## Notes

Add any additional notes, issues encountered, or special considerations for this release:

```
[Add notes here]
```

## Sign-off

- [ ] Release Manager: _____________ Date: _____________
- [ ] Technical Lead: _____________ Date: _____________
- [ ] QA Lead: _____________ Date: _____________

---

## Quick Commands Reference

```bash
# Validate repository
python3 scripts/ci_validate_repo.py

# Run tests
python3 scripts/test_automation.py

# Package MT5 files
bash scripts/package_mt5.sh

# Create release (automated)
bash scripts/prepare_release.sh --full

# Manual tag creation
git tag -a v1.21.0 -m "Release v1.21.0"
git push origin v1.21.0

# Verify package
unzip -l dist/Exness_MT5_MQL5.zip
sha256sum dist/Exness_MT5_MQL5.zip

# Check workflow status
gh run list --workflow=release.yml

# Download release
wget https://github.com/A6-9V/MQL5-Google-Onedrive/releases/download/v1.21.0/Exness_MT5_MQL5.zip
```
