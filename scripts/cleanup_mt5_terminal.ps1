# Cleanup and Reorganize MT5 Terminal Data Folder
# This script organizes files in the MT5 terminal directory

param(
    [string]$MT5TerminalPath = "C:\Users\USER\AppData\Roaming\MetaQuotes\Terminal\53785E099C927DB68A545C249CDBCE06",
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Continue"

Write-Host "=========================================="
Write-Host "MT5 Terminal Cleanup & Reorganization"
Write-Host "=========================================="
Write-Host ""

if (-not (Test-Path $MT5TerminalPath)) {
    Write-Host "❌ MT5 terminal path not found: $MT5TerminalPath" -ForegroundColor Red
    exit 1
}

Write-Host "Target Path: $MT5TerminalPath" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "Mode: DRY RUN (no files will be moved)" -ForegroundColor Yellow
}
Write-Host ""

# Create organization folders
$orgFolders = @{
    "Scripts" = @(
        "manage_sync.ps1",
        "sync_bridge.ps1",
        "QUICK_MANAGE.bat",
        "START_SYNC.bat"
    )
    "Docs" = @(
        "DEV_WORKFLOW.md",
        "SYNC_MANAGEMENT_GUIDE.md",
        "SYNC_SETUP.md"
    )
    "Config" = @(
        ".dropboxignore",
        ".gdignore",
        ".gitignore",
        "origin.txt"
    )
    "Logs" = @(
        "sync_bridge.log"
    )
}

# Files/folders to keep in root (MT5 essential)
$keepInRoot = @(
    "MQL5",
    "config",
    "bases",
    "logs",
    "temp",
    "Tester",
    "liveupdate"
)

# Files/folders to remove or archive
$toRemove = @(
    ".git",
    "Cursor.lnk"
)

$itemsProcessed = 0
$itemsMoved = 0
$itemsRemoved = 0

# Create organization directories
Write-Host "📁 Creating organization folders..." -ForegroundColor Cyan
foreach ($folderName in $orgFolders.Keys) {
    $folderPath = Join-Path $MT5TerminalPath "_organized\$folderName"
    if (-not (Test-Path $folderPath)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
        }
        Write-Host "  ✅ Created: _organized\$folderName" -ForegroundColor Green
    }
}

Write-Host ""

# Move files to organized folders
Write-Host "📦 Organizing files..." -ForegroundColor Cyan

foreach ($folderName in $orgFolders.Keys) {
    $targetFolder = Join-Path $MT5TerminalPath "_organized\$folderName"
    
    foreach ($fileName in $orgFolders[$folderName]) {
        $sourceFile = Join-Path $MT5TerminalPath $fileName
        
        if (Test-Path $sourceFile) {
            $itemsProcessed++
            $targetFile = Join-Path $targetFolder $fileName
            
            Write-Host "  📄 $fileName → _organized\$folderName\" -ForegroundColor Yellow
            
            if (-not $DryRun) {
                try {
                    Move-Item -Path $sourceFile -Destination $targetFile -Force -ErrorAction Stop
                    $itemsMoved++
                    Write-Host "    ✅ Moved successfully" -ForegroundColor Green
                } catch {
                    Write-Host "    ⚠️ Failed to move: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
    }
}

Write-Host ""

# Handle items to remove
Write-Host "🗑️  Cleaning up unnecessary files/folders..." -ForegroundColor Cyan

foreach ($itemName in $toRemove) {
    $itemPath = Join-Path $MT5TerminalPath $itemName
    
    if (Test-Path $itemPath) {
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

# Create consolidated .gitignore
Write-Host "📝 Creating consolidated .gitignore..." -ForegroundColor Cyan
$gitignorePath = Join-Path $MT5TerminalPath ".gitignore"
$gitignoreContent = @"
# MT5 Terminal Data - Git Ignore

# MT5 System Files
bases/
config/
logs/
temp/
Tester/
liveupdate/

# Compiled MQL5 files
*.ex5
*.ex4

# Editor/OS clutter
*.mq5~
*.mqh~
.DS_Store
Thumbs.db
Desktop.ini

# Organized development files
_organized/

# Sync logs
*.log

# IDE files
.vscode/
.idea/
*.swp
*.swo

# Personal shortcuts
*.lnk
"@

if (-not $DryRun) {
    Set-Content -Path $gitignorePath -Value $gitignoreContent -Force
    Write-Host "  ✅ Created consolidated .gitignore" -ForegroundColor Green
} else {
    Write-Host "  📄 Would create .gitignore" -ForegroundColor Yellow
}

Write-Host ""

# Summary
Write-Host "=========================================="
Write-Host "Cleanup Summary" -ForegroundColor Cyan
Write-Host "=========================================="
Write-Host "Items processed: $itemsProcessed"
Write-Host "Items moved: $itemsMoved" -ForegroundColor Green
Write-Host "Items removed: $itemsRemoved" -ForegroundColor Green

if (-not $DryRun) {
    Write-Host ""
    Write-Host "✅ Cleanup complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Files organized in: _organized\" -ForegroundColor Cyan
    Write-Host "  - Scripts: Development scripts (.ps1, .bat)" -ForegroundColor Gray
    Write-Host "  - Docs: Documentation files (.md)" -ForegroundColor Gray
    Write-Host "  - Config: Configuration files (.gitignore, etc.)" -ForegroundColor Gray
    Write-Host "  - Logs: Log files" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "⚠️ DRY RUN - No files were actually moved or removed" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Essential MT5 folders kept in root:" -ForegroundColor Cyan
foreach ($item in $keepInRoot) {
    Write-Host "  ✓ $item" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=========================================="
