# ============================================================================
# MQL5 Trading Automation - Environment Reset Script
# ============================================================================
# This script resets the environment by cleaning up logs, build artifacts,
# and temporary files. It helps ensuring a clean slate for "Resetup".
# ============================================================================

#Requires -Version 5.1

[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host "[RESET] $Message" -ForegroundColor $Color
}

Write-Log "Starting environment reset..."

# 1. Stop Processes (Optional/Interactive)
$Processes = Get-Process -Name "terminal64", "python" -ErrorAction SilentlyContinue
if ($Processes) {
    Write-Log "Found running processes that might interfere:" "Yellow"
    $Processes | Format-Table Id, ProcessName, MainWindowTitle -AutoSize

    if ($Force -or (Read-Host "Do you want to attempt to stop these processes? (y/n)") -eq 'y') {
        foreach ($p in $Processes) {
            # Be careful with Python, only kill if it looks like ours (hard to tell without command line parsing which is complex in PS5)
            # So we'll skip python for safety unless user forced, or just warn.
            if ($p.ProcessName -eq "terminal64") {
                Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
                Write-Log "Stopped terminal64 (PID $($p.Id))" "Green"
            }
            else {
                 Write-Log "Skipping $($p.ProcessName) (PID $($p.Id)) - please close manually if needed." "Yellow"
            }
        }
    }
}

# 2. Clean Directories
$DirsToClean = @(
    Join-Path $RepoRoot "dist",
    Join-Path $RepoRoot "logs"
)

foreach ($Dir in $DirsToClean) {
    if (Test-Path $Dir) {
        Write-Log "Cleaning $Dir..."
        Remove-Item -Path $Dir -Recurse -Force -ErrorAction SilentlyContinue
        New-Item -ItemType Directory -Path $Dir -Force | Out-Null
        Write-Log "Cleaned $Dir" "Green"
    }
}

# 3. Clean __pycache__
Write-Log "Removing __pycache__ directories..."
Get-ChildItem -Path $RepoRoot -Filter "__pycache__" -Recurse -Directory -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
Write-Log "__pycache__ removed." "Green"

# 4. Verify Setup
Write-Log "Verifying setup with startup script (Dry Run)..."
$StartupScript = Join-Path $ScriptDir "startup.ps1"
if (Test-Path $StartupScript) {
    & $StartupScript -DryRun
} else {
    Write-Log "startup.ps1 not found!" "Red"
}

Write-Log "Reset complete!" "Green"
Write-Log "To start the project, run: .\scripts\startup.ps1" "Cyan"
