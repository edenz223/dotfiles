#!/bin/bash
# Ubuntu/Debian specific installation script

install_system_packages_ubuntu() {
    log_info "=== Installing system packages for Ubuntu/Debian ==="

    export PACKAGE_MANAGER="apt"

    # Update package cache
    update_package_cache

    # Install base packages
    local packages=(
        "build-essential"
        "zsh"
        "tmux"
        "bison"
        "bash-completion"
        "tig"
        "unzip"
        "cmake"
        "luarocks"
    )

    install_packages "${packages[@]}"

    log_success "System packages installed"
}

install_tools_ubuntu() {
    log_info "=== Installing additional tools for Ubuntu/Debian ==="

    # Install ripgrep from source (not in older Ubuntu repos)
    setup_ripgrep_from_source

    # Install git-delta from .deb
    setup_delta_from_deb

    # Install gdu from source
    setup_gdu_from_source

    # Install lazygit from source
    setup_lazygit_from_source

    log_success "Additional tools installed"
}

# Run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

    # Source dependencies
    source "$DOTFILES_ROOT/config/versions.conf"
    source "$DOTFILES_ROOT/lib/common.sh"
    source "$DOTFILES_ROOT/lib/setup-tools.sh"

    install_system_packages_ubuntu
    install_tools_ubuntu
fi
