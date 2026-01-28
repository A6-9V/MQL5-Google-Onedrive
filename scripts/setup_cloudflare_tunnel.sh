#!/bin/bash
# Script to install and setup Cloudflare Tunnel (cloudflared)
# Supports Debian/Ubuntu

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Cloudflare Tunnel Setup ===${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)."
  exit 1
fi

# Install cloudflared if not present
if ! command -v cloudflared &> /dev/null; then
    echo "Installing cloudflared..."

    # Add Cloudflare GPG key
    mkdir -p --mode=0755 /usr/share/keyrings
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

    # Add Cloudflare repo
    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared jammy main' | tee /etc/apt/sources.list.d/cloudflared.list

    # Update and install
    apt-get update && apt-get install -y cloudflared
else
    echo -e "${GREEN}cloudflared is already installed.${NC}"
fi

echo -e "${BLUE}=== Configuration Steps ===${NC}"
echo "1. Authenticate with Cloudflare:"
echo "   cloudflared tunnel login"
echo ""
echo "2. Create a tunnel:"
echo "   cloudflared tunnel create <TUNNEL_NAME>"
echo ""
echo "3. Route the tunnel to your domain:"
echo "   cloudflared tunnel route dns <TUNNEL_NAME> lengkundee01.org"
echo ""
echo "4. Configure the tunnel (create config.yml) and run it."
echo ""
echo "For more details, see docs/CLOUDFLARE_GUIDE.md"
