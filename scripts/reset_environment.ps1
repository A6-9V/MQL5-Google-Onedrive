# ============================================================================
# MQL5 Trading Automation - Environment Reset Script
# ============================================================================
# This script resets the environment by cleaning up logs, build artifacts,
# and temporary files. It helps ensuring a clean slate for "Resetup".
# ============================================================================

#Requires -Version 5.1

[CmdletBinding()]
param(
    [switch]$Force,
    [string]$MT5DataPath = ""
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

# 2. Clean Project Directories
$DirsToClean = @(
    Join-Path $RepoRoot "dist",
    Join-Path $RepoRoot "logs"
)

foreach ($Dir in $DirsToClean) {
    if (Test-Path $Dir) {
        Write-Log "Cleaning project directory: $Dir..."
        Remove-Item -Path $Dir -Recurse -Force -ErrorAction SilentlyContinue
        New-Item -ItemType Directory -Path $Dir -Force | Out-Null
        Write-Log "Cleaned $Dir" "Green"
    }
}

# 3. Clean MT5 Data Directory (If provided)
if ($MT5DataPath -and (Test-Path $MT5DataPath)) {
    Write-Log "Processing MT5 Data Directory: $MT5DataPath"
    $MT5LogsDir = Join-Path $MT5DataPath "Logs"

    if (Test-Path $MT5LogsDir) {
        Write-Log "Cleaning MT5 Logs directory..."

        # Define artifacts that should NOT be in the logs folder (based on user report)
        $ArtifactsToRemove = @(
            ".git",
            ".gitignore",
            "package.json",
            "*.md",
            "*.ps1"
        )

        foreach ($Pattern in $ArtifactsToRemove) {
            Get-ChildItem -Path $MT5LogsDir -Filter $Pattern -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
                Write-Log "Removing artifact: $($_.FullName)" "Yellow"
                Remove-Item -Path $_.FullName -Recurse -Force
            }
        }

        # Clean standard log files if Force is used, otherwise keep them or ask
        if ($Force -or (Read-Host "Delete all *.log files in MT5 Logs? (y/n)") -eq 'y') {
            Get-ChildItem -Path $MT5LogsDir -Filter "*.log" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force
            Write-Log "Deleted all .log files in MT5 Logs" "Green"
        }
    } else {
        Write-Log "MT5 Logs directory not found at $MT5LogsDir" "Yellow"
    }
} elseif ($MT5DataPath) {
    Write-Log "Provided MT5 Data Path does not exist: $MT5DataPath" "Red"
}

# 4. Clean __pycache__
Write-Log "Removing __pycache__ directories..."
Get-ChildItem -Path $RepoRoot -Filter "__pycache__" -Recurse -Directory -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
Write-Log "__pycache__ removed." "Green"

# 5. Verify Setup
Write-Log "Verifying setup with startup script (Dry Run)..."
$StartupScript = Join-Path $ScriptDir "startup.ps1"
if (Test-Path $StartupScript) {
    & $StartupScript -DryRun
} else {
    Write-Log "startup.ps1 not found!" "Red"
}

Write-Log "Reset complete!" "Green"
Write-Log "To start the project, run: .\scripts\startup.ps1" "Cyan"
