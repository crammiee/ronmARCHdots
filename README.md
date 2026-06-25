# ronmARCHdots

Dotfiles managed with a bare git repo. Files live in `$HOME` directly — no symlinks, no moving things around.

## Setup on a new machine

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/crammiee/ronmARCHdots/main/install.sh)"
```

Then add the `dots` alias to your shell and reload:

```bash
alias dots='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

## Daily usage

```bash
dots status
dots add ~/.zshrc
dots commit -m "update zsh config"
dots push
```

## What's included

| File | Description |
| --- | --- |
| `.zshrc` | Zsh config |
| `.gitconfig` | Git config |
| `.config/hypr/hyprland.conf` | Hyprland config |
