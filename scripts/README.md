# Scripts Directory

This directory contains automation scripts for the MQL5 trading system.

## Automation Scripts

### Startup Scripts (Choose one based on your platform)

- **`startup.bat`** - Windows batch script for simple automation
- **`startup.ps1`** - PowerShell script with advanced features (recommended for Windows)
- **`startup.sh`** - Bash script for Linux/WSL
- **`startup_orchestrator.py`** - Python orchestrator (cross-platform)

### Helper Scripts

- **`example_custom_script.py`** - Template for creating your own custom scripts
- **`test_automation.py`** - Integration tests for all automation scripts

### Deployment Scripts

- **`ci_validate_repo.py`** - Repository validation (used by CI)
- **`deploy_mt5.sh`** - Deploy MQL5 files to MT5 data folder
- **`package_mt5.sh`** - Create distribution package

## Quick Start

### Windows Users

```powershell
# Run once
.\startup.ps1

# Setup auto-start on boot
.\startup.ps1 -CreateScheduledTask

# Test without executing
.\startup.ps1 -DryRun
```

### Linux/WSL Users

```bash
# Run once
./startup.sh

# Setup auto-start on boot (systemd)
./startup.sh --setup-systemd

# Setup auto-start on boot (cron)
./startup.sh --setup-cron
```

### Python Orchestrator (All Platforms)

```bash
# Create default configuration
python startup_orchestrator.py --create-config

# Run with default config
python startup_orchestrator.py

# Run with monitoring
python startup_orchestrator.py --monitor 3600

# Dry run
python startup_orchestrator.py --dry-run
```

## Testing

Run the integration tests:

```bash
python test_automation.py
```

## Configuration

Edit `../config/startup_config.json` to customize:
- What programs to start
- Startup order and delays
- Platform-specific settings
- MT5 terminal path

## Documentation

Full documentation available in `../docs/`:
- `Startup_Automation_Guide.md` - Complete guide
- `Quick_Start_Automation.md` - Quick reference
- `Windows_Task_Scheduler_Setup.md` - Windows setup details

## Support

- Issues: GitHub Issues
- Email: Lengkundee01.org@domain.com
- WhatsApp: [Agent community](https://chat.whatsapp.com/DYemXrBnMD63K55bjUMKYF)
