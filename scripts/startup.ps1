# ============================================================================
# MQL5 Trading Automation - PowerShell Startup Script
# ============================================================================
# This script provides advanced startup automation for Windows with better
# error handling, logging, and process management compared to batch files
# ============================================================================

#Requires -Version 5.1

[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$NoWait,
    [switch]$Verbose,
    [string]$ConfigPath,
    [switch]$CreateScheduledTask
)

# Set strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Script configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$LogsDir = Join-Path $RepoRoot "logs"
$MT5Dir = Join-Path $RepoRoot "mt5\MQL5"

# Create logs directory
if (-not (Test-Path $LogsDir)) {
    New-Item -ItemType Directory -Path $LogsDir -Force | Out-Null
}

# Set up logging
$LogFile = Join-Path $LogsDir "startup_ps_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$Script:LogFile = $LogFile

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    
    # Write to log file
    Add-Content -Path $Script:LogFile -Value $LogMessage
    
    # Write to console with color
    switch ($Level) {
        "INFO"    { Write-Host $Message -ForegroundColor Cyan }
        "WARN"    { Write-Host $Message -ForegroundColor Yellow }
        "ERROR"   { Write-Host $Message -ForegroundColor Red }
        "SUCCESS" { Write-Host $Message -ForegroundColor Green }
    }
}

function Find-PythonExecutable {
    # Try to find Python executable, including Windows Store installations
    Write-Log "Searching for Python executable..." -Level INFO
    
    # Try standard python command first
    try {
        $null = & python --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Found Python in PATH" -Level INFO
            return "python"
        }
    }
    catch { }
    
    # Check Windows Store Python installations
    $WindowsAppsPaths = @(
        "$env:LOCALAPPDATA\Microsoft\WindowsApps\python.exe",
        "$env:LOCALAPPDATA\Microsoft\WindowsApps\python3.exe"
    )
    
    foreach ($Path in $WindowsAppsPaths) {
        if (Test-Path $Path) {
            try {
                $Version = & $Path --version 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Log "Found Windows Store Python at: $Path" -Level INFO
                    Write-Log "Version: $Version" -Level INFO
                    return $Path
                }
            }
            catch { }
        }
    }
    
    # Check for Python in Program Files (standard installations)
    $ProgramFilesPaths = @(
        "C:\Program Files\Python*\python.exe",
        "C:\Program Files (x86)\Python*\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python*\python.exe"
    )
    
    foreach ($Pattern in $ProgramFilesPaths) {
        $FoundPaths = Get-ChildItem -Path $Pattern -ErrorAction SilentlyContinue
        if ($FoundPaths) {
            $Path = $FoundPaths[0].FullName
            try {
                $Version = & $Path --version 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Log "Found Python at: $Path" -Level INFO
                    Write-Log "Version: $Version" -Level INFO
                    return $Path
                }
            }
            catch { }
        }
    }
    
    return $null
}

function Test-Prerequisites {
    Write-Log "Checking prerequisites..." -Level INFO
    
    # Check PowerShell version
    $PSVersion = $PSVersionTable.PSVersion
    Write-Log "PowerShell Version: $PSVersion" -Level INFO
    
    if ($PSVersion.Major -lt 5) {
        Write-Log "PowerShell 5.1 or higher is required" -Level ERROR
        return $false
    }
    
    # Check Python installation
    $Script:PythonExe = Find-PythonExecutable
    if (-not $Script:PythonExe) {
        Write-Log "Python is not installed or not found" -Level ERROR
        Write-Log "Install from: https://www.python.org/ or Microsoft Store" -Level ERROR
        return $false
    }
    
    try {
        $PythonVersion = & $Script:PythonExe --version 2>&1
        Write-Log "Python: $PythonVersion" -Level INFO
    }
    catch {
        Write-Log "Python found but failed to execute" -Level ERROR
        return $false
    }
    
    # Check repository structure
    if (-not (Test-Path $MT5Dir)) {
        Write-Log "MT5 directory not found: $MT5Dir" -Level ERROR
        return $false
    }
    Write-Log "MT5 directory found" -Level INFO
    
    # Check Python orchestrator script
    $OrchestratorScript = Join-Path $ScriptDir "startup_orchestrator.py"
    if (-not (Test-Path $OrchestratorScript)) {
        Write-Log "Orchestrator script not found: $OrchestratorScript" -Level WARN
    }
    
    Write-Log "Prerequisites check completed" -Level SUCCESS
    return $true
}

function Start-MT5Terminal {
    param([bool]$DryRun = $false)
    
    Write-Log "Checking MT5 Terminal status..." -Level INFO
    
    # Check if already running
    $MT5Process = Get-Process -Name "terminal64" -ErrorAction SilentlyContinue
    if ($MT5Process) {
        Write-Log "MT5 Terminal is already running (PID: $($MT5Process.Id))" -Level INFO
        return $true
    }
    
    # Try to find and start MT5 Terminal
    $MT5Paths = @(
        "C:\Program Files\MetaTrader 5 EXNESS\terminal64.exe",
        "C:\Program Files\Exness Terminal\terminal64.exe",
        "C:\Program Files\MetaTrader 5\terminal64.exe",
        "$env:APPDATA\MetaQuotes\Terminal\terminal64.exe",
        "C:\Program Files (x86)\Exness Terminal\terminal64.exe"
    )
    
    foreach ($Path in $MT5Paths) {
        if (Test-Path $Path) {
            Write-Log "Found MT5 Terminal at: $Path" -Level INFO
            
            if (-not $DryRun) {
                try {
                    Start-Process -FilePath $Path -ArgumentList "/portable" -WindowStyle Normal
                    Write-Log "Started MT5 Terminal" -Level SUCCESS
                    Start-Sleep -Seconds 15  # Wait for MT5 to initialize
                    return $true
                }
                catch {
                    Write-Log "Failed to start MT5 Terminal: $_" -Level ERROR
                    return $false
                }
            }
            else {
                Write-Log "[DRY RUN] Would start: $Path" -Level INFO
                return $true
            }
        }
    }
    
    Write-Log "MT5 Terminal not found in common locations" -Level WARN
    Write-Log "Please install MT5 or update the script with the correct path" -Level WARN
    return $false
}

function Start-PythonOrchestrator {
    param([bool]$DryRun = $false, [bool]$NoWait = $false)
    
    Write-Log "Starting Python orchestrator..." -Level INFO
    
    $OrchestratorScript = Join-Path $ScriptDir "startup_orchestrator.py"
    
    if (-not (Test-Path $OrchestratorScript)) {
        Write-Log "Orchestrator script not found, skipping" -Level WARN
        return $true
    }
    
    if ($DryRun) {
        Write-Log "[DRY RUN] Would execute: python $OrchestratorScript" -Level INFO
        return $true
    }
    
    try {
        # Use --monitor 0 for infinite monitoring to keep processes running
        # When NoWait is used (scheduled task), processes should stay alive
        $MonitorArg = if ($NoWait) { "--monitor", "0" } else { @() }
        $Process = Start-Process -FilePath $Script:PythonExe `
            -ArgumentList (@($OrchestratorScript) + $MonitorArg) `
            -WorkingDirectory $RepoRoot `
            -NoNewWindow `
            -PassThru
        
        if (-not $NoWait) {
            $Process.WaitForExit()
            if ($Process.ExitCode -eq 0) {
                Write-Log "Python orchestrator completed successfully" -Level SUCCESS
                return $true
            }
            else {
                Write-Log "Python orchestrator failed with exit code: $($Process.ExitCode)" -Level ERROR
                return $false
            }
        }
        else {
            Write-Log "Python orchestrator started in background (monitoring mode)" -Level SUCCESS
            return $true
        }
    }
    catch {
        Write-Log "Failed to run Python orchestrator: $_" -Level ERROR
        return $false
    }
}

function Start-ValidationCheck {
    Write-Log "Running validation checks..." -Level INFO
    
    $ValidatorScript = Join-Path $RepoRoot "scripts\ci_validate_repo.py"
    
    if (-not (Test-Path $ValidatorScript)) {
        Write-Log "Validator script not found, skipping" -Level WARN
        return $true
    }
    
    try {
        $Output = & $Script:PythonExe $ValidatorScript 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Validation passed" -Level SUCCESS
            return $true
        }
        else {
            Write-Log "Validation failed: $Output" -Level WARN
            return $true  # Non-critical
        }
    }
    catch {
        Write-Log "Validation check error: $_" -Level WARN
        return $true  # Non-critical
    }
}

function New-StartupScheduledTask {
    Write-Log "Creating scheduled task for automatic startup..." -Level INFO
    
    $TaskName = "MQL5_Trading_Automation_Startup"
    $TaskDescription = "Automatically start MQL5 trading automation on system startup"
    $ScriptPath = $MyInvocation.MyCommand.Path
    
    # Check if task already exists
    $ExistingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($ExistingTask) {
        Write-Log "Scheduled task already exists. Removing old task..." -Level WARN
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    }
    
    # Create action
    $Action = New-ScheduledTaskAction `
        -Execute "powershell.exe" `
        -Argument "-ExecutionPolicy Bypass -File `"$ScriptPath`" -NoWait"
    
    # Create trigger (at startup)
    $Trigger = New-ScheduledTaskTrigger -AtStartup
    
    # Create settings
    $Settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -RunOnlyIfNetworkAvailable
    
    # Create principal (run with user privileges)
    # Using Limited instead of Highest for security - MT5 doesn't require elevation
    $Principal = New-ScheduledTaskPrincipal `
        -UserId "$env:USERDOMAIN\$env:USERNAME" `
        -LogonType Interactive `
        -RunLevel Limited
    
    # Register the task
    try {
        Register-ScheduledTask `
            -TaskName $TaskName `
            -Description $TaskDescription `
            -Action $Action `
            -Trigger $Trigger `
            -Settings $Settings `
            -Principal $Principal `
            -Force | Out-Null
        
        Write-Log "Scheduled task created successfully: $TaskName" -Level SUCCESS
        Write-Log "The automation will start automatically on system boot" -Level INFO
        return $true
    }
    catch {
        Write-Log "Failed to create scheduled task: $_" -Level ERROR
        return $false
    }
}

function Show-Summary {
    param([hashtable]$Results)
    
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "                 STARTUP SUMMARY" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($Key in $Results.Keys) {
        $Status = if ($Results[$Key]) { "[PASS]" } else { "[FAIL]" }
        $Color = if ($Results[$Key]) { "Green" } else { "Red" }
        Write-Host ("  {0,-30} {1}" -f $Key, $Status) -ForegroundColor $Color
    }
    
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "Log file: $LogFile" -ForegroundColor Gray
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
}

# ============================================================================
# Main execution
# ============================================================================

try {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "    MQL5 Trading Automation - PowerShell Startup" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Log "Starting MQL5 Trading Automation..." -Level INFO
    Write-Log "Repository root: $RepoRoot" -Level INFO
    Write-Log "Log file: $LogFile" -Level INFO
    Write-Host ""
    
    # Handle scheduled task creation
    if ($CreateScheduledTask) {
        $Success = New-StartupScheduledTask
        exit $(if ($Success) { 0 } else { 1 })
    }
    
    # Initialize results
    $Results = @{}
    
    # Step 1: Check prerequisites
    $Results["Prerequisites"] = Test-Prerequisites
    if (-not $Results["Prerequisites"]) {
        Write-Log "Prerequisites check failed. Aborting." -Level ERROR
        exit 1
    }
    
    # Step 2: Start Python orchestrator
    Write-Host ""
    $Results["Python Orchestrator"] = Start-PythonOrchestrator -DryRun $DryRun -NoWait $NoWait
    
    # Step 3: Start MT5 Terminal
    Write-Host ""
    $Results["MT5 Terminal"] = Start-MT5Terminal -DryRun $DryRun
    
    # Step 4: Run validation
    Write-Host ""
    $Results["Validation"] = Start-ValidationCheck
    
    # Show summary
    Write-Host ""
    Show-Summary -Results $Results
    
    # Determine overall success
    $AllSuccess = $Results.Values | Where-Object { -not $_ } | Measure-Object | Select-Object -ExpandProperty Count
    
    if ($AllSuccess -eq 0) {
        Write-Log "All components started successfully!" -Level SUCCESS
        
        if (-not $NoWait) {
            Write-Host ""
            Write-Host "Press any key to exit..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
        exit 0
    }
    else {
        Write-Log "Some components failed to start" -Level WARN
        exit 1
    }
}
catch {
    Write-Log "Unexpected error: $_" -Level ERROR
    Write-Log $_.ScriptStackTrace -Level ERROR
    exit 1
}
