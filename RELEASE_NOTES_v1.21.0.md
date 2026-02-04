# Release v1.21.0 Summary

## Overview

This document summarizes the first official release (v1.21.0) of the MQL5 SMC + Trend Breakout Trading System.

## Release Date

February 4, 2026

## What's New in This Release

### Release Infrastructure
This is the first versioned release with comprehensive release management:

- **Automated Release Workflow**: GitHub Actions workflow that automatically:
  - Validates repository structure
  - Runs all tests
  - Packages MT5 files
  - Builds Docker images
  - Creates GitHub releases with assets
  - Generates checksums for verification

- **Release Documentation**: Complete documentation for:
  - Release process and procedures
  - Version numbering (Semantic Versioning)
  - Release checklist template
  - Rollback procedures
  - Hotfix process

- **Changelog**: Comprehensive CHANGELOG.md documenting all features, changes, and version history

- **Release Tools**: Automated release preparation script that:
  - Checks prerequisites
  - Validates repository
  - Runs all tests
  - Packages files
  - Creates tags
  - Provides interactive menu or command-line options

## System Features (v1.21.0)

### Trading System
- **SMC Indicator**: Break of Structure (BOS) and Change of Character (CHoCH) detection
- **Donchian Breakout**: Trend breakout strategy with configurable lookback
- **Multi-Timeframe Confirmation**: Lower timeframe EMA validation
- **Expert Advisor**: Automated trading with multiple risk management modes
- **AI Integration**: Gemini and Jules AI for trade confirmation
- **ZOLO Bridge**: External plugin integration via HTTP

### Automation
- **Cross-Platform Startup**: Windows, Linux, and WSL support
- **Process Management**: Monitoring and logging
- **Scheduled Tasks**: Windows Task Scheduler and Linux systemd/cron
- **Market Research**: Automated AI-powered market analysis

### Deployment
- **Cloud Platforms**: Render, Railway, Fly.io support
- **Docker**: Multi-architecture images (amd64, arm64)
- **VPS**: Automated update scripts
- **OneDrive Sync**: Automated synchronization via rclone

### Development
- **CI/CD**: GitHub Actions workflows for validation and deployment
- **Auto-merge**: Label-driven PR auto-merge
- **Repository Validation**: Automated structure and code checks
- **Package Building**: Automated MT5 file packaging

## Installation

### From GitHub Release

```bash
# Download release package
wget https://github.com/A6-9V/MQL5-Google-Onedrive/releases/download/v1.21.0/Exness_MT5_MQL5.zip

# Verify checksum
wget https://github.com/A6-9V/MQL5-Google-Onedrive/releases/download/v1.21.0/Exness_MT5_MQL5.zip.sha256
sha256sum -c Exness_MT5_MQL5.zip.sha256

# Extract to MT5 data folder
unzip Exness_MT5_MQL5.zip -d /path/to/MT5/Data/Folder/

# Open MetaEditor in MT5 (F4) and compile all files
```

### Using Docker

```bash
# Pull the release image
docker pull ghcr.io/a6-9v/mql5-google-onedrive:v1.21.0

# Run the container
docker run -d \
  --name mql5-trading \
  -v /path/to/config:/app/config \
  ghcr.io/a6-9v/mql5-google-onedrive:v1.21.0
```

### From Repository

```bash
# Clone the repository
git clone https://github.com/A6-9V/MQL5-Google-Onedrive.git
cd MQL5-Google-Onedrive

# Checkout the release tag
git checkout v1.21.0

# Package MT5 files
bash scripts/package_mt5.sh

# Deploy to MT5
bash scripts/deploy_mt5.sh /path/to/MT5/Data/Folder/
```

## Files Included

### MT5 Files (Exness_MT5_MQL5.zip)
- `SMC_TrendBreakout_MTF.mq5` - Main indicator
- `SMC_TrendBreakout_MTF_EA.mq5` - Expert Advisor
- `AiAssistant.mqh` - AI integration library
- `ZoloBridge.mqh` - External bridge library
- `ManagePositions.mqh` - Position management library
- Multiple MAPSAR Expert Advisors
- EXNESS GenX Trader EA

### Release Assets
- `Exness_MT5_MQL5.zip` - Complete MT5 source package (32KB)
- `Exness_MT5_MQL5.zip.sha256` - SHA256 checksum
- Docker images in GitHub Container Registry

## System Requirements

### For MT5 Desktop
- MetaTrader 5 Desktop (Exness or other broker)
- Windows 10/11 or compatible OS
- Note: Custom indicators/EAs not supported on Web Terminal

### For Automation (Optional)
- Python 3.x
- Bash (Linux/WSL) or PowerShell (Windows)
- Optional: Docker for containerized deployment
- Optional: GitHub CLI for automated operations

## Configuration

### Basic Setup
1. Copy MT5 files to data folder
2. Compile in MetaEditor
3. Attach indicator/EA to chart
4. Configure input parameters

### AI Integration (Optional)
1. Get API keys from Gemini/Jules
2. Configure MT5 WebRequest for AI endpoints
3. Enable AI filter in EA parameters
4. Enter API keys

### Automation (Optional)
1. Configure `config/startup_config.json`
2. Set up environment variables in `.env`
3. Run startup script for your platform
4. Optional: Configure auto-start on boot

## Documentation

All documentation is available in the repository:
- [Full Documentation Index](docs/INDEX.md)
- [Release Process](docs/RELEASE_PROCESS.md)
- [Setup & Deployment Guide](docs/SETUP_AND_DEPLOY.md)
- [Startup Automation Guide](docs/Startup_Automation_Guide.md)
- [Cloud Deployment Guide](docs/Cloud_Deployment_Guide.md)
- [CHANGELOG](CHANGELOG.md)

## Support

- **Repository**: https://github.com/A6-9V/MQL5-Google-Onedrive
- **Issues**: https://github.com/A6-9V/MQL5-Google-Onedrive/issues
- **Discussions**: https://github.com/A6-9V/MQL5-Google-Onedrive/discussions
- **WhatsApp Community**: https://chat.whatsapp.com/DYemXrBnMD63K55bjUMKYF

## Testing

All components have been tested:
- ✅ Repository validation passes
- ✅ Shell scripts validated
- ✅ MT5 files compile successfully
- ✅ Package creation works
- ✅ Automation tests pass
- ✅ Docker builds successfully
- ✅ CI/CD workflows functional

## Security

- No hardcoded credentials
- API keys via environment variables
- GitHub Secrets integration
- Secrets template provided
- Regular security validation

## Known Limitations

- Custom indicators/EAs not supported on MT5 Web Terminal (Desktop required)
- AI features require API keys (not included)
- Cloud deployment requires platform accounts
- Some automation features are platform-specific

## Future Roadmap

See [CHANGELOG.md](CHANGELOG.md) for planned features:
- Backtesting optimization tools
- Additional AI provider integrations
- Real-time market sentiment analysis
- Performance analytics dashboard
- Mobile app integration

## License

See [LICENSE](LICENSE) file in repository.

## Contributors

- Development: LengKundee
- AI Assistant: Jules
- Repository: A6-9V

## Acknowledgments

- MetaQuotes for MetaTrader 5 platform
- Google for Gemini AI
- Jules AI for market research capabilities
- GitHub for hosting and CI/CD
- All contributors and testers

---

**Release v1.21.0** - The foundation for automated, AI-powered trading with comprehensive deployment options.
