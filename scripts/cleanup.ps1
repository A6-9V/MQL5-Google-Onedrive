# Cleanup Script - Remove temporary files, caches, and unused files
# Run with: .\scripts\cleanup.ps1

param(
    [switch]$DryRun = $false,
    [switch]$CleanLogs = $false,
    [switch]$CleanCache = $false,
    [switch]$CleanTemp = $false
)

$ErrorActionPreference = "Continue"
$repoRoot = Split-Path -Parent $PSScriptRoot
$itemsRemoved = 0
$totalSize = 0

Write-Host "=========================================="
Write-Host "Repository Cleanup Script"
Write-Host "=========================================="
Write-Host "Repository: $repoRoot"
if ($DryRun) {
    Write-Host "Mode: DRY RUN (no files will be deleted)" -ForegroundColor Yellow
}
Write-Host ""

# Patterns to clean
$patterns = @(
    # Python cache
    "__pycache__",
    "*.pyc",
    "*.pyo",
    "*.pyd",
    ".Python",
    "*.so",

    # Temporary files
    "*.tmp",
    "*.temp",
    "*.swp",
    "*.swo",
    "*~",
    ".DS_Store",
    "Thumbs.db",

    # IDE files (optional - can be kept if needed)
    # ".vscode",
    # ".idea",

    # Build artifacts (if not needed)
    # "dist/",
    # "build/",

    # OS files
    ".DS_Store",
    "._*",
    ".Spotlight-V100",
    ".Trashes"
)

$filesToClean = @()

# Find files matching patterns
foreach ($pattern in $patterns) {
    $items = Get-ChildItem -Path $repoRoot -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Name -like $pattern -or
            $_.FullName -like "*$pattern*"
        }

    foreach ($item in $items) {
        if ($item -and (Test-Path $item.FullName)) {
            $filesToClean += $item
        }
    }
}

# Clean log files if requested
if ($CleanLogs) {
    Write-Host "🔍 Searching for log files..." -ForegroundColor Cyan
    $logFiles = Get-ChildItem -Path $repoRoot -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Extension -eq ".log" -or
            $_.Name -like "*.log.*" -or
            $_.FullName -match "logs[/\\]"
        }

    foreach ($log in $logFiles) {
        if ($log.Length -gt 1MB) {
            $filesToClean += $log
            Write-Host "  📋 Large log file: $($log.Name) ($([math]::Round($log.Length / 1MB, 2)) MB)" -ForegroundColor Yellow
        }
    }
}

# Clean cache files if requested
if ($CleanCache) {
    Write-Host "🔍 Searching for cache files..." -ForegroundColor Cyan
    $cacheDirs = @("__pycache__", ".cache", "*.cache")
    foreach ($cache in $cacheDirs) {
        $items = Get-ChildItem -Path $repoRoot -Recurse -Directory -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like $cache }
        $filesToClean += $items
    }
}

# Remove duplicates
$filesToClean = $filesToClean | Sort-Object FullName -Unique

# Show summary
Write-Host ""
Write-Host "📊 Files/Folders to clean: $($filesToClean.Count)" -ForegroundColor Cyan

if ($filesToClean.Count -gt 0) {
    $totalSize = ($filesToClean | Where-Object { $_.PSIsContainer -eq $false } | Measure-Object -Property Length -Sum).Sum
    Write-Host "📦 Total size: $([math]::Round($totalSize / 1MB, 2)) MB" -ForegroundColor Cyan
    Write-Host ""

    # Show first 20 items
    Write-Host "Items to remove (showing first 20):" -ForegroundColor Yellow
    $filesToClean | Select-Object -First 20 | ForEach-Object {
        $type = if ($_.PSIsContainer) { "📁" } else { "📄" }
        $size = if (-not $_.PSIsContainer) { " ($([math]::Round($_.Length / 1KB, 2)) KB)" } else { "" }
        Write-Host "  $type $($_.FullName.Replace($repoRoot, '.'))$size"
    }

    if ($filesToClean.Count -gt 20) {
        Write-Host "  ... and $($filesToClean.Count - 20) more items"
    }

    Write-Host ""

    if (-not $DryRun) {
        $confirm = Read-Host "Delete these files? (y/N)"
        if ($confirm -eq 'y' -or $confirm -eq 'Y') {
            foreach ($item in $filesToClean) {
                try {
                    if (Test-Path $item.FullName) {
                        Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction Stop
                        $itemsRemoved++
                        Write-Host "  ✅ Removed: $($item.FullName.Replace($repoRoot, '.'))" -ForegroundColor Green
                    }
                } catch {
                    Write-Host "  ⚠️ Failed to remove: $($item.FullName.Replace($repoRoot, '.')) - $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        } else {
            Write-Host "Cleanup cancelled." -ForegroundColor Yellow
            exit
        }
    } else {
        Write-Host "⚠️ DRY RUN: No files were actually deleted" -ForegroundColor Yellow
    }
} else {
    Write-Host "✅ No files found that need cleaning!" -ForegroundColor Green
}

Write-Host ""
Write-Host "=========================================="
if (-not $DryRun -and $itemsRemoved -gt 0) {
    Write-Host "✅ Cleanup Complete!" -ForegroundColor Green
    Write-Host "   Removed: $itemsRemoved items" -ForegroundColor Green
    Write-Host "   Freed: $([math]::Round($totalSize / 1MB, 2)) MB" -ForegroundColor Green
} else {
    Write-Host "Cleanup finished." -ForegroundColor Cyan
}
Write-Host "=========================================="
