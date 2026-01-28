# Automation Features

This document describes the automation features added to the MQL5-Google-Onedrive repository.

## Overview

A comprehensive automation system has been added to enable automatic startup of trading components on Windows, Linux, and WSL. This system eliminates manual startup procedures and ensures consistent initialization of all trading tools.

## What's New

### Scripts Added

1. **`scripts/startup_orchestrator.py`**
   - Advanced Python orchestrator for component management
   - JSON-based configuration system
   - Process monitoring and health checks
   - Comprehensive logging with timestamps
   - Dry-run mode for testing
   - Cross-platform support (Windows, Linux, WSL)

2. **`scripts/startup.bat`**
   - Windows batch script for simple automation
   - Automatic MT5 terminal detection
   - Error handling and logging
   - Task Scheduler compatible

3. **`scripts/startup.ps1`**
   - Advanced PowerShell automation script
   - Scheduled task creation (`-CreateScheduledTask` flag)
   - Colored console output
   - Administrator privilege handling
   - Dry-run mode (`-DryRun` flag)
   - Process verification

4. **`scripts/startup.sh`**
   - Linux/WSL bash script
   - systemd service integration (`--setup-systemd`)
   - Cron job setup (`--setup-cron`)
   - WSL detection and Windows interop
   - Wine support for MT5 on native Linux

5. **`scripts/example_custom_script.py`**
   - Template for user custom scripts
   - Demonstrates proper logging
   - Command-line argument parsing
   - Task-based execution

### Configuration

- **`config/startup_config.json`**
  - Centralized configuration for all components
  - Define startup order and delays
  - Platform-specific component handling
  - MT5 path configuration
  - Notification settings (ready for future enhancement)

### Documentation

1. **`docs/Startup_Automation_Guide.md`**
   - Complete automation guide
   - Platform-specific instructions
   - Configuration examples
   - Troubleshooting section
   - Security considerations

2. **`docs/Quick_Start_Automation.md`**
   - Quick reference for common commands
   - One-command startup instructions
   - Common troubleshooting

3. **`docs/Windows_Task_Scheduler_Setup.md`**
   - Detailed Windows Task Scheduler setup
   - Manual and automated setup methods
   - Testing and verification steps
   - Export/import procedures

### Other Changes

- **`requirements.txt`** - Python dependencies (optional enhancements)
- **`.gitignore`** - Updated to exclude logs, Python cache, and IDE files
- **`README.md`** - Updated with automation quick start section

## Features

### Automated Startup Sequence

1. Prerequisites check (Python, repository structure)
2. Repository validation (optional)
3. MT5 Terminal launch with proper initialization delay
4. Custom script execution in configured order
5. Process monitoring (optional)
6. Comprehensive logging to `logs/` directory

### Multi-Platform Support

- **Windows 10/11**: Batch, PowerShell, Python
- **Linux**: Bash with systemd/cron
- **WSL 1/2**: Full Windows interop support

### Flexible Configuration

- JSON-based component definition
- Per-component settings:
  - Executable path
  - Command-line arguments
  - Working directory
  - Initialization delay
  - Required vs optional
  - Platform restrictions

### Auto-Start Integration

- **Windows**: Task Scheduler with automated setup
- **Linux**: systemd service with one-command install
- **Linux**: Cron job alternative
- **Windows**: Startup folder option

### Logging & Monitoring

- Timestamped log files in `logs/` directory
- Component-level logging
- Success/failure tracking
- Process monitoring mode
- Colored console output (where supported)

## Use Cases

1. **Trading Workstation Auto-Start**
   - Start MT5 terminal on system boot
   - Initialize custom trading scripts
   - Validate repository before trading

2. **Scheduled Trading Sessions**
   - Start trading components at specific times
   - Automated pre-market checks
   - Post-market cleanup routines

3. **Development & Testing**
   - Consistent development environment setup
   - Automated testing workflows
   - CI/CD integration ready

4. **Remote Trading Servers**
   - Unattended server operation
   - Automatic recovery after reboot
   - systemd service management

## System Requirements

### Minimum
- Python 3.8+
- Windows 10 / Linux (Ubuntu 20.04+) / WSL 2
- 4 GB RAM
- MT5 Terminal installed (for trading features)

### Recommended
- Python 3.10+
- Windows 11 / Ubuntu 22.04 LTS
- 8 GB RAM
- SSD storage
- Stable internet connection

## Quick Examples

### Windows Quick Start
```powershell
# One-time setup
powershell -ExecutionPolicy Bypass -File scripts\startup.ps1 -CreateScheduledTask

# Manual run
powershell -ExecutionPolicy Bypass -File scripts\startup.ps1

# Test run
powershell -ExecutionPolicy Bypass -File scripts\startup.ps1 -DryRun
```

### Linux Quick Start
```bash
# One-time setup
./scripts/startup.sh --setup-systemd

# Manual run
./scripts/startup.sh

# Control service
sudo systemctl start mql5-trading-automation
sudo systemctl status mql5-trading-automation
```

### Python Orchestrator
```bash
# Create config
python scripts/startup_orchestrator.py --create-config

# Run with monitoring
python scripts/startup_orchestrator.py --monitor 3600

# Dry run
python scripts/startup_orchestrator.py --dry-run
```

## Security Notes

- Scripts never store sensitive credentials
- Task Scheduler credentials encrypted by Windows
- Scripts run with user privileges (not system)
- All configuration in version-controlled files
- Logs may contain execution details (review before sharing)

## Future Enhancements

Planned features:
- Email/SMS notifications on startup failure
- Webhook integration (Slack, Discord, Telegram)
- ✅ Automatic retry on component failure (IMPLEMENTED)
- Health check API endpoint
- Web dashboard for monitoring
- Backup/restore configuration
- Multi-instance support

## Troubleshooting

Common issues and solutions are documented in:
- [Startup Automation Guide](docs/Startup_Automation_Guide.md) - Full troubleshooting section
- [Quick Start](docs/Quick_Start_Automation.md) - Common issues

## Contributing

When adding new automation features:
1. Update `startup_config.json` with sensible defaults
2. Add documentation to the guides
3. Test on target platforms
4. Update this FEATURES.md file

## Support

- **GitHub Issues**: Report bugs or request features
- **Email**: Lengkundee01.org@domain.com
- **WhatsApp**: [Agent community](https://chat.whatsapp.com/DYemXrBnMD63K55bjUMKYF)

## License

Same as repository: See [LICENSE](LICENSE)
