# Repository Cleanup Guide

This guide helps you clean up pull requests, branches, files, and folders in your repository.

## 🧹 File & Folder Cleanup

### Automated Cleanup

Run the cleanup script to remove temporary files, caches, and logs:

```powershell
# Dry run (see what would be deleted)
.\scripts\cleanup.ps1 -DryRun

# Clean temporary files
.\scripts\cleanup.ps1 -CleanTemp

# Clean log files (large files > 1MB)
.\scripts\cleanup.ps1 -CleanLogs

# Clean cache files
.\scripts\cleanup.ps1 -CleanCache

# Clean everything
.\scripts\cleanup.ps1 -CleanTemp -CleanLogs -CleanCache
```

### Manual Cleanup

Files/folders that are safe to remove:

- **Log files**: `logs/*.log` (if too large)
- **Cache directories**: `__pycache__/`, `.cache/`
- **Temporary files**: `*.tmp`, `*.swp`, `*~`
- **Build artifacts**: `dist/` (unless needed)
- **OS files**: `.DS_Store`, `Thumbs.db`

### Protected Files (DO NOT DELETE)

- `config/vault.json` - Personal credentials (already in .gitignore)
- `dashboard/` - Web dashboard files
- `scripts/` - All deployment scripts
- `mt5/` - MQL5 source files
- `.github/` - GitHub Actions workflows

## 🌿 Branch Cleanup

### List All Branches

```powershell
# Local branches
git branch

# Remote branches
git branch -r

# All branches
git branch -a
```

### Delete Local Branches

```powershell
# Delete a specific branch (if already merged)
git branch -d branch-name

# Force delete (even if not merged)
git branch -D branch-name

# Delete multiple merged branches
git branch --merged | Where-Object { $_ -notmatch '\*|main|master' } | ForEach-Object { git branch -d $_.Trim() }
```

### Delete Remote Branches

```powershell
# Delete a remote branch
git push origin --delete branch-name

# Delete multiple remote branches
git branch -r | Select-String "origin/old-feature" | ForEach-Object {
    $branch = $_.ToString().Trim().Replace("origin/", "")
    git push origin --delete $branch
}
```

### Prune Remote Tracking Branches

```powershell
# Remove remote tracking branches that no longer exist on remote
git remote prune origin

# Or fetch with prune
git fetch --prune
```

## 📋 Pull Request Cleanup

GitHub Pull Requests cannot be deleted via git commands, but you can manage them:

### Via GitHub Web Interface

1. **Close/Reopen PRs**:
   - Go to: `https://github.com/A6-9V/MQL5-Google-Onedrive/pulls`
   - Click on a PR → Close/Reopen

2. **Merge PRs**:
   - If approved, click "Merge pull request"
   - Choose merge type (merge commit, squash, rebase)

3. **Delete PR Branch** (after merge):
   - After merging, GitHub offers to delete the branch
   - Or manually delete: `git push origin --delete branch-name`

### Close Multiple PRs via GitHub API

```powershell
# Requires GitHub CLI (gh) or API token
# Install GitHub CLI: winget install GitHub.cli

# List open PRs
gh pr list --state open

# Close a specific PR
gh pr close <PR_NUMBER>

# Close multiple PRs by label
gh pr list --label "automerge" --state open | ForEach-Object { gh pr close $_.Split("`t")[0] }
```

### Using GitHub CLI (Recommended)

```powershell
# Install: winget install GitHub.cli
# Login: gh auth login

# List all PRs
gh pr list

# List open PRs
gh pr list --state open

# Close a PR
gh pr close <PR_NUMBER>

# List merged PRs
gh pr list --state merged

# Check PR status
gh pr view <PR_NUMBER>
```

## 🗑️ Common Cleanup Tasks

### Clean Up After Merging to Main

```powershell
# 1. Update main branch
git checkout main
git pull origin main

# 2. Delete merged feature branch locally
git branch -d feature-branch-name

# 3. Delete merged feature branch on remote
git push origin --delete feature-branch-name

# 4. Clean up any temporary files
.\scripts\cleanup.ps1
```

### Bulk Branch Cleanup (Merged Branches)

```powershell
# Script to delete all merged branches except main
git checkout main
git pull origin main

# Get list of merged branches
$mergedBranches = git branch --merged main | Where-Object {
    $_ -notmatch '\*|main|master'
} | ForEach-Object { $_.Trim() }

# Delete local merged branches
foreach ($branch in $mergedBranches) {
    git branch -d $branch
    Write-Host "Deleted local branch: $branch" -ForegroundColor Green
}

# Delete remote merged branches (be careful!)
foreach ($branch in $mergedBranches) {
    git push origin --delete $branch 2>&1 | Out-Null
    Write-Host "Deleted remote branch: $branch" -ForegroundColor Green
}
```

### Clean Up Large Files from History (if needed)

If you need to remove large files from git history:

```powershell
# Use git filter-repo (install first: pip install git-filter-repo)
# Or use BFG Repo-Cleaner

# Example: Remove a large file from all history
# WARNING: This rewrites history - coordinate with team first!
# git filter-branch --force --index-filter "git rm --cached --ignore-unmatch path/to/large-file" --prune-empty --tag-name-filter cat -- --all
```

## 📊 Repository Size Check

```powershell
# Check repository size
git count-objects -vH

# Find large files in current state
Get-ChildItem -Recurse -File |
    Sort-Object Length -Descending |
    Select-Object -First 10 Name, @{Name="Size(MB)";Expression={[math]::Round($_.Length / 1MB, 2)}}, FullName

# Find large files in git history
git rev-list --objects --all |
    git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' |
    Where-Object { $_ -match '^blob' } |
    Sort-Object { [int]($_.Split(' ')[2]) } -Descending |
    Select-Object -First 10
```

## 🔒 Safety Tips

1. **Always use dry-run first**: Test cleanup scripts with `-DryRun` flag
2. **Backup before bulk operations**: Create a backup branch before deleting many branches
3. **Coordinate with team**: Don't delete shared branches without checking
4. **Use .gitignore**: Ensure temporary files are ignored, not committed
5. **Review before deleting**: Check branch/PR status before deletion

## 📝 Maintenance Schedule

Recommended cleanup schedule:

- **Weekly**: Run cleanup script for temporary files
- **After each release**: Delete merged feature branches
- **Monthly**: Review and close stale PRs
- **Quarterly**: Full repository audit for large files

## 🆘 Recovering Deleted Items

If you accidentally delete something:

```powershell
# Recover a deleted branch
git checkout -b branch-name origin/branch-name

# Recover a deleted file (before commit)
git checkout HEAD -- path/to/file

# Recover from reflog
git reflog
git checkout <commit-hash>
```
