#!/bin/bash
#######################################################################
# Unified setup script for dotfiles
# Supports Ubuntu/Debian and Arch Linux
#
# This script replaces setup_ubuntu2204.sh and setup_arch.sh
# It uses modular components from lib/ and distro-specific configs
#######################################################################

set -euo pipefail

# Get script directory and dotfiles root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$SCRIPT_DIR"

# Source configuration and common library
source "$DOTFILES_ROOT/config/versions.conf"
source "$DOTFILES_ROOT/lib/common.sh"

# Enable caching by default
export USE_CACHE="${USE_CACHE:-true}"

#######################################################################
# Main setup function
#######################################################################

main() {
    log_info "==================================================================="
    log_info "  Dotfiles Setup Script"
    log_info "  Unified installation for Ubuntu/Debian and Arch Linux"
    log_info "==================================================================="
    echo ""

    # Detect OS
    local os_id
    os_id=$(detect_os)
    log_info "Detected OS: $os_id"

    # Detect and source distro-specific script
    local distro_script=""
    case "$os_id" in
        ubuntu|debian)
            distro_script="$DOTFILES_ROOT/distro/ubuntu.sh"
            ;;
        arch|manjaro)
            distro_script="$DOTFILES_ROOT/distro/arch.sh"
            ;;
        *)
            log_error "Unsupported OS: $os_id"
            log_error "Supported: ubuntu, debian, arch, manjaro"
            exit 1
            ;;
    esac

    log_info "Using distro-specific script: $distro_script"
    source "$distro_script"
    source "$DOTFILES_ROOT/lib/setup-tools.sh"

    # Step 1: Install system packages
    case "$os_id" in
        ubuntu|debian)
            install_system_packages_ubuntu
            ;;
        arch|manjaro)
            install_system_packages_arch
            ;;
    esac

    # Step 2: Setup Zsh and oh-my-zsh
    source "$DOTFILES_ROOT/lib/setup-zsh.sh"
    setup_zsh

    # Step 3: Setup Python environment
    source "$DOTFILES_ROOT/lib/setup-python.sh"
    setup_python

    # Step 4: Install additional tools
    case "$os_id" in
        ubuntu|debian)
            install_tools_ubuntu
            ;;
        arch|manjaro)
            install_tools_arch
            ;;
    esac

    # Step 5: Setup Neovim
    source "$DOTFILES_ROOT/lib/setup-nvim.sh"
    setup_nvim

    # Step 6: Verify installation
    echo ""
    log_info "==================================================================="
    log_info "  Installation Complete - Running Verification"
    log_info "==================================================================="
    echo ""
    verify_installation || log_warning "Some tools failed verification"

    # Summary
    echo ""
    log_info "==================================================================="
    log_success "✓ Dotfiles setup completed successfully!"
    log_info "==================================================================="
    echo ""
    log_info "Next steps:"
    log_info "  1. Restart your shell or run: exec zsh"
    log_info "  2. Run tmux to use your tmux configuration"
    log_info "  3. Run nvim to start Neovim"
    echo ""
}

# Run main function
main "$@"
