# for .local lib
export LD_RUN_PATH=$HOME/.local/lib:$LD_RUN_PATH
export LD_LIBRARY_PATH=$HOME/.local/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$HOME/.local/lib/pkgconfig:$PKG_CONFIG_PATH

# for http proxy
# export proxy_addr=
# export HTTPS_PROXY=$proxy_addr
# export http_proxy=$proxy_addr
# export https_proxy=$proxy_addr
# export FTP_PROXY=$proxy_addr
# export RSYNC_PROXY=$proxy_addr
# export ALL_PROXY=$proxy_addr

# alias proxyon="setproxy on; . ~/.local/etc/config.sh"
# alias proxyoff="setproxy off; . ~/.local/etc/config.sh"

# editor
if command -v nvim >/dev/null 2>&1; then
	alias vim=nvim
	export VISUAL=nvim
else
	export VISUAL=vim
fi
export EDITOR="$VISUAL"

export HISTTIMEFORMAT="%d/%m/%y %T "

# Alias for tree view of commit history.
git config --global alias.tree "log --all --graph --decorate=short --color --format=format:'%C(bold blue)%h%C(reset) %C(auto)%d%C(reset)\n         %C(blink yellow)[%cr]%C(reset)  %x09%C(white)%an: %s %C(reset)'"

# set pwd for tmux
function set_tmux_pwd() {
	[ -n "$TMUX" ] && tmux setenv TMUXPWD_$(tmux display -p "#D" | tr -d %) "$PWD"
	return 0
}
function my_cd() {
	\cd $1
	set_tmux_pwd
}
set_tmux_pwd
alias cd=my_cd

alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'
alias dc='docker-compose'
alias dcr='docker-compose down && docker-compose up -d'
