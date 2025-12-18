fork form https://github.com/hanxi/dotfiles


# edenz223's dotfiles

bash + tmux + neovim

## Installation

### Linux

```bash
curl https://raw.githubusercontent.com/edenz223/dotfiles/master/bootstrap.sh | bash
```

Or:

```bash
wget -O - https://raw.githubusercontent.com/edenz223/dotfiles/master/bootstrap.sh | bash
```

> The bootstrap script clones this repo under `~/.local/dotfiles`, copies the `etc/` and `bin/` content into `~/.local`, installs tmux plugins, and runs `setup_ubuntu2204.sh` on apt-based Linux hosts. The Ubuntu script installs packages (zsh/tmux/neovim/etc.), configures oh-my-zsh, pulls a Neovim config, and installs helper binaries such as ripgrep, git-delta, gdu, and lazygit. It also changes your login shell to zsh and sources the provided init file from `~/.zshrc`.

### Standalone zsh setup

You can run only the zsh environment setup (oh-my-zsh, plugins, default shell) with:

```bash
curl https://raw.githubusercontent.com/edenz223/dotfiles/master/setup_zsh.sh | bash
```

### Add Public key:
```bash
curl https://raw.githubusercontent.com/edenz223/dotfiles/master/deploy_ssh_key.sh | bash
```

To decrypt and install the private key bundle you must pass `-p` to the script (Bash needs `-s --` to forward arguments when reading from stdin):

```bash
curl https://raw.githubusercontent.com/edenz223/dotfiles/master/deploy_ssh_key.sh | bash -s -- -p
```
