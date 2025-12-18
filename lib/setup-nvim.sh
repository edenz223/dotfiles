#!/bin/bash
# Neovim setup module
# Installs Neovim and configures it

setup_nvim() {
    log_info "=== Setting up Neovim ==="

    local NVIM_DIR=$HOME/.local/tools/nvim
    local NVIM_SRC_NAME=$HOME/.local/packages/nvim-linux-x86_64.tar.gz
    local NVIM_CONFIG_DIR=$HOME/.config/nvim

    # Create necessary directories
    ensure_dir "$HOME/.local/packages/"
    ensure_dir "$HOME/.local/tools/"

    # Download and install Neovim
    if [[ "$USE_CACHE" = false || ! -f "$NVIM_DIR/bin/nvim" ]]; then
        log_info "Installing Neovim"

        ensure_dir "$NVIM_DIR"

        log_info "Downloading Neovim v${NVIM_VERSION}"
        download_with_cache "$NVIM_LINK" "$NVIM_SRC_NAME"

        log_info "Extracting Neovim"
        tar zxvf "$NVIM_SRC_NAME" --strip-components 1 -C "$NVIM_DIR" >/dev/null 2>&1

        # Add to PATH
        add_to_path "$NVIM_DIR/bin"

        log_success "Neovim installed"
    else
        log_info "Neovim is already installed. Skipping installation."
    fi

    # Setup Neovim config
    log_info "Setting up Neovim configuration"
    if [[ -d "$NVIM_CONFIG_DIR" ]]; then
        log_info "Updating existing Neovim config"
        cd "$NVIM_CONFIG_DIR"
        git pull || log_warning "Failed to update Neovim config"
    else
        log_info "Cloning Neovim config from $NVIM_CONFIG_REPO"
        git clone --depth 1 "$NVIM_CONFIG_REPO" "$NVIM_CONFIG_DIR"
    fi

    # Initialize Neovim (install plugins)
    log_info "Initializing Neovim plugins"
    eval "$NVIM_DIR/bin/nvim --headless +qa" 2>/dev/null || true

    log_success "Neovim setup completed!"
}

# Run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

    # Source dependencies
    source "$DOTFILES_ROOT/config/versions.conf"
    source "$DOTFILES_ROOT/lib/common.sh"

    setup_nvim
fi
