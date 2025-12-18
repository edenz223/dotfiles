#!/bin/bash
# Common utility functions for dotfiles setup
# This library is sourced by other setup scripts

#######################################################################
# Error handling and logging (Solution 4)
#######################################################################

# Strict error handling
set -euo pipefail

# Trap errors and show line number
trap 'echo "❌ Error occurred in ${BASH_SOURCE[0]} at line $LINENO. Exit code: $?" >&2' ERR

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[✗]${NC} $*" >&2
}

#######################################################################
# Download and caching utilities
#######################################################################

download_with_cache() {
    local url="$1"
    local destination="$2"

    if [[ "$USE_CACHE" = false || ! -f "$destination" ]]; then
        mkdir -p "$(dirname "$destination")"
        log_info "Downloading ${url} -> ${destination}"
        if curl -L --fail -o "$destination" "$url"; then
            log_success "Downloaded $(basename "$destination")"
        else
            log_error "Failed to download from $url"
            return 1
        fi
    else
        log_info "Using cached $(basename "$destination")"
    fi
}

#######################################################################
# Git repository management
#######################################################################

clone_if_missing() {
    local repo="$1"
    local target="$2"

    if [[ -d "$target" ]]; then
        log_info "$target already exists. Skipping clone."
    else
        log_info "Cloning $repo to $target"
        if git clone "$repo" "$target"; then
            log_success "Cloned $(basename "$target")"
        else
            log_error "Failed to clone $repo"
            return 1
        fi
    fi
}

#######################################################################
# PATH management utilities
#######################################################################

# Add directory to PATH in a configuration file (avoiding duplicates)
add_to_path() {
    local dir="$1"
    local config_file="${2:-$HOME/.zshrc}"

    # Remove old entries to avoid duplicates
    sed -i "\:$dir:d" "$config_file" 2>/dev/null || true

    # Add new entry
    echo "export PATH=\"$dir:\$PATH\"" >> "$config_file"
    log_success "Added $dir to PATH in $config_file"
}

# Add source line to config file (avoiding duplicates)
add_source_line() {
    local source_file="$1"
    local config_file="${2:-$HOME/.zshrc}"
    local source_line="${3:-. $source_file}"

    # Remove old entries
    sed -i "\:$source_file:d" "$config_file" 2>/dev/null || true

    # Add new entry
    echo "$source_line" >> "$config_file"
    log_success "Added source line for $source_file to $config_file"
}

#######################################################################
# Package manager abstraction
#######################################################################

# Detect package manager
detect_package_manager() {
    if command -v apt >/dev/null 2>&1; then
        echo "apt"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum"
    else
        log_error "No supported package manager found"
        return 1
    fi
}

# Install packages using the appropriate package manager
install_packages() {
    local pm="${PACKAGE_MANAGER:-$(detect_package_manager)}"
    local packages=("$@")

    log_info "Installing packages using $pm: ${packages[*]}"

    case "$pm" in
        apt)
            sudo apt update
            sudo apt install -y "${packages[@]}"
            ;;
        pacman)
            sudo pacman -S --noconfirm "${packages[@]}"
            ;;
        dnf|yum)
            sudo "$pm" install -y "${packages[@]}"
            ;;
        *)
            log_error "Unsupported package manager: $pm"
            return 1
            ;;
    esac

    log_success "Installed ${packages[*]}"
}

# Update package manager cache
update_package_cache() {
    local pm="${PACKAGE_MANAGER:-$(detect_package_manager)}"

    log_info "Updating package cache for $pm"

    case "$pm" in
        apt)
            sudo apt update
            ;;
        pacman)
            sudo pacman -Syu --noconfirm
            ;;
        dnf|yum)
            sudo "$pm" check-update || true
            ;;
    esac

    log_success "Package cache updated"
}

#######################################################################
# Directory management
#######################################################################

ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_success "Created directory: $dir"
    fi
}

#######################################################################
# Installation verification (Solution 5)
#######################################################################

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Verify a tool is installed
verify_tool() {
    local tool="$1"
    local version_arg="${2:---version}"

    if command_exists "$tool"; then
        local version
        version=$("$tool" "$version_arg" 2>&1 | head -n1)
        log_success "$tool is installed: $version"
        return 0
    else
        log_error "$tool is NOT installed"
        return 1
    fi
}

# Verify all required tools are installed
verify_installation() {
    log_info "Verifying installation..."
    local failed=0

    # Core tools
    verify_tool "zsh" || ((failed++))
    verify_tool "tmux" "-V" || ((failed++))
    verify_tool "git" || ((failed++))

    # Development tools
    verify_tool "nvim" || ((failed++))
    verify_tool "rg" || ((failed++))
    verify_tool "delta" || ((failed++))

    # Python
    verify_tool "python3" || ((failed++))
    verify_tool "pip3" || ((failed++))

    # Modern tools
    verify_tool "lazygit" || ((failed++))
    verify_tool "gdu" || ((failed++))

    # Zsh setup
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_success "oh-my-zsh is installed"
    else
        log_error "oh-my-zsh is NOT installed"
        ((failed++))
    fi

    # Summary
    echo ""
    if [[ $failed -eq 0 ]]; then
        log_success "✓ All tools verified successfully!"
        return 0
    else
        log_warning "⚠ $failed tool(s) failed verification"
        return 1
    fi
}

# Quick verification (only check critical tools)
verify_critical() {
    local failed=0

    command_exists "zsh" || { log_error "zsh not found"; ((failed++)); }
    command_exists "git" || { log_error "git not found"; ((failed++)); }
    command_exists "nvim" || { log_error "nvim not found"; ((failed++)); }

    return $failed
}

#######################################################################
# Platform detection
#######################################################################

detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "${ID:-unknown}"
    else
        uname -s | tr '[:upper:]' '[:lower:]'
    fi
}

detect_arch() {
    uname -m
}

#######################################################################
# Init
#######################################################################

# Set USE_CACHE default if not already set
export USE_CACHE="${USE_CACHE:-true}"

log_info "Common library loaded (strict mode: enabled)"
