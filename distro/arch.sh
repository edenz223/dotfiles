#!/bin/bash
# Arch Linux specific installation script

install_system_packages_arch() {
    log_info "=== Installing system packages for Arch Linux ==="

    export PACKAGE_MANAGER="pacman"

    # Update package cache
    update_package_cache

    # Install base packages
    local packages=(
        "base-devel"
        "zsh"
        "tmux"
        "bison"
        "bash-completion"
        "tig"
        "unzip"
        "cmake"
        "luarocks"
        "git"
        "curl"
    )

    install_packages "${packages[@]}"

    log_success "System packages installed"
}

install_tools_arch() {
    log_info "=== Installing additional tools for Arch Linux ==="

    # These tools are available in official Arch repos
    local tools=(
        "ripgrep"      # rg
        "git-delta"    # delta
        "gdu"          # disk usage analyzer
        "lazygit"      # git TUI
    )

    install_packages "${tools[@]}"

    log_success "Additional tools installed"
}

# Run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

    # Source dependencies
    source "$DOTFILES_ROOT/config/versions.conf"
    source "$DOTFILES_ROOT/lib/common.sh"

    install_system_packages_arch
    install_tools_arch
fi
