# Check EA Status and Running Status
# Verifies if EA is compiled, attached, and running

param(
    [string]$Account = "411534497",
    [string]$MT5TerminalPath = "C:\Users\USER\AppData\Roaming\MetaQuotes\Terminal\53785E099C927DB68A545C249CDBCE06"
)

$ErrorActionPreference = "Continue"

Write-Host "========================================"
Write-Host "EA STATUS CHECK - Account $Account"
Write-Host "========================================"
Write-Host ""

$eaPath = Join-Path $MT5TerminalPath "MQL5\Experts"
$indicatorsPath = Join-Path $MT5TerminalPath "MQL5\Indicators"
$logsPath = Join-Path $MT5TerminalPath "logs"

# Check 1: EA Source Files
Write-Host "1. Checking EA source files..." -ForegroundColor Cyan
$eaFiles = @()
if (Test-Path $eaPath) {
    $eaFiles = Get-ChildItem $eaPath -Filter "*SMC*.mq5" -File -Recurse -ErrorAction SilentlyContinue
    if ($eaFiles) {
        foreach ($eaFile in $eaFiles) {
            $ex5Path = $eaFile.FullName -replace '\.mq5$', '.ex5'
            $compiled = Test-Path $ex5Path

            Write-Host "  📄 $($eaFile.Name)" -ForegroundColor Gray
            if ($compiled) {
                Write-Host "    ✅ Compiled (.ex5 exists)" -ForegroundColor Green
                $ex5File = Get-Item $ex5Path
                Write-Host "    📅 Compiled: $(Get-Date $ex5File.LastWriteTime -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
            } else {
                Write-Host "    ❌ NOT COMPILED - Needs compilation in MetaEditor (F7)" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "  ⚠️ No SMC EA files found in: $eaPath" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ❌ Experts folder not found: $eaPath" -ForegroundColor Red
}

Write-Host ""

# Check 2: Indicator Files
Write-Host "2. Checking indicator files..." -ForegroundColor Cyan
if (Test-Path $indicatorsPath) {
    $indFiles = Get-ChildItem $indicatorsPath -Filter "*SMC*.mq5" -File -ErrorAction SilentlyContinue
    if ($indFiles) {
        foreach ($indFile in $indFiles) {
            $ex5Path = $indFile.FullName -replace '\.mq5$', '.ex5'
            $compiled = Test-Path $ex5Path
            $status = if ($compiled) { "✅ Compiled" } else { "❌ NOT COMPILED" }
            $color = if ($compiled) { "Green" } else { "Red" }
            Write-Host "  📊 $($indFile.Name) - $status" -ForegroundColor $color
        }
    } else {
        Write-Host "  ⚠️ No SMC indicator files found" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⚠️ Indicators folder not found" -ForegroundColor Yellow
}

Write-Host ""

# Check 3: Log Files
Write-Host "3. Checking Experts log for activity..." -ForegroundColor Cyan
if (Test-Path $logsPath) {
    # Check for expert log files
    $expertLogs = Get-ChildItem "$logsPath\*.log" -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match "expert" -or $_.Name -match "411534497" } |
        Sort-Object LastWriteTime -Descending | Select-Object -First 5

    if ($expertLogs) {
        Write-Host "  📋 Recent log activity:" -ForegroundColor Gray
        foreach ($log in $expertLogs) {
            $logContent = Get-Content $log.FullName -Tail 5 -ErrorAction SilentlyContinue
            Write-Host "    📄 $($log.Name) ($(Get-Date $log.LastWriteTime -Format 'MM/dd HH:mm:ss'))" -ForegroundColor Gray
            if ($logContent) {
                $lastLines = $logContent | Select-Object -Last 2
                foreach ($line in $lastLines) {
                    if ($line -match "SMC|411534497|expert|error|warning" -or $line.Length -gt 0) {
                        Write-Host "      $line" -ForegroundColor $(if ($line -match "error|Error|ERROR") { "Red" } elseif ($line -match "warning|Warning") { "Yellow" } else { "DarkGray" })
                    }
                }
            }
        }
    } else {
        Write-Host "  ⚠️ No recent expert log files found" -ForegroundColor Yellow
        Write-Host "    💡 If EA is running, logs may be in MT5's Toolbox → Experts tab" -ForegroundColor Gray
    }
} else {
    Write-Host "  ⚠️ Logs folder not found" -ForegroundColor Yellow
}

Write-Host ""

# Check 4: Configuration Files
Write-Host "4. Checking account configuration..." -ForegroundColor Cyan
$configPath = Join-Path $MT5TerminalPath "_setup\account_$Account"
if (Test-Path $configPath) {
    Write-Host "  ✅ Account setup folder exists" -ForegroundColor Green
    $configFile = Join-Path $configPath "account_config.ini"
    if (Test-Path $configFile) {
        Write-Host "  ✅ Account configuration file found" -ForegroundColor Green
        $config = Get-Content $configFile -Raw
        if ($config -match "Status\s*=\s*Active") {
            Write-Host "  ✅ Account marked as Active" -ForegroundColor Green
        }
    }
} else {
    Write-Host "  ⚠️ Account setup folder not found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================"
Write-Host "STATUS SUMMARY" -ForegroundColor Cyan
Write-Host "========================================"
Write-Host ""

# Summary
$allCompiled = $true
$hasEA = $false

if ($eaFiles) {
    $hasEA = $true
    foreach ($eaFile in $eaFiles) {
        $ex5Path = $eaFile.FullName -replace '\.mq5$', '.ex5'
        if (-not (Test-Path $ex5Path)) {
            $allCompiled = $false
        }
    }
}

if (-not $hasEA) {
    Write-Host "❌ EA FILES NOT FOUND" -ForegroundColor Red
    Write-Host "   Action: Deploy EA files to: $eaPath" -ForegroundColor Yellow
} elseif (-not $allCompiled) {
    Write-Host "⚠️ EA FILES NOT COMPILED" -ForegroundColor Yellow
    Write-Host "   Action: Open MetaEditor (F4) and compile .mq5 files (F7)" -ForegroundColor Yellow
} else {
    Write-Host "✅ EA FILES READY" -ForegroundColor Green
    Write-Host "   Status: Files are compiled and ready" -ForegroundColor Gray
}

Write-Host ""
Write-Host "📋 To verify if EA is RUNNING in MT5:" -ForegroundColor Cyan
Write-Host "   1. Check AutoTrading button is GREEN/enabled" -ForegroundColor Gray
Write-Host "   2. Check chart shows EA indicator (😊 smiley face)" -ForegroundColor Gray
Write-Host "   3. Open Toolbox → Experts tab for activity logs" -ForegroundColor Gray
Write-Host "   4. Check for trades in Trade tab" -ForegroundColor Gray
Write-Host ""
Write-Host "⚠️ NOTE: This script only checks files. Actual running status" -ForegroundColor Yellow
Write-Host "   must be verified in MT5 application itself." -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================"
