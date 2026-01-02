# Auto-Merge Setup and Usage Guide

## Overview

This repository is configured with automated merge capabilities to streamline the development workflow. When a pull request has the `automerge` label, GitHub will automatically merge it once all required checks pass.

## How Auto-Merge Works

The auto-merge workflow (`.github/workflows/enable-automerge.yml`) automatically enables GitHub's auto-merge feature for pull requests that:

1. Have the **`automerge`** label
2. Are not in draft status
3. Meet all branch protection requirements

## Prerequisites

### Repository Settings

Ensure the following settings are configured in GitHub:

1. **Enable Auto-Merge Feature**
   - Go to **Settings** → **General**
   - Scroll to **Pull Requests** section
   - Check ✓ **Allow auto-merge**

2. **Branch Protection Rules** (recommended)
   - Go to **Settings** → **Branches**
   - Add rule for `main` branch:
     - ✓ Require pull request reviews before merging (at least 1)
     - ✓ Require status checks to pass before merging
       - Add required check: `CI / validate-and-package`
     - ✓ Require branches to be up to date before merging (optional)

## Using Auto-Merge

### For Pull Request Authors

1. **Create a Pull Request**
   ```bash
   git checkout -b feature/my-new-feature
   # Make your changes
   git add .
   git commit -m "Add new feature"
   git push origin feature/my-new-feature
   ```

2. **Add the `automerge` Label**
   - Go to your pull request on GitHub
   - Click on **Labels** in the right sidebar
   - Select or create the **`automerge`** label

3. **Wait for Checks to Pass**
   - The auto-merge workflow will automatically enable GitHub's auto-merge
   - Once all required checks pass and reviews are approved, the PR will be merged automatically
   - The branch will be deleted after merge (if configured)

### For This Specific PR

To enable auto-merge for the current pull request (`copilot/merge-and-delete-branch`):

1. Navigate to the pull request in GitHub
2. Add the `automerge` label
3. Ensure all CI checks pass
4. Get required approvals (if branch protection requires reviews)
5. The PR will automatically merge once all conditions are met

## Merge Method

The auto-merge workflow uses **squash merge** by default. This means:
- All commits in the PR are squashed into a single commit
- The commit message will be the PR title
- The commit description will include all individual commit messages
- Clean, linear commit history on the main branch

## Workflow Triggers

The auto-merge workflow runs when:
- A PR is **labeled** with `automerge`
- A PR is **reopened**
- A PR becomes **ready for review** (no longer draft)
- A PR is **synchronized** (new commits pushed)

## Manual Merge Alternative

If you prefer to merge manually:
1. Don't add the `automerge` label
2. Use GitHub's merge button when ready
3. Choose your preferred merge method (squash, merge commit, or rebase)

## Troubleshooting

### Auto-Merge Not Enabled

If auto-merge doesn't enable automatically:
- Check that the PR has the `automerge` label
- Verify the PR is not in draft status
- Review workflow logs in the **Actions** tab

### Auto-Merge Enabled But Not Merging

If auto-merge is enabled but the PR doesn't merge:
- Check if all required status checks are passing
- Verify you have the required number of approvals
- Ensure the branch is up to date (if required)
- Check for merge conflicts

### Workflow Permissions

If you see permission errors:
- The workflow requires `contents: write` and `pull-requests: write` permissions
- These are configured in the workflow file
- Contact repository administrators if issues persist

## Security Considerations

1. **Required Reviews**: Always configure branch protection to require reviews for production branches
2. **Status Checks**: Ensure CI checks are required and passing before merge
3. **CODEOWNERS**: Consider adding CODEOWNERS file for critical paths
4. **Label Permissions**: Restrict who can add the `automerge` label in repository settings

## Branch Cleanup

After a successful auto-merge:
- GitHub can automatically delete the source branch
- Enable this in **Settings** → **General** → **Pull Requests**
- Check ✓ **Automatically delete head branches**

## Related Workflows

This repository includes other automated workflows:

- **CI**: Validates code and packages artifacts
- **OneDrive Sync**: Syncs MT5 files to OneDrive after merge
- **Trading News Monitor**: Scheduled monitoring of trading news

## Examples

### Example 1: Feature Branch with Auto-Merge

```bash
# Create feature branch
git checkout -b feature/add-new-indicator
git push origin feature/add-new-indicator

# Create PR on GitHub and add 'automerge' label
# Push commits
git commit -m "Add new indicator"
git push

# PR automatically merges when CI passes and reviews are approved
```

### Example 2: Hotfix with Immediate Merge

```bash
# Create hotfix branch
git checkout -b hotfix/fix-critical-bug
git push origin hotfix/fix-critical-bug

# Create PR and add 'automerge' label
# Get emergency approval
# CI passes → Auto-merge triggers → Merged!
```

## Best Practices

1. **Use for routine PRs**: Auto-merge works well for well-tested, routine changes
2. **Review before labeling**: Only add `automerge` after reviewing the changes
3. **Monitor CI**: Ensure your CI is comprehensive and catches issues
4. **Test locally**: Run tests locally before pushing to catch issues early
5. **Keep PRs small**: Smaller PRs are easier to review and merge safely

## Reference

- [GitHub Auto-Merge Documentation](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request/automatically-merging-a-pull-request)
- [Branch Protection Documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- Repository Workflow: `.github/workflows/enable-automerge.yml`
