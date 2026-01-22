#!/usr/bin/env bash
# ============================================================================
# MQL5 Trading Automation - Linux/WSL Startup Script
# ============================================================================
# This script provides startup automation for Linux and Windows Subsystem
# for Linux (WSL) environments
# ============================================================================

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOGS_DIR="$REPO_ROOT/logs"
MT5_DIR="$REPO_ROOT/mt5/MQL5"

# Create logs directory
mkdir -p "$LOGS_DIR"

# Set up logging
LOG_FILE="$LOGS_DIR/startup_$(date +%Y%m%d_%H%M%S).log"

# Logging functions
log_info() {
    echo -e "${CYAN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# Header
print_header() {
    echo "" | tee -a "$LOG_FILE"
    echo "============================================================" | tee -a "$LOG_FILE"
    echo "    MQL5 Trading Automation - Linux/WSL Startup" | tee -a "$LOG_FILE"
    echo "============================================================" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
}

# Check if running in WSL
is_wsl() {
    if grep -qi microsoft /proc/version 2>/dev/null; then
        return 0
    fi
    return 1
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    local all_ok=true
    
    # Check Python
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version 2>&1)
        log_info "Python: $PYTHON_VERSION"
    else
        log_error "Python 3 is not installed"
        log_error "Install with: sudo apt install python3 python3-pip"
        all_ok=false
    fi
    
    # Check repository structure
    if [[ ! -d "$MT5_DIR" ]]; then
        log_error "MT5 directory not found: $MT5_DIR"
        all_ok=false
    else
        log_info "MT5 directory found"
    fi
    
    # Check if in WSL
    if is_wsl; then
        log_info "Running in WSL environment"
        
        # Check if Wine is available for MT5
        if command -v wine &> /dev/null; then
            log_info "Wine is installed (for MT5 Terminal)"
        else
            log_warn "Wine is not installed (needed for MT5 Terminal)"
            log_info "Install with: sudo apt install wine wine64"
        fi
    else
        log_info "Running in native Linux environment"
    fi
    
    if [[ "$all_ok" == "true" ]]; then
        log_success "Prerequisites check passed"
        return 0
    else
        log_error "Prerequisites check failed"
        return 1
    fi
}

# Start Python orchestrator
start_python_orchestrator() {
    local monitor_val="$1"
    log_info "Starting Python orchestrator..."
    
    local orchestrator_script="$SCRIPT_DIR/startup_orchestrator.py"
    local cmd="python3 \"$orchestrator_script\""
    
    if [[ -n "$monitor_val" ]]; then
        cmd="$cmd --monitor $monitor_val"
        log_info "Monitor mode enabled: $monitor_val seconds (0=infinite)"
    fi

    if [[ ! -f "$orchestrator_script" ]]; then
        log_warn "Orchestrator script not found, skipping"
        return 0
    fi
    
    # Evaluate the command properly
    if eval "$cmd" >> "$LOG_FILE" 2>&1; then
        log_success "Python orchestrator completed successfully"
        return 0
    else
        log_error "Python orchestrator failed with exit code $?"
        return 1
    fi
}

# Start MT5 Terminal (via Wine in WSL/Linux)
start_mt5_terminal() {
    log_info "Checking MT5 Terminal status..."
    
    if is_wsl; then
        # In WSL, we can try to start the Windows version
        local mt5_paths=(
            "/mnt/c/Program Files/Exness Terminal/terminal64.exe"
            "/mnt/c/Program Files/MetaTrader 5/terminal64.exe"
        )
        
        for mt5_path in "${mt5_paths[@]}"; do
            if [[ -f "$mt5_path" ]]; then
                log_info "Found MT5 Terminal at: $mt5_path"
                
                # Check if already running
                if tasklist.exe 2>/dev/null | grep -qi "terminal64.exe"; then
                    log_info "MT5 Terminal is already running"
                    return 0
                fi
                
                # Start MT5 via Windows
                log_info "Starting MT5 Terminal..."
                cmd.exe /c start "" "$mt5_path" /portable > /dev/null 2>&1 &
                log_success "MT5 Terminal started"
                sleep 15  # Wait for initialization
                return 0
            fi
        done
        
        log_warn "MT5 Terminal not found in common Windows paths"
        log_info "Please start MT5 manually from Windows"
        return 0
    else
        # Native Linux - would need Wine
        if command -v wine &> /dev/null; then
            log_warn "MT5 on native Linux requires Wine and manual configuration"
            log_info "Please configure Wine and MT5 path in the script"
        else
            log_warn "Wine not installed. MT5 Terminal cannot be started"
        fi
        return 0
    fi
}

# Run validation check
run_validation() {
    log_info "Running validation checks..."
    
    local validator_script="$REPO_ROOT/scripts/ci_validate_repo.py"
    
    if [[ ! -f "$validator_script" ]]; then
        log_warn "Validator script not found, skipping"
        return 0
    fi
    
    if python3 "$validator_script" >> "$LOG_FILE" 2>&1; then
        log_success "Validation passed"
        return 0
    else
        log_warn "Validation failed, but continuing..."
        return 0  # Non-critical
    fi
}

# Setup systemd service (for Linux systems with systemd)
setup_systemd_service() {
    log_info "Setting up systemd service for automatic startup..."
    
    local service_name="mql5-trading-automation"
    local service_file="/etc/systemd/system/${service_name}.service"
    local user=$(whoami)
    
    # Create service file content
    cat > "/tmp/${service_name}.service" <<EOF
[Unit]
Description=MQL5 Trading Automation Startup
After=network.target

[Service]
Type=oneshot
User=$user
WorkingDirectory=$REPO_ROOT
ExecStart=/bin/bash $SCRIPT_DIR/startup.sh
RemainAfterExit=yes
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
    
    # Install service (requires sudo)
    if sudo cp "/tmp/${service_name}.service" "$service_file"; then
        sudo systemctl daemon-reload
        sudo systemctl enable "$service_name.service"
        log_success "Systemd service installed: $service_name"
        log_info "Service will start automatically on boot"
        log_info "Manual control:"
        log_info "  Start:   sudo systemctl start $service_name"
        log_info "  Stop:    sudo systemctl stop $service_name"
        log_info "  Status:  sudo systemctl status $service_name"
    else
        log_error "Failed to install systemd service (need sudo privileges)"
        return 1
    fi
}

# Setup cron job (alternative to systemd)
setup_cron_job() {
    log_info "Setting up cron job for automatic startup..."
    
    local startup_script="$SCRIPT_DIR/startup.sh"
    local log_file="$LOGS_DIR/cron_startup.log"
    local cron_entry="@reboot sleep 30 && $startup_script >> $log_file 2>&1"
    
    # Check if entry already exists
    if crontab -l 2>/dev/null | grep -q "$startup_script"; then
        log_warn "Cron job already exists"
        return 0
    fi
    
    # Add cron entry
    (crontab -l 2>/dev/null; echo "$cron_entry") | crontab -
    log_success "Cron job added for automatic startup"
    log_info "Job will run on system reboot (after 30 second delay)"
}

# Print summary
print_summary() {
    local -n results_ref=$1
    
    echo "" | tee -a "$LOG_FILE"
    echo "============================================================" | tee -a "$LOG_FILE"
    echo "                 STARTUP SUMMARY" | tee -a "$LOG_FILE"
    echo "============================================================" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    
    for key in "${!results_ref[@]}"; do
        if [[ "${results_ref[$key]}" == "0" ]]; then
            echo -e "  ${GREEN}✓${NC} $key" | tee -a "$LOG_FILE"
        else
            echo -e "  ${RED}✗${NC} $key" | tee -a "$LOG_FILE"
        fi
    done
    
    echo "" | tee -a "$LOG_FILE"
    echo "============================================================" | tee -a "$LOG_FILE"
    echo "Log file: $LOG_FILE" | tee -a "$LOG_FILE"
    echo "============================================================" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
}

# Main execution
main() {
    local setup_mode=""
    local monitor_mode=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --setup-systemd)
                setup_mode="systemd"
                shift
                ;;
            --setup-cron)
                setup_mode="cron"
                shift
                ;;
            --monitor)
                if [[ -n "${2:-}" ]] && [[ "$2" =~ ^[0-9]+$ ]]; then
                    monitor_mode="$2"
                    shift 2
                else
                    monitor_mode="0"  # Default to infinite if no arg provided or invalid
                    shift
                fi
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --setup-systemd       Install systemd service for auto-startup"
                echo "  --setup-cron          Install cron job for auto-startup"
                echo "  --monitor [SECONDS]   Monitor processes (default: 0 = infinite)"
                echo "  --help                Show this help message"
                echo ""
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Handle setup modes
    if [[ -n "$setup_mode" ]]; then
        print_header
        if [[ "$setup_mode" == "systemd" ]]; then
            setup_systemd_service
        elif [[ "$setup_mode" == "cron" ]]; then
            setup_cron_job
        fi
        exit $?
    fi
    
    # Normal startup sequence
    print_header
    log_info "Repository root: $REPO_ROOT"
    log_info "Log file: $LOG_FILE"
    echo ""
    
    # Track results
    declare -A results
    
    # Step 1: Check prerequisites
    if check_prerequisites; then
        results["Prerequisites"]=0
    else
        results["Prerequisites"]=1
        log_error "Prerequisites check failed. Aborting."
        exit 1
    fi
    
    echo "" | tee -a "$LOG_FILE"
    
    # Step 2: Start Python orchestrator
    if start_python_orchestrator "$monitor_mode"; then
        results["Python Orchestrator"]=0
    else
        results["Python Orchestrator"]=1
    fi
    
    echo "" | tee -a "$LOG_FILE"
    
    # Step 3: Start MT5 Terminal
    if start_mt5_terminal; then
        results["MT5 Terminal"]=0
    else
        results["MT5 Terminal"]=1
    fi
    
    echo "" | tee -a "$LOG_FILE"
    
    # Step 4: Run validation
    if run_validation; then
        results["Validation"]=0
    else
        results["Validation"]=1
    fi
    
    # Print summary
    print_summary results
    
    # Determine overall success
    local failed=0
    for result in "${results[@]}"; do
        if [[ "$result" != "0" ]]; then
            ((failed++))
        fi
    done
    
    if [[ $failed -eq 0 ]]; then
        log_success "All components started successfully!"
        exit 0
    else
        log_warn "Some components failed to start ($failed failures)"
        exit 1
    fi
}

# Run main function
main "$@"
