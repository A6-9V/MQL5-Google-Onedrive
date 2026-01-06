# MQL5 Trading Automation - Startup Guide

## Overview

This repository includes a comprehensive automation system for starting up all components required for automated forex trading with MT5 (MetaTrader 5) terminal and custom scripts. The system supports **Windows**, **Linux**, and **Windows Subsystem for Linux (WSL)**.

## Components

### 1. **Python Orchestrator** (`scripts/startup_orchestrator.py`)
Advanced Python script that manages the startup sequence of all components with:
- Configurable component startup order
- Proper initialization delays between components
- Comprehensive logging
- Process monitoring
- Error handling and recovery

### 2. **Windows Batch Script** (`scripts/startup.bat`)
Simple Windows batch file for basic automation:
- Easy to use for Windows users
- Minimal dependencies
- Suitable for Task Scheduler
- Good for quick testing

### 3. **PowerShell Script** (`scripts/startup.ps1`)
Advanced Windows automation with:
- Better error handling than batch files
- Colored output and logging
- Scheduled task creation
- Administrator privilege management
- Dry-run mode for testing

### 4. **Linux/WSL Shell Script** (`scripts/startup.sh`)
Bash script for Linux and WSL environments:
- systemd service integration
- Cron job setup
- Wine support for MT5 on Linux
- WSL detection and Windows interop

### 5. **Configuration File** (`config/startup_config.json`)
JSON configuration for customizing startup behavior:
- Define components to start
- Set initialization delays
- Configure platform-specific settings
- Add custom scripts

## Quick Start

### Windows Users

#### Option 1: Using Batch Script (Simplest)
```cmd
cd C:\path\to\MQL5-Google-Onedrive
scripts\startup.bat
```

#### Option 2: Using PowerShell (Recommended)
```powershell
cd C:\path\to\MQL5-Google-Onedrive
powershell -ExecutionPolicy Bypass -File scripts\startup.ps1
```

#### Option 3: Using Python Orchestrator
```cmd
cd C:\path\to\MQL5-Google-Onedrive
python scripts\startup_orchestrator.py
```

### Linux/WSL Users

```bash
cd /path/to/MQL5-Google-Onedrive
./scripts/startup.sh
```

## Setting Up Automatic Startup

### Windows - Task Scheduler

#### Using PowerShell (Automated)
```powershell
cd C:\path\to\MQL5-Google-Onedrive
powershell -ExecutionPolicy Bypass -File scripts\startup.ps1 -CreateScheduledTask
```

#### Manual Setup
1. Open **Task Scheduler** (`taskschd.msc`)
2. Click **Create Task** (not "Create Basic Task")
3. **General** tab:
   - Name: `MQL5 Trading Automation`
   - Check "Run with highest privileges"
   - Configure for: Windows 10
4. **Triggers** tab:
   - New trigger
   - Begin the task: **At startup**
   - Delay task for: 30 seconds (recommended)
5. **Actions** tab:
   - Action: Start a program
   - Program/script: `powershell.exe`
   - Arguments: `-ExecutionPolicy Bypass -File "C:\path\to\MQL5-Google-Onedrive\scripts\startup.ps1" -NoWait`
   - Start in: `C:\path\to\MQL5-Google-Onedrive`
6. **Conditions** tab:
   - Uncheck "Start only if on AC power"
   - Check "Start whether user is logged on or not"
7. Click OK and enter your password

### Windows - Startup Folder

For user-level startup (simpler but runs only after login):

```cmd
# Create shortcut
# Target: powershell.exe -ExecutionPolicy Bypass -File "C:\path\to\MQL5-Google-Onedrive\scripts\startup.ps1"
# Start in: C:\path\to\MQL5-Google-Onedrive

# Copy to startup folder
copy startup.lnk "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\"
```

### Linux - systemd Service

```bash
cd /path/to/MQL5-Google-Onedrive
./scripts/startup.sh --setup-systemd
```

This creates a systemd service that runs on boot. Control it with:
```bash
sudo systemctl start mql5-trading-automation   # Start now
sudo systemctl stop mql5-trading-automation    # Stop
sudo systemctl status mql5-trading-automation  # Check status
sudo systemctl disable mql5-trading-automation # Disable auto-start
```

### Linux - Cron Job

Alternative to systemd:
```bash
cd /path/to/MQL5-Google-Onedrive
./scripts/startup.sh --setup-cron
```

## Configuration

### Editing Startup Components

Edit `config/startup_config.json` to customize what starts:

```json
{
  "components": [
    {
      "name": "My Custom Script",
      "executable": "python3",
      "args": ["path/to/my_script.py", "--arg1", "value1"],
      "working_dir": null,
      "wait_seconds": 5,
      "required": false,
      "platform_specific": null
    }
  ]
}
```

### Component Options

- **name**: Display name for logging
- **executable**: Path to executable (use full path or ensure it's in PATH)
- **args**: Command-line arguments as array
- **working_dir**: Working directory (null = repository root)
- **wait_seconds**: Seconds to wait after starting before continuing
- **required**: If true, abort startup if this component fails
- **platform_specific**: "windows", "linux", or null for all platforms

### MT5 Terminal Paths

The scripts automatically search common MT5 installation locations:

**Windows:**
- `C:\Program Files\Exness Terminal\terminal64.exe`
- `C:\Program Files\MetaTrader 5\terminal64.exe`
- `%APPDATA%\MetaQuotes\Terminal\terminal64.exe`

**WSL:**
- `/mnt/c/Program Files/Exness Terminal/terminal64.exe`
- `/mnt/c/Program Files/MetaTrader 5/terminal64.exe`

To add custom paths, edit the configuration file or the scripts directly.

## Usage Examples

### Testing (Dry Run)

**PowerShell:**
```powershell
.\scripts\startup.ps1 -DryRun
```

**Python:**
```bash
python scripts/startup_orchestrator.py --dry-run
```

### Monitoring Processes

**Python (monitor for 1 hour):**
```bash
python scripts/startup_orchestrator.py --monitor 3600
```

### Creating Default Config

```bash
python scripts/startup_orchestrator.py --create-config
```

### Custom Config File

```bash
python scripts/startup_orchestrator.py --config path/to/custom_config.json
```

## Logs

All startup activity is logged to the `logs/` directory:

- `logs/startup_YYYYMMDD_HHMMSS.log` - Python orchestrator logs
- `logs/startup_ps_YYYYMMDD_HHMMSS.log` - PowerShell logs  
- Logs are kept for reference and troubleshooting

## Troubleshooting

### Python Not Found

**Windows:**
```cmd
# Download from https://www.python.org/downloads/
# Or use Microsoft Store
```

**Linux/WSL:**
```bash
sudo apt update
sudo apt install python3 python3-pip
```

### MT5 Terminal Not Starting

1. Verify MT5 is installed
2. Check the installation path
3. Update the path in `config/startup_config.json`
4. Try starting MT5 manually first
5. Check Task Manager for existing MT5 processes

### PowerShell Execution Policy Error

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Or run with bypass:
```powershell
powershell -ExecutionPolicy Bypass -File scripts\startup.ps1
```

### Permission Denied (Linux)

```bash
chmod +x scripts/startup.sh
chmod +x scripts/startup_orchestrator.py
```

### WSL - Can't Start Windows MT5

Ensure WSL can access Windows files:
```bash
ls /mnt/c/Program\ Files/
```

If not available, check WSL configuration in `/etc/wsl.conf`.

## Advanced Features

### Email Notifications (Coming Soon)

Configure in `startup_config.json`:
```json
"notifications": {
  "enabled": true,
  "email": "your@email.com",
  "smtp_server": "smtp.gmail.com",
  "smtp_port": 587
}
```

### Webhook Integration (Coming Soon)

Send startup notifications to Slack, Discord, etc:
```json
"notifications": {
  "enabled": true,
  "webhook_url": "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
}
```

### Restart on Failure

The orchestrator can be configured to automatically restart failed components:
```json
"settings": {
  "max_startup_retries": 3,
  "retry_delay_seconds": 30
}
```

## Integration with Existing Workflows

This automation system integrates with:

- **GitHub Actions** - CI/CD workflows in `.github/workflows/`
- **OneDrive Sync** - Automatic sync to OneDrive via rclone
- **MT5 Expert Advisors** - Automatically starts EA scripts
- **Custom Python Scripts** - Add your own trading logic

## System Requirements

### Minimum

- **OS**: Windows 10/11, Linux (Ubuntu 20.04+), WSL 2
- **Python**: 3.8 or higher
- **RAM**: 4 GB
- **Disk**: 1 GB free space

### Recommended

- **OS**: Windows 11 or Ubuntu 22.04 LTS
- **Python**: 3.10 or higher
- **RAM**: 8 GB
- **Disk**: 10 GB free space (for MT5 data and logs)
- **Network**: Stable internet connection

## Security Considerations

1. **Never commit** sensitive data (API keys, passwords) to the repository
2. Use environment variables for secrets
3. Secure MT5 account credentials
4. Review all scripts before running with elevated privileges
5. Keep Python and system packages updated

## Support

- **Issues**: Open an issue on GitHub
- **Email**: Lengkundee01.org@domain.com
- **WhatsApp**: [Agent community](https://chat.whatsapp.com/DYemXrBnMD63K55bjUMKYF)

## License

See [LICENSE](../LICENSE) file in the repository root.
