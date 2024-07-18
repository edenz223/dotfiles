#!/bin/bash
set -x

USE_CACHE=false
USE_CACHE=true
 
#######################################################################
# pre install
#######################################################################
sudo apt update
sudo apt install -y build-essential zsh tmux bison bash-completion tig unzip cmake luarocks

#######################################################################
# setup zsh config
#######################################################################

sudo chsh -s "$(which zsh)" "${USER}"

# 安装 oh-my-zsh
 sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 安装 zsh-autosuggestions 插件
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# 安装 zsh-syntax-highlighting 插件
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 安装 zsh-completions 插件
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions、

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

if [[ "$USE_CACHE" = false || ! -f "$HOME/.local/packages/$CONDA_NAME" ]]; then
	curl -Lo "$HOME/.local/packages/$CONDA_NAME" $CONDA_LINK
fi

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
RIPGREP_DIR=$HOME/.local/tools/ripgrep
RIPGREP_SRC_NAME=$HOME/.local/packages/ripgrep.tar.gz
RIPGREP_LINK="https://github.com/BurntSushi/ripgrep/releases/download/12.0.0/ripgrep-12.0.0-x86_64-unknown-linux-musl.tar.gz"
if [[ -z "$(command -v rg)" ]] && [[ ! -f "$RIPGREP_DIR/rg" ]]; then
    echo "Install ripgrep"
    if [[ "$USE_CACHE" = false || ! -f $RIPGREP_SRC_NAME ]]; then
        echo "Downloading ripgrep and renaming"
        wget $RIPGREP_LINK -O "$RIPGREP_SRC_NAME"
    fi

    if [[ ! -d "$RIPGREP_DIR" ]]; then
        echo "Creating ripgrep directory under tools directory"
        mkdir -p "$RIPGREP_DIR"
        echo "Extracting to $HOME/.local/tools/ripgrep directory"
        tar zxvf "$RIPGREP_SRC_NAME" -C "$RIPGREP_DIR" --strip-components 1
    fi

    sed -i "\:"$RIPGREP_DIR":d" "$HOME/.zshrc"
    echo "export PATH=\"$RIPGREP_DIR:\$PATH\"" >> "$HOME/.zshrc"
else
    echo "ripgrep is already installed. Skip installing it."
fi


#######################################################################
# Nvim install
#######################################################################
NVIM_DIR=$HOME/.local/tools/nvim
NVIM_SRC_NAME=$HOME/.local/packages/nvim-linux64.tar.gz
NVIM_CONFIG_DIR=$HOME/.config/nvim
NVIM_LINK="https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz"
if [[ "$USE_CACHE" = false || ! -f "$NVIM_DIR/bin/nvim" ]]; then
    echo "Installing Nvim"
    echo "Creating nvim directory under tools directory"

    if [[ ! -d "$NVIM_DIR" ]]; then
        mkdir -p "$NVIM_DIR"
    fi

    if [[ "$USE_CACHE" = false || ! -f $NVIM_SRC_NAME ]]; then
        echo "Downloading Nvim"
        wget "$NVIM_LINK" -O "$NVIM_SRC_NAME"
    fi
    echo "Extracting neovim"
    tar zxvf "$NVIM_SRC_NAME" --strip-components 1 -C "$NVIM_DIR"

    sed -i "\:"$NVIM_DIR/bin":d" "$HOME/.zshrc"
    echo "export PATH=\"$NVIM_DIR/bin:\$PATH\"" >> "$HOME/.zshrc"
else
    echo "Nvim is already installed. Skip installing it."
fi

# install delta
musl=$([[ $(lsb_release -r | cut -f2) == "20.04" ]] && echo "" || echo "-musl") # https://github.com/dandavison/delta/issues/504
arch=$([[ $(uname -m) == "x86_64" ]] && echo "amd64" || echo "armhf")
curl -fsSL https://github.com/dandavison/delta/releases/download/0.14.0/git-delta${musl}_0.14.0_$arch.deb -o /tmp/git-delta_$arch.deb && sudo dpkg -i /tmp/git-delta_$arch.deb

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

# installl gdu for disk usage analyzer
curl -L https://github.com/dundee/gdu/releases/latest/download/gdu_linux_amd64.tgz | tar xz
chmod +x gdu_linux_amd64
sudo mv gdu_linux_amd64 /usr/bin/gdu

# install lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm -rf lazygit*

eval "$NVIM_DIR/bin/nvim --headless +qa"

echo "Finished installing Nvim and its dependencies!"

