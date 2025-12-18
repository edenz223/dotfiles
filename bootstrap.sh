#! /usr/bin/env bash

set -e
set -x

unameOut="$(uname -s)"
case "${unameOut}" in
Linux*) machine=Linux ;;
Darwin*) machine=Mac ;;
CYGWIN*) machine=Cygwin ;;
MINGW*) machine=MinGw ;;
*) machine="UNKNOWN:${unameOut}" ;;
esac
echo ${machine}

LOCAL_ETC=~/.local/etc
LOCAL_BIN=~/.local/bin
mkdir -p $LOCAL_ETC
mkdir -p $LOCAL_BIN

# git clone respository
cd ~/.local/
if [ -d dotfiles ]; then
	cd dotfiles
	git pull
else
	git clone https://github.com/edenz223/dotfiles.git
	cd dotfiles
fi
cp -rf etc/* $LOCAL_ETC/
cp -rf bin/* $LOCAL_BIN/
cp bootstrap.sh $LOCAL_BIN/

if [ "$(uname -s)" == "Linux" ] && command -v apt >/dev/null; then
	bash ~/.local/dotfiles/setup_ubuntu2204.sh
fi

# source init.sh
sed -i "\:$LOCAL_ETC/init.sh:d" ~/.zshrc
echo ". $LOCAL_ETC/init.sh" >>~/.zshrc
zsh ~/.zshrc
chsh -s $(which zsh)


# source \tmp 
if [ ! -d ~/.tmux/plugins/tpm ]; then
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
mkdir -p ~/.tmux/resurrect
# source tmux.conf
touch ~/.tmux.conf
sed -i "\:$LOCAL_ETC/tmux.conf:d" ~/.tmux.conf
echo "source $LOCAL_ETC/tmux.conf" >>~/.tmux.conf

# install tmux plugins
if command -v tmux >/dev/null 2>&1 && [ -d ~/.tmux/plugins/tpm ]; then
	tmux new-session -d -s install_tmux_plugins
	tmux run-shell ~/.tmux/plugins/tpm/scripts/install_plugins.sh
	tmux kill-session -t install_tmux_plugins
else
	echo "Skipping tmux plugin install (tmux not available?)."
fi

# update git config
git config --global color.status auto
git config --global color.diff auto
git config --global color.branch auto
git config --global color.interactive auto
git config --global core.quotepath false
git config --global push.default simple
git config --global core.autocrlf false
git config --global core.ignorecase false
git config --global core.pager delta
git config --global interactive.diffFilter delta
git config --global add.interactive.useBuiltin false
git config --global delta.navigate true
git config --global delta.light false
git config --global delta.side-by-side true
git config --global merge.conflictstyle diff3
git config --global diff.colorMoved default


# install wezterm
# rm -rf ~/.config/wezterm
# mkdir -p ~/.config
# ln -s $LOCAL_ETC/wezterm ~/.config/wezterm

# install stylua config
# rm -rf ~/.config/stylua
# ln -s $LOCAL_ETC/stylua ~/.config/stylua
