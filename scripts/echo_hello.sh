#!/usr/bin/env bash
# ============================================================================
# Echo and Hello Window Demo Script (Shell Version)
# Demonstrates simple echo output and hello window display functionality.
# ============================================================================

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Echo function
echo_message() {
    local message="$1"
    echo -e "${CYAN}[ECHO]${NC} >>> ${message}"
}

# Show hello window
show_hello_window() {
    local border="============================================================"
    local title="HELLO WINDOW"
    local greeting="Hello from MQL5 Trading Automation!"
    local timestamp="Time: $(date '+%Y-%m-%d %H:%M:%S')"
    
    echo ""
    echo "$border"
    printf "%*s\n" $(((${#title}+60)/2)) "$title"
    echo "$border"
    printf "%*s\n" $(((${#greeting}+60)/2)) "$greeting"
    printf "%*s\n" $(((${#timestamp}+60)/2)) "$timestamp"
    echo "$border"
    echo ""
}

# Run demo
run_demo() {
    echo -e "${GREEN}[INFO]${NC} Starting echo and hello window demo..."
    
    # Echo some messages
    echo_message "Welcome to the demo!"
    echo_message "This script demonstrates echo functionality"
    echo_message "And displays a hello window"
    
    # Show the hello window
    show_hello_window
    
    echo -e "${GREEN}[SUCCESS]${NC} Demo completed successfully"
}

# Main
main() {
    if [ $# -eq 0 ]; then
        # No arguments, run full demo
        run_demo
    else
        # Custom message provided
        echo_message "$*"
    fi
}

# Parse arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [message]"
        echo ""
        echo "Options:"
        echo "  --help, -h    Show this help message"
        echo "  [message]     Custom message to echo"
        echo ""
        echo "Examples:"
        echo "  $0                    # Run full demo"
        echo "  $0 Hello World        # Echo custom message"
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
