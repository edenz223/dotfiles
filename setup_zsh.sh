#!/usr/bin/env bash
set -e

sudo apt update
sudo apt install -y zsh git curl

# Install oh-my-zsh non-interactively if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
# Install fzf from source so it stays up to date regardless of distro packages
if [ ! -d "$HOME/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all
else
  echo "fzf already installed in ~/.fzf. Run ~/.fzf/install to update if needed."
fi

# Plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"

clone_if_missing () {
  local repo=$1
  local dest=$2
  if [ ! -d "$dest" ]; then
    git clone "$repo" "$dest"
  fi
}

clone_if_missing https://github.com/zsh-users/zsh-autosuggestions \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone_if_missing https://github.com/agkozak/zsh-z \
  "$ZSH_CUSTOM/plugins/zsh-z"
clone_if_missing https://github.com/Aloxaf/fzf-tab \
  "$ZSH_CUSTOM/plugins/fzf-tab"

# Update .zshrc
if ! grep -q "oh-my-zsh.sh" "$HOME/.zshrc" 2>/dev/null; then
  echo "Looks like ~/.zshrc isn't the standard oh-my-zsh one. Skipping auto-edit."
  exit 0
fi

# Set plugins
sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-z fzf fzf-tab)/' "$HOME/.zshrc"

# Make zsh default shell
if [ "$SHELL" != "$(command -v zsh)" ]; then
  chsh -s "$(command -v zsh)"
  echo "Default shell changed to zsh."
fi

echo "Tip: run 'exec zsh' in this terminal to start using it immediately."
