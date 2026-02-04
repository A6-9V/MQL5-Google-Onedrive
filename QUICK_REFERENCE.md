# Quick Reference Guide

## 🚀 Start Automation System

### Windows
```powershell
# Option 1: PowerShell (Recommended)
powershell -ExecutionPolicy Bypass -File scripts\startup.ps1

# Option 2: Batch File
scripts\startup.bat

# Option 3: Python
python scripts\startup_orchestrator.py
```

### Linux/WSL
```bash
# Option 1: Shell Script
./scripts/startup.sh

# Option 2: Python
python3 scripts/startup_orchestrator.py
```

## 🔧 Setup Auto-Start

### Windows
```powershell
# Create Scheduled Task (runs at boot)
powershell -ExecutionPolicy Bypass -File scripts\startup.ps1 -CreateScheduledTask

# Verify Task
Get-ScheduledTask -TaskName "MQL5*" | Get-ScheduledTaskInfo
```

### Linux
```bash
# Option 1: systemd (Recommended)
./scripts/startup.sh --setup-systemd
sudo systemctl enable mql5-trading-automation
sudo systemctl start mql5-trading-automation

# Option 2: Cron
./scripts/startup.sh --setup-cron
```

## 🧪 Testing Commands

```bash
# Run all integration tests
python3 scripts/test_automation.py

# Validate repository
python3 scripts/ci_validate_repo.py

# Dry run (test without executing)
python3 scripts/startup_orchestrator.py --dry-run

# Test with PowerShell (Windows)
powershell -ExecutionPolicy Bypass -File scripts\startup.ps1 -DryRun
```

## 📊 Monitor & Control

```bash
# Monitor processes for 1 hour
python3 scripts/startup_orchestrator.py --monitor 3600

# Monitor indefinitely
python3 scripts/startup_orchestrator.py --monitor 0

# Check MT5 is running (Windows)
tasklist | findstr terminal64.exe

# Check MT5 is running (Linux/WSL)
ps aux | grep terminal64
```

## 📝 Check Logs

```bash
# View latest log
ls -lt logs/ | head -5

# View specific log
cat logs/startup_20260106_*.log

# Monitor log in real-time
tail -f logs/startup_*.log
```

## ⚙️ Configuration

```bash
# Edit configuration
nano config/startup_config.json

# Create new config template
python3 scripts/startup_orchestrator.py --create-config

# Validate JSON syntax
python3 -m json.tool config/startup_config.json
```

## 🔍 Troubleshooting

```bash
# Check Python version
python3 --version

# Check if script is executable
ls -l scripts/*.py scripts/*.sh

# Test script syntax
bash -n scripts/startup.sh

# View recent git changes
git log --oneline -5

# Check system status
df -h  # Disk space
free -h  # Memory
```

## 📦 Package & Deploy

> **⚠️ Note:** Deployed indicators/EAs require **MT5 Desktop**. Exness Web Terminal is not supported.

```bash
# Package MT5 files
./scripts/package_mt5.sh

# Deploy to MT5 data folder (replace path)
./scripts/deploy_mt5.sh "/path/to/MT5/Data/Folder"

# Find your MT5 data folder (Windows)
# In MT5: File → Open Data Folder
```

## 🚀 Release Management

```bash
# Prepare and create a release (interactive)
bash scripts/prepare_release.sh

# Full automated release
bash scripts/prepare_release.sh --full

# Individual steps
bash scripts/prepare_release.sh --check      # Check prerequisites
bash scripts/prepare_release.sh --validate   # Validate repository
bash scripts/prepare_release.sh --test       # Run tests
bash scripts/prepare_release.sh --package    # Package files
bash scripts/prepare_release.sh --tag 1.22.0 # Create tag

# Download latest release
wget https://github.com/A6-9V/MQL5-Google-Onedrive/releases/latest/download/Exness_MT5_MQL5.zip

# View releases
gh release list  # if GitHub CLI is installed
```

See [RELEASE_QUICK_REF.md](RELEASE_QUICK_REF.md) for more release commands.

## 🆘 Common Issues

### Permission Denied
```bash
# Fix script permissions
chmod +x scripts/*.py scripts/*.sh
```

### Python Not Found
```bash
# Windows
winget install Python.Python.3.12

# Linux
sudo apt update && sudo apt install python3 python3-pip
```

### PowerShell Execution Policy
```powershell
# Temporary bypass (current session)
Set-ExecutionPolicy Bypass -Scope Process

# Permanent fix (current user)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### MT5 Not Starting
1. Verify MT5 is installed
2. Check path in `config/startup_config.json`
3. Test manual launch first
4. Check logs in `logs/` directory

## 📚 Documentation

- **Full Guide**: `docs/Startup_Automation_Guide.md`
- **Quick Start**: `docs/Quick_Start_Automation.md`
- **Windows Setup**: `docs/Windows_Task_Scheduler_Setup.md`
- **Verification**: `VERIFICATION.md`
- **Features**: `AUTOMATION_FEATURES.md`

## 🔗 Useful Links

- **Repository**: https://github.com/A6-9V/MQL5-Google-Onedrive
- **Issues**: https://github.com/A6-9V/MQL5-Google-Onedrive/issues
- **WhatsApp**: https://chat.whatsapp.com/DYemXrBnMD63K55bjUMKYF

---

*For detailed information, see [VERIFICATION.md](VERIFICATION.md)*
