@echo off
REM ============================================================================
REM MQL5 Trading Automation - Windows Startup Script
REM ============================================================================
REM This script automates the startup of all trading components on Windows
REM Run this at system startup via Task Scheduler or Startup folder
REM ============================================================================

setlocal enabledelayedexpansion

REM Get script directory
set "SCRIPT_DIR=%~dp0"
set "REPO_ROOT=%SCRIPT_DIR%.."
set "LOGS_DIR=%REPO_ROOT%\logs"

REM Create logs directory if it doesn't exist
if not exist "%LOGS_DIR%" mkdir "%LOGS_DIR%"

REM Set log file with timestamp
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "LOG_FILE=%LOGS_DIR%\startup_%dt:~0,8%_%dt:~8,6%.log"

REM Start logging
echo ============================================================ > "%LOG_FILE%"
echo MQL5 Trading Automation Startup >> "%LOG_FILE%"
echo Start Time: %date% %time% >> "%LOG_FILE%"
echo ============================================================ >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

echo Starting MQL5 Trading Automation...
echo Log file: %LOG_FILE%
echo.

REM Check if Python is installed
echo [1/5] Checking Python installation... >> "%LOG_FILE%"

REM Try standard python command first
set "PYTHON_EXE=python"
python --version >> "%LOG_FILE%" 2>&1
if %errorlevel% equ 0 (
    echo Python found in PATH >> "%LOG_FILE%"
    goto :python_found
)

REM Check Windows Store Python
set "PYTHON_EXE=%LOCALAPPDATA%\Microsoft\WindowsApps\python.exe"
if exist "%PYTHON_EXE%" (
    "%PYTHON_EXE%" --version >> "%LOG_FILE%" 2>&1
    if %errorlevel% equ 0 (
        echo Found Windows Store Python >> "%LOG_FILE%"
        goto :python_found
    )
)

REM Check Windows Store Python3
set "PYTHON_EXE=%LOCALAPPDATA%\Microsoft\WindowsApps\python3.exe"
if exist "%PYTHON_EXE%" (
    "%PYTHON_EXE%" --version >> "%LOG_FILE%" 2>&1
    if %errorlevel% equ 0 (
        echo Found Windows Store Python3 >> "%LOG_FILE%"
        goto :python_found
    )
)

REM Python not found
echo ERROR: Python is not installed or not found >> "%LOG_FILE%"
echo ERROR: Python is not installed or not found
echo Please install Python 3.8 or higher from https://www.python.org/ or Microsoft Store
pause
exit /b 1

:python_found
echo Python check passed >> "%LOG_FILE%"
echo [OK] Python installed

REM Check repository structure
echo [2/5] Checking repository structure... >> "%LOG_FILE%"
if not exist "%REPO_ROOT%\mt5\MQL5" (
    echo ERROR: MT5 directory not found >> "%LOG_FILE%"
    echo ERROR: MT5 directory not found at %REPO_ROOT%\mt5\MQL5
    pause
    exit /b 1
)
echo Repository structure OK >> "%LOG_FILE%"
echo [OK] Repository structure valid

REM Run Python startup orchestrator
echo [3/5] Starting Python orchestrator... >> "%LOG_FILE%"
echo [3/5] Starting Python orchestrator...
cd /d "%REPO_ROOT%"
"%PYTHON_EXE%" "%SCRIPT_DIR%startup_orchestrator.py" >> "%LOG_FILE%" 2>&1
set "ORCHESTRATOR_EXIT=%errorlevel%"

if %ORCHESTRATOR_EXIT% neq 0 (
    echo ERROR: Python orchestrator failed with exit code %ORCHESTRATOR_EXIT% >> "%LOG_FILE%"
    echo ERROR: Python orchestrator failed. Check log file: %LOG_FILE%
    pause
    exit /b %ORCHESTRATOR_EXIT%
)
echo [OK] Python orchestrator completed

REM Optional: Start MT5 Terminal directly if not started by orchestrator
echo [4/5] Checking MT5 Terminal... >> "%LOG_FILE%"
tasklist /FI "IMAGENAME eq terminal64.exe" 2>NUL | find /I /N "terminal64.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo MT5 Terminal is already running >> "%LOG_FILE%"
    echo [OK] MT5 Terminal running
) else (
    echo MT5 Terminal not found. Attempting to start... >> "%LOG_FILE%"
    echo [WARN] MT5 Terminal not running, attempting to start...
    
    REM Try common installation paths
    set "MT5_FOUND=0"
    if exist "C:\Program Files\Exness Terminal\terminal64.exe" (
        start "" "C:\Program Files\Exness Terminal\terminal64.exe" /portable
        set "MT5_FOUND=1"
        echo Started MT5 from C:\Program Files\Exness Terminal >> "%LOG_FILE%"
    )
    
    if !MT5_FOUND!==0 (
        if exist "%APPDATA%\MetaQuotes\Terminal\terminal64.exe" (
            start "" "%APPDATA%\MetaQuotes\Terminal\terminal64.exe" /portable
            set "MT5_FOUND=1"
            echo Started MT5 from AppData >> "%LOG_FILE%"
        )
    )
    
    if !MT5_FOUND!==0 (
        echo WARNING: Could not find MT5 Terminal executable >> "%LOG_FILE%"
        echo [WARN] MT5 Terminal not found in common locations
        echo Please start MT5 manually or update the script with correct path
    ) else (
        echo [OK] MT5 Terminal started
        timeout /t 15 /nobreak > NUL
    )
)

REM Run validation check
echo [5/5] Running validation checks... >> "%LOG_FILE%"
echo [5/5] Running validation checks...
"%PYTHON_EXE%" "%REPO_ROOT%\scripts\ci_validate_repo.py" >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo WARNING: Validation check failed >> "%LOG_FILE%"
    echo [WARN] Validation check failed, but continuing...
) else (
    echo Validation passed >> "%LOG_FILE%"
    echo [OK] Validation passed
)

echo. >> "%LOG_FILE%"
echo ============================================================ >> "%LOG_FILE%"
echo Startup Complete >> "%LOG_FILE%"
echo End Time: %date% %time% >> "%LOG_FILE%"
echo ============================================================ >> "%LOG_FILE%"

echo.
echo ============================================================
echo Startup sequence completed successfully!
echo ============================================================
echo.
echo Log file saved to: %LOG_FILE%
echo.
echo Press any key to close this window...
pause > NUL

exit /b 0
