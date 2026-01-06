# Quick Start - Automation Scripts

## 🚀 One-Command Startup

### Windows
```powershell
# PowerShell (Recommended)
cd C:\path\to\MQL5-Google-Onedrive
powershell -ExecutionPolicy Bypass -File scripts\startup.ps1

# Command Prompt
scripts\startup.bat
```

### Linux/WSL
```bash
cd /path/to/MQL5-Google-Onedrive
./scripts/startup.sh
```

## 📋 Setup Auto-Start

### Windows - Create Scheduled Task
```powershell
cd C:\path\to\MQL5-Google-Onedrive
powershell -ExecutionPolicy Bypass -File scripts\startup.ps1 -CreateScheduledTask
```

### Linux - Install Service
```bash
cd /path/to/MQL5-Google-Onedrive
./scripts/startup.sh --setup-systemd
```

## 📝 Common Commands

### Test Without Starting (Dry Run)
```powershell
# Windows
.\scripts\startup.ps1 -DryRun

# Python
python scripts/startup_orchestrator.py --dry-run
```

### Monitor Running Processes
```bash
python scripts/startup_orchestrator.py --monitor 3600  # Monitor for 1 hour
python scripts/startup_orchestrator.py --monitor 0     # Monitor indefinitely
```

### Create Config File
```bash
python scripts/startup_orchestrator.py --create-config
```

### Use Custom Config
```bash
python scripts/startup_orchestrator.py --config path/to/config.json
```

## 🔧 Configuration

Edit `config/startup_config.json` to customize:
- What programs to start
- Startup order and delays
- MT5 terminal path
- Custom scripts

## 📂 File Structure

```
MQL5-Google-Onedrive/
├── scripts/
│   ├── startup.bat              # Windows batch script
│   ├── startup.ps1              # PowerShell script
│   ├── startup.sh               # Linux/WSL script
│   └── startup_orchestrator.py  # Python orchestrator
├── config/
│   └── startup_config.json      # Configuration
├── logs/
│   └── startup_*.log            # Log files
└── docs/
    └── Startup_Automation_Guide.md  # Full documentation
```

## ❓ Troubleshooting

### Python Not Found
**Windows:** Install from [python.org](https://www.python.org/downloads/)  
**Linux:** `sudo apt install python3 python3-pip`

### MT5 Not Starting
1. Check if MT5 is installed
2. Verify path in `config/startup_config.json`
3. Try starting MT5 manually first

### Permission Errors
**PowerShell:** `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`  
**Linux:** `chmod +x scripts/startup.sh`

## 📚 Full Documentation

See [Startup_Automation_Guide.md](./Startup_Automation_Guide.md) for complete details.
