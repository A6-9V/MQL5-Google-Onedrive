#!/usr/bin/env bash
# ============================================================================
# MQL5 Trading Automation - Ubuntu 24.04 / VPS Setup Script
# ============================================================================
# This script prepares a fresh Ubuntu environment for the automation system.
# It installs Python, Wine (for MT5), and necessary dependencies.
# ============================================================================

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

print_header() {
    echo "============================================================"
    echo "    MQL5 Trading Automation - Ubuntu 24.04 Setup"
    echo "============================================================"
    echo ""
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
       log_warn "This script requires sudo privileges for package installation."
       log_info "You may be prompted for your password."
    fi
}

install_system_deps() {
    log_info "Updating package lists..."
    sudo apt-get update

    log_info "Installing system dependencies..."
    sudo apt-get install -y \
        python3 \
        python3-pip \
        python3-venv \
        git \
        unzip \
        curl \
        wget \
        software-properties-common

    log_success "System dependencies installed."
}

install_wine() {
    log_info "Checking Wine installation..."
    if command -v wine &> /dev/null; then
        log_info "Wine is already installed: $(wine --version)"
    else
        log_info "Installing Wine (required for running MT5 on Linux)..."

        # Enable 32-bit architecture
        sudo dpkg --add-architecture i386

        # Add WineHQ repository key
        sudo mkdir -p /etc/apt/keyrings
        sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

        # Add WineHQ repository (Ubuntu 24.04 - Noble)
        sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources

        sudo apt-get update

        # Install Wine (Stable)
        # Note: We use --install-recommends to get all necessary libs
        sudo apt-get install -y --install-recommends winehq-stable

        log_success "Wine installed successfully."
    fi
}

setup_python_env() {
    log_info "Setting up Python environment..."

    # Install requirements from root
    if [[ -f "$REPO_ROOT/requirements.txt" ]]; then
        log_info "Installing core requirements..."
        # Use --break-system-packages on Ubuntu 24.04 if running outside venv,
        # or rely on user using a venv.
        # Ideally, we should create a venv, but to keep it simple for the bot startup script
        # (which often assumes system python or accessible pip), we'll try to install to user site if allowed,
        # or warn.

        # Check if we are in a virtual environment
        if [[ "${VIRTUAL_ENV:-}" != "" ]]; then
            pip install -r "$REPO_ROOT/requirements.txt"
        else
            log_warn "Not in a virtual environment. Installing to user directory."
            pip3 install --user -r "$REPO_ROOT/requirements.txt" || \
            pip3 install -r "$REPO_ROOT/requirements.txt" --break-system-packages
        fi
    fi

    # Install bot requirements
    if [[ -f "$SCRIPT_DIR/requirements_bot.txt" ]]; then
        log_info "Installing bot requirements..."
        if [[ "${VIRTUAL_ENV:-}" != "" ]]; then
            pip install -r "$SCRIPT_DIR/requirements_bot.txt"
        else
            pip3 install --user -r "$SCRIPT_DIR/requirements_bot.txt" || \
            pip3 install -r "$SCRIPT_DIR/requirements_bot.txt" --break-system-packages
        fi
    fi

    log_success "Python dependencies installed."
}

install_node_and_ai_clis() {
    log_info "Checking Node.js, Jules and Gemini CLIs..."

    # Check/Install Node.js
    if ! command -v node &> /dev/null; then
        log_info "Installing Node.js and npm..."
        sudo apt-get install -y nodejs npm
    else
        log_info "Node.js is already installed: $(node --version)"
    fi

    # Check/Install Jules
    if ! command -v jules &> /dev/null; then
        log_info "Installing Jules CLI..."
        # Install globally using npm
        sudo npm install -g @google/jules
        log_success "Jules CLI installed."
    else
        log_info "Jules CLI is already installed."
    fi

    # Check/Install Gemini CLI
    if ! command -v gemini &> /dev/null; then
        log_info "Installing Gemini CLI..."
        sudo npm install -g @google/gemini-cli
        log_success "Gemini CLI installed."
    else
        log_info "Gemini CLI is already installed."
    fi
}
make_executable() {
    log_info "Making scripts executable..."
    chmod +x "$SCRIPT_DIR/startup.sh"
    chmod +x "$SCRIPT_DIR/startup_orchestrator.py"
    log_success "Scripts are now executable."
}


main() {
    print_header
    check_root

    # Parse args
    INSTALL_WINE=true

    for arg in "$@"; do
        case $arg in
            --no-wine)
                INSTALL_WINE=false
                shift
                ;;
            --help)
                echo "Usage: $0 [--no-wine]"
                exit 0
                ;;
        esac
    done

    install_system_deps

    if [[ "$INSTALL_WINE" == "true" ]]; then
        install_wine
    else
        log_info "Skipping Wine installation (--no-wine)."
    fi

    setup_python_env
    install_node_and_ai_clis
    make_executable

    echo ""
    echo "============================================================"
    log_success "Setup complete!"
    echo "============================================================"
    echo "You can now start the automation with:"
    echo "  ./scripts/startup.sh"
    echo ""
}

main "$@"
