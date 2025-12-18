#!/bin/bash
# Python/Miniconda setup module
# Installs Miniconda and required Python packages

setup_python() {
    log_info "=== Setting up Python environment with Miniconda ==="

    # Create necessary directories
    ensure_dir "$HOME/.local/packages/"
    ensure_dir "$HOME/.local/tools/"

    local CONDA_DIR=$HOME/.local/tools/miniconda
    local CONDA_NAME=Miniconda.sh

    # Download Miniconda
    log_info "Downloading Miniconda"
    download_with_cache "$MINICONDA_LINK" "$HOME/.local/packages/$CONDA_NAME"

    # Install conda silently
    if [[ -d $CONDA_DIR ]]; then
        log_warning "Miniconda directory exists, removing old installation"
        rm -rf "$CONDA_DIR"
    fi

    log_info "Installing Miniconda to $CONDA_DIR"
    bash "$HOME/.local/packages/$CONDA_NAME" -b -p "$CONDA_DIR"
    log_success "Miniconda installed"

    # Add to PATH
    add_to_path "$CONDA_DIR/bin"

    # Install Python packages
    log_info "Installing Python packages"
    for package in "${PYTHON_PACKAGES[@]}"; do
        log_info "Installing $package"
        "$CONDA_DIR/bin/pip" install "$package" || log_warning "Failed to install $package"
    done

    log_success "Python environment setup completed!"
}

# Run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

    # Source dependencies
    source "$DOTFILES_ROOT/config/versions.conf"
    source "$DOTFILES_ROOT/lib/common.sh"

    setup_python
fi
