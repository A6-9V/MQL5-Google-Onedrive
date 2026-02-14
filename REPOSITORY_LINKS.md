# Repository Links & Ecosystem

This document serves as a central manifest tracking all repositories and resources related to the MQL5 Trading Automation project.

## 📋 Table of Contents

- [Main Repository](#main-repository)
- [Related Repositories](#related-repositories)
- [External Resources](#external-resources)
- [Development Tools](#development-tools)
- [Cloud Services](#cloud-services)
- [API Integrations](#api-integrations)

## Main Repository

### 🏠 MQL5-Google-Onedrive

**URL**: https://github.com/A6-9V/MQL5-Google-Onedrive

**Purpose**: Main repository containing MQL5 indicators, Expert Advisors, and automation scripts for trading on MetaTrader 5 with Exness.

**Key Features**:
- SMC + Trend Breakout Multi-Timeframe Indicator
- Expert Advisor with AI integration (Gemini & Jules)
- Cloud deployment automation (Render, Railway, Fly.io, Docker)
- Telegram bot for remote deployment
- Automated startup scripts for Windows/Linux
- OneDrive synchronization

**Technology Stack**:
- MQL5 (MetaTrader 5 trading logic)
- Python 3.8+ (automation, deployment, bots)
- Docker (containerization)
- Bash/PowerShell (system automation)

## Related Repositories

### 📄 GitHub Pages

**URL**: https://github.com/Mouy-leng/-LengKundee-mql5.github.io.git

**Purpose**: GitHub Pages site for project documentation and web presence.

**Status**: Active

**Sync**: Automated via `.github/workflows/github-pages-sync.yml`

### 🔌 ZOLO-A6-9V-NUNA Plugin

**Location**: [OneDrive - ZOLO Plugin](https://1drv.ms/f/c/8F247B1B46E82304/IgBYRTEjjPv-SKHi70WnmmU8AZb3Mr5X1o3a0QNU_mKgAZg)

**Purpose**: Bridge plugin for webhook integrations and external signal processing.

**Integration**: Via WebRequest in Expert Advisor

### 🌳 Samurai All Branch Structure

**Location**: [OneDrive - Branch Structure](https://1drv.ms/f/c/8F247B1B46E82304/IgDpUzdplXkDTpiyCkdNDZpXASUMJEccVuNGxAaY3MxB1sA)

**Purpose**: Complete branch history and structure documentation.

**Content**: Historical snapshots of all development branches

### 🧬 GenX Workspace

**Location**: [OneDrive - VSCode Folder](https://1drv.ms/f/c/8F247B1B46E82304/IgCPaN4jwMKZTar1XBwn8W9zAYFz0tYoNz7alcAhiiI9oIQ)

**Purpose**: Shared VS Code workspace configurations and project settings.

**Sync**: Manual updates

## External Resources

### 📓 Knowledge Base

**NotebookLM**: [Access here](https://notebooklm.google.com/notebook/e8f4c29d-9aec-4d5f-8f51-2ca168687616)

**Purpose**: AI-enhanced knowledge base for documentation, guides, and context. Available for reading and writing by AI agents.

**Usage**: All AI agents must read this before starting work.

### 💬 Cursor Connect Session

**URL**: [Join Session](https://prod.liveshare.vsengsaas.visualstudio.com/join?9C5AED55D7D6624FE2E1B50AD9F14D1339A5)

**Purpose**: Live collaboration session for pair programming and code reviews.

**Status**: Active

### 🪟 Developer Tip Window

**URL**: https://chatgpt.com/g/g-p-691e9c0ace5c8191a1b409c09251cc2b-window-for-developer-tip/project

**Purpose**: ChatGPT custom GPT for developer tips and guidance.

## Development Tools

### Version Control

- **Git**: Source control
- **GitHub**: Repository hosting, CI/CD, project management
- **GitHub CLI**: Command-line interface for GitHub

### IDEs & Editors

- **VS Code**: Primary IDE (see `.vscode/` and workspace file)
- **MetaEditor**: MQL5 development and compilation
- **Cursor**: AI-powered code editor

### AI Assistants

- **GitHub Copilot**: AI pair programmer
- **Jules**: Custom AI assistant for code execution
- **Gemini**: Google AI for trade analysis

### CLI Tools

- **Docker**: Container runtime
- **Docker Compose**: Multi-container orchestration
- **rclone**: Cloud storage sync (OneDrive)
- **Firebase CLI**: Firebase deployment
- **GitHub CLI**: GitHub automation
- **Vercel CLI**: Vercel deployment

## Cloud Services

### Deployment Platforms

#### Render.com

**Workspace**: My Blue watermelon Workspace  
**Workspace ID**: `tea-d1joqqi4d50c738aiujg`  
**Config**: `render.yaml`  
**Status**: Active  
**Auto-deploy**: Enabled via CD workflow

#### Railway.app

**Config**: `railway.json`  
**Status**: Active  
**Auto-deploy**: Enabled via CD workflow

#### Fly.io

**Config**: `fly.toml`  
**Status**: Active  
**Auto-deploy**: Enabled via CD workflow

#### Docker Hub

**Repository**: `mouyleng/mql5-trading-automation`  
**Tags**: `latest`, versioned releases  
**Auto-build**: Enabled via CD workflow

#### Google Cloud Platform

**Config**: `app.yaml`, `cloudbuild.yaml`  
**Services**: App Engine, Cloud Build  
**Status**: Configured

### Storage Services

#### OneDrive

**Remote**: Configured via `rclone`  
**Sync Path**: `Apps/MT5/MQL5`  
**Auto-sync**: Enabled via GitHub Actions  
**Vault Password**: `[ACCESS_CODE_REQUIRED]`

#### GitHub Packages

**Registry**: `ghcr.io/a6-9v/mql5-google-onedrive`  
**Usage**: Container image storage

## API Integrations

### Trading Platform

#### Exness MT5

**Platform**: MetaTrader 5  
**Broker**: Exness  
**Account Setup**: See `EXNESS_ACCOUNT_SETUP.txt`  
**Live Trading**: See `LIVE_TRADING_SETUP.md`

### AI Services

#### Google Gemini API

**Endpoint**: `https://generativelanguage.googleapis.com`  
**Purpose**: AI-powered trade confirmation  
**Integration**: EA parameter `UseGeminiFilter`  
**API Key Storage**: GitHub Secrets, `.env` file

#### Jules AI API

**Purpose**: Code execution and automation  
**Integration**: Via `scripts/jules_execute.py`  
**API Key Storage**: GitHub Secrets, `.env` file

### Communication

#### Telegram Bot API

**API Reference**: https://core.telegram.org/bots/api  
**Bot Script**: `scripts/telegram_deploy_bot.py`  
**Setup Guide**: `scripts/TELEGRAM_BOT_SETUP.md`  
**Commands**:
- `/deploy_flyio` - Deploy to Fly.io
- `/deploy_render` - Deploy to Render.com
- `/deploy_railway` - Deploy to Railway.app
- `/status` - Check deployment status

### Domain & DNS

#### Cloudflare

**Domain**: `Lengkundee01.org`  
**Services**: DNS, CDN, Tunnels  
**Config**: `scripts/manage_cloudflare.py`  
**Secrets**: Zone ID, Account ID in GitHub Secrets

### Email

#### Firefox Relay

**Purpose**: Email privacy and forwarding  
**API Keys**: `SCRSOR`, `COPILOT` in GitHub Secrets  
**Profile**: https://relay.firefox.com/accounts/profile/

## Repository Timeline & History

For detailed project timeline and version history, see:

- **TIMELINE.md**: Project milestones and major events
- **CHANGELOG.md**: Version-by-version change log
- **Release Notes**: `RELEASE_NOTES_*.md` files

## Continuous Integration / Continuous Deployment

### GitHub Actions Workflows

Located in `.github/workflows/`:

- **CI** (`ci.yml`): Validation and packaging on pull requests
- **CD** (`cd.yml`): Comprehensive deployment on main/tags
- **Deploy Cloud** (`deploy-cloud.yml`): Multi-platform deployment
- **Deploy Dashboard** (`deploy-dashboard.yml`): GitHub Pages deployment
- **OneDrive Sync** (`onedrive-sync.yml`): Automated file sync
- **GitHub Pages Sync** (`github-pages-sync.yml`): Documentation sync
- **Enable Auto-merge** (`enable-automerge.yml`): PR auto-merge
- **Release** (`release.yml`): Automated release creation
- **Container CI/CD** (`container-ci-cd.yml`): Docker workflows

### Secrets Management

All API keys, tokens, and sensitive credentials are stored as:

1. **GitHub Secrets**: For CI/CD workflows
2. **Local `.env` files**: For local development (see `.env.example`)
3. **Vault**: `config/vault.json` (template only, real values in secrets)

See `docs/Secrets_Management.md` for complete guide.

## Contributing

See `CONTRIBUTING.md` for guidelines on:

- Development workflow
- Coding standards
- Testing requirements
- Documentation standards
- Pull request process

## Contact & Support

- **Email**: Lengkundee01.org@domain.com
- **WhatsApp Community**: [Agent Community](https://chat.whatsapp.com/DYemXrBnMD63K55bjUMKYF)
- **GitHub Issues**: https://github.com/A6-9V/MQL5-Google-Onedrive/issues
- **GitHub Discussions**: https://github.com/A6-9V/MQL5-Google-Onedrive/discussions

---

**Last Updated**: 2026-02-14  
**Maintained by**: A6-9V  
**Status**: Active Development
