#!/bin/bash
set -x

USE_CACHE="${USE_CACHE:-true}"

download_with_cache() {
	local url="$1"
	local destination="$2"

	if [[ "$USE_CACHE" = false || ! -f "$destination" ]]; then
		mkdir -p "$(dirname "$destination")"
		echo "Downloading ${url} -> ${destination}"
		curl -L --fail -o "$destination" "$url"
	else
		echo "Using cached $(basename "$destination")"
	fi
}

clone_if_missing() {
	local repo="$1"
	local target="$2"
	if [[ -d "$target" ]]; then
		echo "$target already exists. Skipping clone."
	else
		git clone "$repo" "$target"
	fi
}

#######################################################################
# pre install
#######################################################################
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm base-devel zsh tmux bison bash-completion tig unzip cmake luarocks git curl

#######################################################################
# setup zsh config
#######################################################################

sudo chsh -s "$(which zsh)" "${USER}"

# 安装 oh-my-zsh
 sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 安装 zsh-autosuggestions 插件
ZSH_CUSTOM_DIR=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM_DIR}/plugins/zsh-autosuggestions"

# 安装 zsh-syntax-highlighting 插件
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM_DIR}/plugins/zsh-syntax-highlighting"

# 安装 zsh-completions 插件
clone_if_missing https://github.com/zsh-users/zsh-completions "${ZSH_CUSTOM_DIR}/plugins/zsh-completions"

# 在 .zshrc 文件中添加一行来更新 FPATH
sed -i '/^source \$ZSH\/oh-my-zsh.sh/i fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src' ~/.zshrc

# 更新 .zshrc 文件以启用插件
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting sudo)/g' ~/.zshrc

echo "Finished installing oh-my-zsh and its dependencies!"


#######################################################################
# install python3
#######################################################################

if [[ ! -d "$HOME/.local/packages/" ]]; then
    mkdir -p "$HOME/.local/packages/"
fi

if [[ ! -d "$HOME/.local/tools/" ]]; then
    mkdir -p "$HOME/.local/tools/"
fi

CONDA_DIR=$HOME/.local/tools/miniconda
CONDA_NAME=Miniconda.sh
CONDA_LINK="https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh"

echo "Installing Python in user HOME"
echo "Downloading and installing miniconda"

download_with_cache "$CONDA_LINK" "$HOME/.local/packages/$CONDA_NAME"

# Install conda silently
if [[ -d $CONDA_DIR ]]; then
	rm -rf "$CONDA_DIR"
fi
bash "$HOME/.local/packages/$CONDA_NAME" -b -p "$CONDA_DIR"

# Setting up environment variables
sed -i "\:"$CONDA_DIR/bin":d" "$HOME/.zshrc"
echo "export PATH=\"$CONDA_DIR/bin:\$PATH\"" >> "$HOME/.zshrc"

echo "Installing Python packages"
declare -a py_packages=("pynvim" 'python-lsp-server[all]' "black" "vim-vint" "pyls-isort" "pylsp-mypy" "requests")

for p in "${py_packages[@]}"; do
	"$CONDA_DIR/bin/pip" install "$p"
done

#######################################################################
# Ripgrep part
#######################################################################
# ripgrep is available in official Arch repos
sudo pacman -S --noconfirm ripgrep


#######################################################################
# Nvim install
#######################################################################
NVIM_DIR=$HOME/.local/tools/nvim
NVIM_SRC_NAME=$HOME/.local/packages/nvim-linux-x86_64.tar.gz
NVIM_CONFIG_DIR=$HOME/.config/nvim
NVIM_LINK="https://github.com/neovim/neovim/releases/download/v0.11.1/nvim-linux-x86_64.tar.gz"
if [[ "$USE_CACHE" = false || ! -f "$NVIM_DIR/bin/nvim" ]]; then
    echo "Installing Nvim"
    echo "Creating nvim directory under tools directory"

    if [[ ! -d "$NVIM_DIR" ]]; then
        mkdir -p "$NVIM_DIR"
    fi

	echo "Downloading Nvim"
	download_with_cache "$NVIM_LINK" "$NVIM_SRC_NAME"
    echo "Extracting neovim"
    tar zxvf "$NVIM_SRC_NAME" --strip-components 1 -C "$NVIM_DIR"

    sed -i "\:"$NVIM_DIR/bin":d" "$HOME/.zshrc"
    echo "export PATH=\"$NVIM_DIR/bin:\$PATH\"" >> "$HOME/.zshrc"
else
    echo "Nvim is already installed. Skip installing it."
fi

# install delta (git-delta is available in official Arch repos)
sudo pacman -S --noconfirm git-delta

#######################################################################
# setup nvim config
#######################################################################
echo "Setting up config and installing plugins"
if [[ -d "$NVIM_CONFIG_DIR" ]]; then
    cd "$NVIM_CONFIG_DIR"
    git pull
else
    git clone --depth 1 https://github.com/edenz223/neovimConfig "$NVIM_CONFIG_DIR"
fi

# install gdu for disk usage analyzer (available in official Arch repos)
sudo pacman -S --noconfirm gdu

# install lazygit (available in official Arch repos)
sudo pacman -S --noconfirm lazygit

eval "$NVIM_DIR/bin/nvim --headless +qa"

echo "Finished installing Nvim and its dependencies!"
