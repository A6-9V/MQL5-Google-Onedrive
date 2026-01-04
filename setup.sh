#!/usr/bin/env bash
set -euo pipefail

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to check Python 3
check_python() {
    print_info "Checking for Python 3..."
    if command_exists python3; then
        PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
        print_success "Python 3 found: $PYTHON_VERSION"
        return 0
    else
        print_error "Python 3 not found. Please install Python 3."
        return 1
    fi
}

# Function to check bash
check_bash() {
    print_info "Checking for Bash..."
    if command_exists bash; then
        BASH_VERSION=$(bash --version | grep -oE '[0-9]+\.[0-9]+[0-9.]*' | head -1)
        print_success "Bash found: $BASH_VERSION"
        return 0
    else
        print_error "Bash not found. Please install Bash."
        return 1
    fi
}

# Function to check git
check_git() {
    print_info "Checking for Git..."
    if command_exists git; then
        GIT_VERSION=$(git --version | cut -d' ' -f3)
        print_success "Git found: $GIT_VERSION"
        return 0
    else
        print_error "Git not found. Please install Git."
        return 1
    fi
}

# Function to validate repository structure
validate_repo() {
    print_header "Validating Repository Structure"
    
    if [[ ! -f "$REPO_ROOT/scripts/ci_validate_repo.py" ]]; then
        print_error "Validation script not found: scripts/ci_validate_repo.py"
        return 1
    fi
    
    print_info "Running repository validation..."
    if python3 "$REPO_ROOT/scripts/ci_validate_repo.py"; then
        print_success "Repository structure validation passed!"
        return 0
    else
        print_error "Repository structure validation failed!"
        return 1
    fi
}

# Function to validate shell scripts
validate_shell_scripts() {
    print_header "Validating Shell Scripts"
    
    local scripts=(
        "$REPO_ROOT/scripts/package_mt5.sh"
        "$REPO_ROOT/scripts/deploy_mt5.sh"
    )
    
    local all_valid=true
    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            print_info "Validating: $(basename "$script")"
            if bash -n "$script"; then
                print_success "$(basename "$script") syntax is valid"
            else
                print_error "$(basename "$script") syntax check failed"
                all_valid=false
            fi
        else
            print_warning "Script not found: $script"
        fi
    done
    
    if $all_valid; then
        print_success "All shell scripts are valid!"
        return 0
    else
        print_error "Some shell scripts have syntax errors!"
        return 1
    fi
}

# Function to show CLI tools status
show_cli_tools_status() {
    print_header "CLI Tools Status"
    
    local tools=(
        "gh:GitHub CLI:GitHub_CLI_setup.md"
        "firebase:Firebase CLI:Firebase_CLI_setup.md"
        "docker:Docker CLI:Docker_CLI_setup.md"
        "cursor-agent:Cursor CLI:Cursor_CLI_setup.md"
        "jules:Jules CLI:Jules_CLI_setup.md"
    )
    
    for tool_info in "${tools[@]}"; do
        IFS=':' read -r cmd name doc <<< "$tool_info"
        if command_exists "$cmd"; then
            print_success "$name is installed"
        else
            print_warning "$name is NOT installed (see docs/$doc)"
        fi
    done
}

# Function to package MT5 files
package_mt5() {
    print_header "Packaging MT5 Files"
    
    if [[ ! -f "$REPO_ROOT/scripts/package_mt5.sh" ]]; then
        print_error "Package script not found: scripts/package_mt5.sh"
        return 1
    fi
    
    print_info "Running package script..."
    if bash "$REPO_ROOT/scripts/package_mt5.sh"; then
        print_success "MT5 files packaged successfully!"
        if [[ -f "$REPO_ROOT/dist/Exness_MT5_MQL5.zip" ]]; then
            print_info "Package location: dist/Exness_MT5_MQL5.zip"
        fi
        return 0
    else
        print_error "Failed to package MT5 files!"
        return 1
    fi
}

# Function to show setup menu
show_menu() {
    print_header "MQL5 Google OneDrive - Full Setup"
    
    echo "Please select an option:"
    echo ""
    echo "  1) Run full validation (recommended first)"
    echo "  2) Check CLI tools status"
    echo "  3) Package MT5 files"
    echo "  4) Show CLI setup documentation"
    echo "  5) Run all setup steps"
    echo "  0) Exit"
    echo ""
}

# Function to show CLI documentation paths
show_cli_docs() {
    print_header "CLI Setup Documentation"
    
    echo "Setup guides are available in the docs/ directory:"
    echo ""
    echo "  - GitHub CLI:   docs/GitHub_CLI_setup.md"
    echo "  - Firebase CLI: docs/Firebase_CLI_setup.md"
    echo "  - Docker CLI:   docs/Docker_CLI_setup.md"
    echo "  - Cursor CLI:   docs/Cursor_CLI_setup.md"
    echo "  - Jules CLI:    docs/Jules_CLI_setup.md"
    echo ""
    echo "You can view these files with:"
    echo "  cat docs/<filename>.md"
    echo ""
}

# Function to run full validation
run_full_validation() {
    print_header "Running Full Validation"
    
    local validation_passed=true
    
    # Check required tools
    check_python || validation_passed=false
    check_bash || validation_passed=false
    check_git || validation_passed=false
    
    echo ""
    
    # Validate repository
    validate_repo || validation_passed=false
    
    # Validate shell scripts
    validate_shell_scripts || validation_passed=false
    
    if $validation_passed; then
        print_success "All validation checks passed! ✓"
        return 0
    else
        print_error "Some validation checks failed!"
        return 1
    fi
}

# Function to run all setup steps
run_all_steps() {
    print_header "Running All Setup Steps"
    
    run_full_validation
    echo ""
    show_cli_tools_status
    echo ""
    
    read -p "Would you like to package MT5 files? [y/N]: " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        package_mt5
    fi
    
    print_success "Setup complete!"
}

# Main function
main() {
    cd "$REPO_ROOT"
    
    # If run with --non-interactive or --ci flag, run full validation only
    if [[ "${1:-}" == "--non-interactive" ]] || [[ "${1:-}" == "--ci" ]]; then
        run_full_validation
        exit $?
    fi
    
    # Interactive mode
    while true; do
        show_menu
        read -p "Enter your choice [0-5]: " choice
        
        case $choice in
            1)
                run_full_validation
                ;;
            2)
                show_cli_tools_status
                ;;
            3)
                package_mt5
                ;;
            4)
                show_cli_docs
                ;;
            5)
                run_all_steps
                ;;
            0)
                print_info "Exiting setup. Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please try again."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
        clear
    done
}

# Run main function
main "$@"
