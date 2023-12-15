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

if [ $machine == "Linux" ]; then
	echo "install nvim"
	bash ~/.local/dotfiles/setup_ubuntu2204.sh
    sudo chsh -s $(which zsh)
fi

# source init.sh
sed -i "\:$LOCAL_ETC/init.sh:d" ~/.bashrc
echo ". $LOCAL_ETC/init.sh" >>~/.bashrc
. ~/.bashrc

# source vimrc.vim
# touch ~/.vimrc
# sed -i "\:$LOCAL_ETC/vimrc.vim:d" ~/.vimrc
# echo "source $LOCAL_ETC/vimrc.vim" >>~/.vimrc

mkdir -p ~/.tmux/resurrect
if [ ! -d ~/.tmux/plugins/tpm ]; then
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
# source tmux.conf
touch ~/.tmux.conf
sed -i "\:$LOCAL_ETC/tmux.conf:d" ~/.tmux.conf
echo "source $LOCAL_ETC/tmux.conf" >>~/.tmux.conf

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

# install vim plug
# vim_version=$(\vim --version | head -1)
# if [[ $(echo $vim_version | awk -F '[ .]' '{print $5}') -gt 7 ]]; then
# 	\vim +PlugInstall +qall
# fi

# install wezterm
# rm -rf ~/.config/wezterm
# mkdir -p ~/.config
# ln -s $LOCAL_ETC/wezterm ~/.config/wezterm

# install stylua config
# rm -rf ~/.config/stylua
# ln -s $LOCAL_ETC/stylua ~/.config/stylua
