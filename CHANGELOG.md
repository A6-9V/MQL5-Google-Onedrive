# Changelog

All notable changes to the MQL5 SMC + Trend Breakout Trading System will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.22.0] - 2026-02-10

### Changed
- Updated package version to 1.22.0
- Updated Expert Advisor version property
- Maintained compatibility with existing features and configurations

## [1.21.0] - 2026-02-04

### Added
- **AI Integration**: Gemini and Jules AI support for trade confirmation
  - Configurable AI provider selection (Gemini/Jules)
  - API key configuration for both providers
  - Pre-trade signal validation via AI
- **ZOLO Bridge Integration**: Web request support for external plugin
  - HTTP endpoint communication
  - Real-time signal forwarding
- **Position Management**: Enhanced position tracking and management
  - ManagePositions.mqh library for centralized position control
  - One position per symbol enforcement
- **Automated Startup System**: Cross-platform automation
  - Windows PowerShell and Batch scripts
  - Linux/WSL shell scripts with systemd integration
  - Python orchestrator for cross-platform management
  - Scheduled task configuration
  - Process monitoring and logging
- **Cloud Deployment**: Multi-platform cloud support
  - Render.com auto-deploy configuration
  - Railway.app deployment support
  - Fly.io deployment configuration
  - Docker Hub automated publishing
  - VPS update scripts
- **GitHub Automation**: CI/CD workflows
  - Repository validation on PRs
  - Automated MT5 package building
  - OneDrive sync via rclone
  - Auto-merge for labeled PRs
  - Docker dev deployment pipeline
- **Market Research Automation**: AI-powered market analysis
  - Automated market data fetching (yfinance)
  - AI-generated research reports
  - Code upgrade suggestions
  - Scheduled research runs every 4 hours

### Core Features
- **SMC (Smart Money Concepts)**: 
  - Break of Structure (BOS) detection
  - Change of Character (CHoCH) identification
  - Fractal-based swing analysis
- **Donchian Breakout**: 
  - Configurable lookback period
  - Channel width-based TP calculations
  - Visual breakout lines (optional)
- **Multi-Timeframe (MTF) Confirmation**:
  - Lower timeframe EMA crossover validation
  - Cached MTF direction for performance
  - Configurable fast/slow EMAs
- **Advanced Risk Management**:
  - Multiple SL modes: ATR-based, Swing-based, Fixed points
  - Multiple TP modes: Risk/Reward ratio, Fixed points, Donchian width
  - Position sizing based on risk percentage
  - Equity or balance-based risk calculations
  - Free margin clamping
- **Notifications**:
  - MT5 push notifications
  - Popup alerts
  - Terminal alerts
- **Visual Indicators**:
  - Buy/Sell arrow signals
  - Structure lines (BOS/CHoCH)
  - Breakout level lines
  - Text labels for signal types

### Documentation
- Comprehensive setup and deployment guides
- WSL and VPS deployment instructions
- Startup automation documentation
- Cloud deployment guides for all platforms
- Secrets management guide
- GitHub CI/CD setup guide
- Quick reference commands
- Index of all documentation

### Included Files
- `SMC_TrendBreakout_MTF.mq5` - Visual indicator
- `SMC_TrendBreakout_MTF_EA.mq5` - Expert Advisor
- `AiAssistant.mqh` - AI integration library
- `ZoloBridge.mqh` - External plugin bridge
- `ManagePositions.mqh` - Position management library
- Multiple enhanced MAPSAR EAs for different strategies

### Scripts and Tools
- Repository validation script (`ci_validate_repo.py`)
- MT5 packaging script (`package_mt5.sh`)
- MT5 deployment script (`deploy_mt5.sh`)
- Cloud deployment automation (`deploy_cloud.py`)
- Docker Hub publishing (`deploy_docker_hub.sh`)
- VPS update automation (`update_vps.sh`)
- Telegram deployment bot (`telegram_deploy_bot.py`)
- Startup orchestrator (`startup_orchestrator.py`)
- Market research automation (`schedule_research.py`)

### Configuration
- Startup configuration (`config/startup_config.json`)
- Environment template (`.env.example`)
- Docker configurations for dev and production
- Cloud platform configurations (render.yaml, railway.json, fly.toml)
- GitHub Actions workflows

### Requirements
- MetaTrader 5 (Desktop version required for custom indicators/EAs)
- Python 3.x for automation scripts
- Bash/PowerShell for deployment scripts
- Optional: Docker for containerized deployment
- Optional: GitHub CLI for automated secrets management
- Optional: rclone for OneDrive synchronization

### Security
- API keys management via environment variables
- GitHub Secrets integration
- Secrets template provided
- No hardcoded credentials

### Tested Platforms
- Windows 10/11 with MT5 Desktop
- Ubuntu Linux (native and WSL)
- Docker containers
- Render.com cloud platform
- Railway.app cloud platform
- Fly.io cloud platform

## [Unreleased]

### Planned Features
- Backtesting optimization tools
- Additional AI provider integrations
- Real-time market sentiment analysis
- Performance analytics dashboard
- Mobile app integration

---

## Release Notes

### Version 1.21.0 Highlights
This release represents a comprehensive trading system with advanced automation, AI integration, and multi-platform deployment capabilities. The system is production-ready with extensive documentation and testing.

### Breaking Changes
None. This is the initial versioned release.

### Migration Guide
If upgrading from unversioned code:
1. Review your existing configuration files
2. Update API keys in `.env` file
3. Recompile MQL5 files in MetaEditor
4. Test in Strategy Tester before live deployment
5. Configure cloud deployment if needed

### Support
- Repository: https://github.com/A6-9V/MQL5-Google-Onedrive
- Documentation: See `docs/INDEX.md`
- Issues: Use GitHub Issues for bug reports and feature requests
