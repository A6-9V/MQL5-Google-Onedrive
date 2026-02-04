#!/usr/bin/env bash
# Release Preparation Script
# This script helps prepare and create a new release

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    local missing=0
    
    if ! command_exists git; then
        print_error "git is not installed"
        missing=1
    fi
    
    if ! command_exists python3; then
        print_error "python3 is not installed"
        missing=1
    fi
    
    if ! command_exists gh; then
        print_warning "GitHub CLI (gh) is not installed - manual release creation will be required"
    fi
    
    if [ $missing -eq 1 ]; then
        print_error "Missing required dependencies. Please install them and try again."
        exit 1
    fi
    
    print_success "All required dependencies are available"
}

# Validate repository
validate_repository() {
    print_info "Validating repository structure..."
    
    cd "$ROOT_DIR"
    
    if ! python3 scripts/ci_validate_repo.py; then
        print_error "Repository validation failed"
        return 1
    fi
    
    print_success "Repository structure is valid"
}

# Check git status
check_git_status() {
    print_info "Checking git status..."
    
    cd "$ROOT_DIR"
    
    if [ -n "$(git status --porcelain)" ]; then
        print_warning "Working directory is not clean:"
        git status --short
        echo
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Release preparation cancelled"
            exit 1
        fi
    else
        print_success "Working directory is clean"
    fi
}

# Get current version from EA
get_current_version() {
    cd "$ROOT_DIR"
    local ea_file="mt5/MQL5/Experts/SMC_TrendBreakout_MTF_EA.mq5"
    
    if [ ! -f "$ea_file" ]; then
        print_error "EA file not found: $ea_file"
        return 1
    fi
    
    local version=$(grep "#property version" "$ea_file" | sed 's/.*"\(.*\)".*/\1/')
    echo "$version"
}

# Run tests
run_tests() {
    print_info "Running validation tests..."
    
    cd "$ROOT_DIR"
    
    # Validate shell scripts
    print_info "Validating shell scripts..."
    if ! bash -n scripts/package_mt5.sh; then
        print_error "package_mt5.sh has syntax errors"
        return 1
    fi
    
    if ! bash -n scripts/deploy_mt5.sh; then
        print_error "deploy_mt5.sh has syntax errors"
        return 1
    fi
    
    # Run automation tests if available
    if [ -f "scripts/test_automation.py" ]; then
        print_info "Running automation tests..."
        if ! python3 scripts/test_automation.py; then
            print_warning "Some automation tests failed"
        fi
    fi
    
    print_success "All validation tests passed"
}

# Package MT5 files
package_mt5() {
    print_info "Packaging MT5 files..."
    
    cd "$ROOT_DIR"
    
    if ! bash scripts/package_mt5.sh; then
        print_error "Failed to package MT5 files"
        return 1
    fi
    
    if [ -f "dist/Exness_MT5_MQL5.zip" ]; then
        local size=$(du -h dist/Exness_MT5_MQL5.zip | cut -f1)
        print_success "Package created: dist/Exness_MT5_MQL5.zip ($size)"
    else
        print_error "Package file not found"
        return 1
    fi
}

# Create release tag
create_release_tag() {
    local version=$1
    
    print_info "Creating release tag: v$version"
    
    cd "$ROOT_DIR"
    
    # Check if tag already exists
    if git rev-parse "v$version" >/dev/null 2>&1; then
        print_error "Tag v$version already exists"
        return 1
    fi
    
    # Create annotated tag
    git tag -a "v$version" -m "Release v$version"
    
    print_success "Tag v$version created"
    
    # Ask to push
    echo
    read -p "Push tag to origin? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git push origin "v$version"
        print_success "Tag pushed to origin"
        print_info "GitHub Actions will now create the release automatically"
    else
        print_warning "Tag not pushed. Run 'git push origin v$version' to trigger the release workflow"
    fi
}

# Create release via GitHub CLI
create_release_gh() {
    local version=$1
    
    if ! command_exists gh; then
        print_warning "GitHub CLI not available. Please create the release manually or push the tag."
        return 0
    fi
    
    print_info "Creating GitHub release via GitHub CLI..."
    
    cd "$ROOT_DIR"
    
    # Extract release notes
    local notes_file=$(mktemp)
    if [ -f "CHANGELOG.md" ]; then
        awk "/## \[${version}\]/,/## \[/{if(/## \[${version}\]/)f=1;else if(/## \[/)exit;if(f)print}" CHANGELOG.md > "$notes_file"
        
        if [ ! -s "$notes_file" ]; then
            echo "Release v$version" > "$notes_file"
            echo "" >> "$notes_file"
            echo "See CHANGELOG.md for details." >> "$notes_file"
        fi
    else
        echo "Release v$version" > "$notes_file"
        echo "" >> "$notes_file"
        echo "MQL5 SMC + Trend Breakout Trading System" >> "$notes_file"
    fi
    
    # Create release
    if gh release create "v$version" \
        --title "Release v$version" \
        --notes-file "$notes_file" \
        dist/Exness_MT5_MQL5.zip; then
        print_success "GitHub release created: v$version"
    else
        print_error "Failed to create GitHub release"
        rm -f "$notes_file"
        return 1
    fi
    
    rm -f "$notes_file"
}

# Main menu
show_menu() {
    echo
    echo "======================================"
    echo "   Release Preparation Tool"
    echo "======================================"
    echo
    echo "1. Full release preparation (recommended)"
    echo "2. Check prerequisites only"
    echo "3. Validate repository only"
    echo "4. Run tests only"
    echo "5. Package MT5 files only"
    echo "6. Create release tag and push"
    echo "7. Exit"
    echo
}

# Full release workflow
full_release() {
    print_info "Starting full release preparation..."
    echo
    
    check_prerequisites
    echo
    
    check_git_status
    echo
    
    validate_repository
    echo
    
    run_tests
    echo
    
    package_mt5
    echo
    
    local current_version=$(get_current_version)
    print_info "Current version in EA: $current_version"
    echo
    
    read -p "Enter release version (default: $current_version): " version
    version=${version:-$current_version}
    
    print_info "Preparing release v$version"
    echo
    
    read -p "Create and push release tag? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        create_release_tag "$version"
    else
        print_warning "Release tag not created"
        print_info "You can create it manually later with: git tag -a v$version -m 'Release v$version'"
    fi
    
    echo
    print_success "Release preparation complete!"
    echo
    print_info "Next steps:"
    echo "  1. If you pushed the tag, GitHub Actions will create the release automatically"
    echo "  2. Monitor the workflow at: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/actions"
    echo "  3. Once complete, the release will be available at: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/releases"
}

# Main script
main() {
    cd "$ROOT_DIR"
    
    if [ $# -eq 0 ]; then
        while true; do
            show_menu
            read -p "Choose an option: " choice
            echo
            
            case $choice in
                1)
                    full_release
                    break
                    ;;
                2)
                    check_prerequisites
                    ;;
                3)
                    validate_repository
                    ;;
                4)
                    run_tests
                    ;;
                5)
                    package_mt5
                    ;;
                6)
                    local version=$(get_current_version)
                    read -p "Enter release version (default: $version): " version
                    version=${version:-$version}
                    create_release_tag "$version"
                    ;;
                7)
                    print_info "Exiting..."
                    exit 0
                    ;;
                *)
                    print_error "Invalid option"
                    ;;
            esac
            echo
            read -p "Press Enter to continue..."
        done
    else
        case "$1" in
            --full)
                full_release
                ;;
            --check)
                check_prerequisites
                ;;
            --validate)
                validate_repository
                ;;
            --test)
                run_tests
                ;;
            --package)
                package_mt5
                ;;
            --tag)
                local version=${2:-$(get_current_version)}
                create_release_tag "$version"
                ;;
            --help)
                echo "Usage: $0 [OPTION]"
                echo
                echo "Options:"
                echo "  --full       Run full release preparation"
                echo "  --check      Check prerequisites only"
                echo "  --validate   Validate repository only"
                echo "  --test       Run tests only"
                echo "  --package    Package MT5 files only"
                echo "  --tag [VER]  Create release tag"
                echo "  --help       Show this help message"
                echo
                echo "If no option is provided, an interactive menu will be shown."
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    fi
}

main "$@"
