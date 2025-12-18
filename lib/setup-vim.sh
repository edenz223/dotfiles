#!/bin/bash
# Lightweight Vim setup module for servers
# Just basic vim with practical configuration

setup_vim() {
    log_info "=== Setting up Vim (lightweight) ==="

    # Check if vim is already installed
    if command_exists vim; then
        log_info "Vim is already installed"
        vim --version | head -n1
    else
        log_warning "Vim is not installed. Please install it first."
        return 1
    fi

    # Setup vim configuration
    local VIMRC_SOURCE="$DOTFILES_ROOT/etc/vimrc"
    local VIMRC_TARGET="$HOME/.vimrc"

    if [[ -f "$VIMRC_SOURCE" ]]; then
        log_info "Installing vim configuration"
        cp "$VIMRC_SOURCE" "$VIMRC_TARGET"
        log_success "Vim configuration installed to ~/.vimrc"
    else
        log_warning "Vimrc source file not found: $VIMRC_SOURCE"
    fi

    # Create vim directories
    ensure_dir "$HOME/.vim/backup"
    ensure_dir "$HOME/.vim/swap"
    ensure_dir "$HOME/.vim/undo"

    log_success "Vim setup completed!"
}

# Run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

    # Source dependencies
    source "$DOTFILES_ROOT/lib/common.sh"

    setup_vim
fi
