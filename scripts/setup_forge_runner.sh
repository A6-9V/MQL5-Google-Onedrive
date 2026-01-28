#!/usr/bin/env bash
# ============================================================================
# MQL5 Forge Runner Setup Script
# ============================================================================
# This script helps set up a Gitea Action runner for MQL5 Forge.
# It downloads the act_runner binary, registers it with the provided token,
# and prepares a systemd service (on Linux).
# ============================================================================

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
FORGE_URL="https://forge.mql5.io"
RUNNER_NAME="mql5-forge-runner"
DEFAULT_TOKEN=""

log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

print_header() {
    echo "============================================================"
    echo "    MQL5 Forge Action Runner Setup"
    echo "============================================================"
}

install_dependencies() {
    log_info "Installing dependencies (curl, docker)..."
    if ! command -v curl &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y curl
    fi

    if ! command -v docker &> /dev/null; then
        log_warn "Docker not found. Docker is required to run most Gitea Actions."
        log_info "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        log_warn "You may need to log out and back in for docker group changes to take effect."
    fi
}

download_runner() {
    log_info "Downloading act_runner..."
    # Get latest version for Linux amd64
    # For simplicity, we use a specific known good version or try to find latest.
    # Architecture check
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) BIN_ARCH="amd64" ;;
        aarch64) BIN_ARCH="arm64" ;;
        *) log_error "Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    VERSION="v0.2.10" # Example version
    URL="https://gitea.com/gitea/act_runner/releases/download/${VERSION}/act_runner-${VERSION#v}-linux-${BIN_ARCH}"

    curl -L "$URL" -o act_runner
    chmod +x act_runner
    log_success "act_runner downloaded."
}

register_runner() {
    local token=${1:-$DEFAULT_TOKEN}

    if [[ -z "$token" ]]; then
        echo -n "Enter your Forge Runner Registration Token: "
        read token
    fi

    if [[ -f ".runner" ]]; then
        log_warn "A runner is already registered (.runner file exists)."
        echo -n "Do you want to re-register? (y/N): "
        read answer
        if [[ "$answer" != "y" ]]; then
            return
        fi
    fi

    log_info "Registering runner with Forge..."
    ./act_runner register \
        --instance "$FORGE_URL" \
        --token "$token" \
        --name "$RUNNER_NAME" \
        --labels "ubuntu-latest:docker://gitea/proto-messages,ubuntu-22.04:docker://node:16-bullseye,ubuntu-20.04:docker://node:16-bullseye" \
        --no-interactive

    log_success "Runner registered successfully."
}

setup_systemd() {
    log_info "Setting up systemd service..."

    WORKING_DIR=$(pwd)
    USER_NAME=$(whoami)

    SERVICE_FILE="[Unit]
Description=Gitea Actions runner
After=network.target docker.service

[Service]
ExecStart=${WORKING_DIR}/act_runner daemon
WorkingDirectory=${WORKING_DIR}
User=${USER_NAME}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target"

    echo "$SERVICE_FILE" | sudo tee /etc/systemd/system/forge-runner.service > /dev/null
    sudo systemctl daemon-reload
    log_success "Systemd service 'forge-runner.service' created."
    log_info "You can start it with: sudo systemctl start forge-runner"
}

main() {
    print_header

    TOKEN=${1:-""}

    install_dependencies
    download_runner
    register_runner "$TOKEN"
    setup_systemd

    echo ""
    log_success "Setup complete!"
    echo "To start the runner now: ./act_runner daemon"
    echo "To start as a service: sudo systemctl enable --now forge-runner"
}

main "$@"
