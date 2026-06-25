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

# --- deps ---

install_pkg() {
    if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm "$@"
    elif command -v apt-get &>/dev/null; then
        sudo apt-get update -q && sudo apt-get install -y "$@"
    elif command -v brew &>/dev/null; then
        brew install "$@"
    else
        echo "Unsupported package manager. Install $* manually." && exit 1
    fi
}

if ! command -v zsh &>/dev/null; then
    echo "Installing zsh..."
    install_pkg zsh
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo "Installing powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
fi

# --- dotfiles ---

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
