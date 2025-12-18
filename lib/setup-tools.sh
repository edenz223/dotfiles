#!/bin/bash
# Additional tools setup module
# Installs ripgrep, git-delta, lazygit, gdu, etc.

setup_ripgrep_from_source() {
    log_info "Installing ripgrep from source"

    local RIPGREP_DIR=$HOME/.local/tools/ripgrep
    local RIPGREP_SRC_NAME=$HOME/.local/packages/ripgrep.tar.gz

    if command_exists rg && [[ ! -f "$RIPGREP_DIR/rg" ]]; then
        log_info "ripgrep is already installed in system"
        return 0
    fi

    if [[ -f "$RIPGREP_DIR/rg" ]]; then
        log_info "ripgrep already installed in $RIPGREP_DIR"
        return 0
    fi

    log_info "Downloading ripgrep"
    download_with_cache "$RIPGREP_LINK" "$RIPGREP_SRC_NAME"

    ensure_dir "$RIPGREP_DIR"

    log_info "Extracting ripgrep"
    tar zxvf "$RIPGREP_SRC_NAME" -C "$RIPGREP_DIR" --strip-components 1 >/dev/null 2>&1

    add_to_path "$RIPGREP_DIR"

    log_success "ripgrep installed"
}

setup_delta_from_deb() {
    log_info "Installing git-delta from .deb package"

    local musl=$([[ $(lsb_release -r | cut -f2 2>/dev/null) == "20.04" ]] && echo "" || echo "-musl")
    local arch=$([[ $(uname -m) == "x86_64" ]] && echo "amd64" || echo "armhf")
    local deb_url="https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta${musl}_${DELTA_VERSION}_${arch}.deb"

    log_info "Downloading delta .deb"
    curl -fsSL "$deb_url" -o /tmp/git-delta_${arch}.deb

    log_info "Installing delta"
    sudo dpkg -i /tmp/git-delta_${arch}.deb

    log_success "git-delta installed"
}

setup_gdu_from_source() {
    log_info "Installing gdu (disk usage analyzer)"

    local GDU_ARCHIVE="$HOME/.local/packages/gdu_linux_amd64.tgz"

    download_with_cache "$GDU_LINK" "$GDU_ARCHIVE"

    log_info "Extracting and installing gdu"
    tar xzf "$GDU_ARCHIVE" gdu_linux_amd64
    chmod +x gdu_linux_amd64
    sudo mv gdu_linux_amd64 /usr/bin/gdu

    log_success "gdu installed"
}

setup_lazygit_from_source() {
    log_info "Installing lazygit"

    local LAZYGIT_VERSION
    LAZYGIT_VERSION=$(eval "$LAZYGIT_VERSION_CMD")

    local LAZYGIT_ARCHIVE="$HOME/.local/packages/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    local LAZYGIT_URL="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"

    download_with_cache "$LAZYGIT_URL" "$LAZYGIT_ARCHIVE"

    log_info "Extracting and installing lazygit"
    tar xf "$LAZYGIT_ARCHIVE" lazygit
    sudo install lazygit /usr/local/bin
    rm -f lazygit

    log_success "lazygit installed (version: $LAZYGIT_VERSION)"
}

install_fzf() {
    log_info "Installing fzf from source"

    local fzf_dir="${FZF_INSTALL_DIR:-$HOME/.fzf}"

    if [[ ! -d "$fzf_dir" ]]; then
        clone_if_missing "$FZF_REPO" "$fzf_dir"

        if [[ -x "$fzf_dir/install" ]]; then
            "$fzf_dir/install" --all
            log_success "fzf installed in $fzf_dir"
        else
            log_error "fzf install script not found at $fzf_dir/install"
        fi
    else
        log_info "fzf already installed in $fzf_dir. Run $fzf_dir/install to update if needed."
    fi
}

setup_tools() {
    log_info "=== Setting up additional tools ==="

    # These functions will be called by distro-specific scripts
    # They are defined here for reuse
    log_info "Tools module loaded"
}

# Run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

    # Source dependencies
    source "$DOTFILES_ROOT/config/versions.conf"
    source "$DOTFILES_ROOT/lib/common.sh"

    setup_tools
fi
