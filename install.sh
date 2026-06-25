#!/usr/bin/env bash
set -e

if [ -n "$USE_HTTPS" ]; then
    REPO="https://github.com/crammiee/ronmARCHdots.git"
else
    REPO="git@github.com:crammiee/ronmARCHdots.git"
fi
DOTFILES="$HOME/.dotfiles"
BACKUP="$HOME/.dotfiles-backup"

if ! command -v git &>/dev/null; then
    echo "git is required but not installed."
    exit 1
fi

if [ -d "$DOTFILES" ]; then
    echo "$DOTFILES already exists, skipping clone."
else
    git clone --bare "$REPO" "$DOTFILES"
fi

dots() { git --git-dir="$DOTFILES/" --work-tree="$HOME" "$@"; }

dots config status.showUntrackedFiles no

# Exclude repo meta-files from being checked out to $HOME
dots config core.sparseCheckout true
{
    echo "/*"
    echo "!README.md"
    echo "!install.sh"
    echo "!uninstall.sh"
} > "$DOTFILES/info/sparse-checkout"

dots checkout 2>/dev/null || {
    echo "Backing up conflicting files to $BACKUP..."
    dots checkout 2>&1 | grep -E "^\s+" | awk '{print $1}' | while read -r f; do
        mkdir -p "$BACKUP/$(dirname "$f")"
        mv "$HOME/$f" "$BACKUP/$f"
    done
    dots checkout
}

echo "Done! Restart your shell or run: source ~/.zshrc"
