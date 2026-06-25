# ronmARCHdots

Dotfiles managed with a bare git repo. Files live in `$HOME` directly — no symlinks, no moving things around. Meta-files (`README.md`, `install.sh`, `uninstall.sh`) are excluded from checkout and won't appear in your home directory.

## Setup on a new machine

Requires SSH access to GitHub. If you haven't set that up, see [GitHub's SSH guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh).

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/crammiee/ronmARCHdots/main/install.sh)"
```

Then add the `dots` alias to your shell config and reload:

```bash
alias dots='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

## Uninstall

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/crammiee/ronmARCHdots/main/uninstall.sh)"
```

Removes `~/.dotfiles` and all tracked dotfiles. Optionally restores any files that were backed up during install.

## Daily usage

```bash
dots status
dots add ~/.zshrc
dots commit -m "update zsh config"
dots push
```


