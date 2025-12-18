#!/bin/bash
# Zsh setup module
# Installs and configures zsh, oh-my-zsh, plugins, and fzf

setup_zsh() {
    log_info "=== Setting up Zsh and oh-my-zsh ==="

    # Change default shell to zsh
    if [[ "$SHELL" != *"zsh"* ]]; then
        log_info "Changing default shell to zsh"
        sudo chsh -s "$(which zsh)" "${USER}"
        log_success "Default shell changed to zsh"
    else
        log_info "Zsh is already the default shell"
    fi

    # Install oh-my-zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Installing oh-my-zsh"
        sh -c "$(curl -fsSL ${OHMYZSH_INSTALL_URL})" "" --unattended
        log_success "oh-my-zsh installed"
    else
        log_info "oh-my-zsh already installed"
    fi

    # Install fzf (source)
    install_fzf

    # Setup custom plugin directory
    local ZSH_CUSTOM_DIR=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}

    # Install zsh-autosuggestions plugin
    log_info "Installing zsh-autosuggestions plugin"
    clone_if_missing "$ZSH_AUTOSUGGESTIONS_REPO" "${ZSH_CUSTOM_DIR}/plugins/zsh-autosuggestions"

    # Install zsh-syntax-highlighting plugin
    log_info "Installing zsh-syntax-highlighting plugin"
    clone_if_missing "$ZSH_SYNTAX_HIGHLIGHTING_REPO" "${ZSH_CUSTOM_DIR}/plugins/zsh-syntax-highlighting"

    # Install zsh-completions plugin
    log_info "Installing zsh-completions plugin"
    clone_if_missing "$ZSH_COMPLETIONS_REPO" "${ZSH_CUSTOM_DIR}/plugins/zsh-completions"

    # Install zsh-z plugin
    log_info "Installing zsh-z plugin"
    clone_if_missing "$ZSH_Z_REPO" "${ZSH_CUSTOM_DIR}/plugins/zsh-z"

    # Install fzf-tab plugin
    log_info "Installing fzf-tab plugin"
    clone_if_missing "$FZF_TAB_REPO" "${ZSH_CUSTOM_DIR}/plugins/fzf-tab"

    # Update .zshrc to add fpath for completions
    if ! grep -q "fpath+=" "$HOME/.zshrc" 2>/dev/null; then
        log_info "Adding zsh-completions to fpath"
        sed -i '/^source \$ZSH\/oh-my-zsh.sh/i fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src' ~/.zshrc
    fi

    # Update .zshrc to enable plugins
    if grep -q "plugins=(git)" "$HOME/.zshrc" 2>/dev/null; then
        log_info "Enabling zsh plugins"
        sed -i 's/plugins=(git)/plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting zsh-z fzf fzf-tab)/g' ~/.zshrc
        log_success "Zsh plugins enabled"
    fi

    log_success "Zsh setup completed!"
}

# Run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

    # Source dependencies
    source "$DOTFILES_ROOT/config/versions.conf"
    source "$DOTFILES_ROOT/lib/common.sh"

    setup_zsh
fi
