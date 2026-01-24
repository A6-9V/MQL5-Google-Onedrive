# Cleanup and Organize MQL5 Folder Structure
# Removes unnecessary files and organizes development files

param(
    [string]$MQL5Path = "C:\Users\USER\AppData\Roaming\MetaQuotes\Terminal\53785E099C927DB68A545C249CDBCE06\MQL5",
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Continue"

Write-Host "=========================================="
Write-Host "MQL5 Folder Cleanup & Organization"
Write-Host "=========================================="
Write-Host ""

if (-not (Test-Path $MQL5Path)) {
    Write-Host "❌ MQL5 path not found: $MQL5Path" -ForegroundColor Red
    exit 1
}

Write-Host "Target Path: $MQL5Path" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "Mode: DRY RUN (no files will be moved/deleted)" -ForegroundColor Yellow
}
Write-Host ""

# Standard MQL5 folders (must keep in root)
$standardFolders = @(
    "Scripts",
    "Services",
    "Shared Projects",
    "Terminal",
    "Experts",
    "Indicators",
    "Include",
    "Libraries",
    "Logs",
    "Presets",
    "Profiles",
    "Files",
    "Images"
)

# Files/folders to remove or organize
$itemsToClean = @{
    "Remove" = @(
        ".git",                    # Git folder shouldn't be in MQL5
        "I'm Good",               # Unclear purpose folder
        "Expert"                   # Likely duplicate of "Experts"
    )
    "Organize" = @(
        @{Name="README.md"; Target="_dev\Docs"},
        @{Name="GenX_FX.mq5"; Target="_dev\Scripts"},
        @{Name="GenX_FX.ex5"; Target="_dev\Compiled"}
    )
}

$itemsProcessed = 0
$itemsRemoved = 0
$itemsMoved = 0

# Create _dev organization folder
if (-not $DryRun) {
    $devPath = Join-Path $MQL5Path "_dev"
    if (-not (Test-Path $devPath)) {
        New-Item -ItemType Directory -Path $devPath -Force | Out-Null
    }

    $devSubFolders = @("Docs", "Scripts", "Compiled")
    foreach ($subFolder in $devSubFolders) {
        $subPath = Join-Path $devPath $subFolder
        if (-not (Test-Path $subPath)) {
            New-Item -ItemType Directory -Path $subPath -Force | Out-Null
        }
    }
    Write-Host "📁 Created _dev organization folder" -ForegroundColor Green
}

Write-Host ""

# Remove unwanted items
Write-Host "🗑️  Removing unnecessary items..." -ForegroundColor Cyan
foreach ($itemName in $itemsToClean["Remove"]) {
    $itemPath = Join-Path $MQL5Path $itemName
    if (Test-Path $itemPath) {
        $itemsProcessed++
        Write-Host "  🗑️  $itemName" -ForegroundColor Yellow

        if (-not $DryRun) {
            try {
                Remove-Item -Path $itemPath -Recurse -Force -ErrorAction Stop
                $itemsRemoved++
                Write-Host "    ✅ Removed successfully" -ForegroundColor Green
            } catch {
                Write-Host "    ⚠️ Failed to remove: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}

Write-Host ""

# Organize files
Write-Host "📦 Organizing development files..." -ForegroundColor Cyan
foreach ($item in $itemsToClean["Organize"]) {
    $sourcePath = Join-Path $MQL5Path $item.Name
    if (Test-Path $sourcePath) {
        $targetPath = Join-Path $MQL5Path "$($item.Target)\$($item.Name)"
        $targetDir = Split-Path $targetPath -Parent

        $itemsProcessed++
        Write-Host "  📄 $($item.Name) → $($item.Target)\" -ForegroundColor Yellow

        if (-not $DryRun) {
            try {
                if (-not (Test-Path $targetDir)) {
                    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                }
                Move-Item -Path $sourcePath -Destination $targetPath -Force -ErrorAction Stop
                $itemsMoved++
                Write-Host "    ✅ Moved successfully" -ForegroundColor Green
            } catch {
                Write-Host "    ⚠️ Failed to move: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}

Write-Host ""

# Check for duplicate "Expert" vs "Experts"
$expertPath = Join-Path $MQL5Path "Expert"
$expertsPath = Join-Path $MQL5Path "Experts"

if (Test-Path $expertPath) {
    Write-Host "⚠️  Found 'Expert' folder (likely duplicate of 'Experts')" -ForegroundColor Yellow
    if (Test-Path $expertsPath) {
        Write-Host "  📋 'Experts' folder exists - 'Expert' will be removed" -ForegroundColor Gray
    }
}

Write-Host ""

# Verify standard folders exist
Write-Host "✅ Verifying standard MQL5 folders..." -ForegroundColor Cyan
$missingFolders = @()
foreach ($folder in $standardFolders) {
    $folderPath = Join-Path $MQL5Path $folder
    if (-not (Test-Path $folderPath)) {
        $missingFolders += $folder
        Write-Host "  ⚠️ Missing: $folder" -ForegroundColor Yellow
    } else {
        Write-Host "  ✓ $folder" -ForegroundColor Gray
    }
}

if ($missingFolders.Count -gt 0 -and -not $DryRun) {
    Write-Host ""
    Write-Host "Creating missing standard folders..." -ForegroundColor Cyan
    foreach ($folder in $missingFolders) {
        $folderPath = Join-Path $MQL5Path $folder
        New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
        Write-Host "  ✅ Created: $folder" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=========================================="
Write-Host "Cleanup Summary" -ForegroundColor Cyan
Write-Host "=========================================="
Write-Host "Items processed: $itemsProcessed"
if (-not $DryRun) {
    Write-Host "Items removed: $itemsRemoved" -ForegroundColor Green
    Write-Host "Items moved: $itemsMoved" -ForegroundColor Green
    Write-Host ""
    Write-Host "✅ Cleanup complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Organized structure:" -ForegroundColor Cyan
    Write-Host "  _dev\Docs\      - Documentation files" -ForegroundColor Gray
    Write-Host "  _dev\Scripts\   - Development scripts" -ForegroundColor Gray
    Write-Host "  _dev\Compiled\  - Compiled files backup" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "⚠️ DRY RUN - No files were actually moved or removed" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Standard MQL5 folders preserved:" -ForegroundColor Cyan
foreach ($folder in $standardFolders) {
    Write-Host "  ✓ $folder" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=========================================="
