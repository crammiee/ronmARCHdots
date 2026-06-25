#!/usr/bin/env bash
set -e

DOTFILES="$HOME/.dotfiles"
BACKUP="$HOME/.dotfiles-backup"

read -rp "This will remove ~/.dotfiles and all tracked dotfiles. Continue? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

dots() { git --git-dir="$DOTFILES/" --work-tree="$HOME" "$@"; }

if [ -d "$DOTFILES" ]; then
    dots ls-files | while read -r f; do
        rm -f "$HOME/$f"
    done
    rm -rf "$DOTFILES"
    echo "Removed ~/.dotfiles and tracked files."
else
    echo "~/.dotfiles not found, nothing to remove."
fi

if [ -d "$BACKUP" ]; then
    read -rp "Restore backed-up files from $BACKUP? [y/N] " restore
    if [[ "$restore" =~ ^[Yy]$ ]]; then
        cp -r "$BACKUP/." "$HOME/"
        echo "Restored files from backup."
    fi
fi

echo "Done. You may want to remove the dots alias from your shell config."
