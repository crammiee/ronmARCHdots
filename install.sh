#!/usr/bin/env bash
set -e

# Containers run as root without sudo
[ "$(id -u)" = "0" ] && sudo() { "$@"; }

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
    ZSH_PATH="$(which zsh)"
    if ! grep -qx "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi
    chsh -s "$ZSH_PATH"
fi

# --- packages ---

if command -v pacman &>/dev/null && [ -z "$SKIP_PACKAGES" ]; then
    if ! command -v whiptail &>/dev/null; then
        sudo pacman -S --needed --noconfirm libnewt
    fi

    CHOICES=$(whiptail --title "Package Installation" --checklist \
        "Space to toggle, Enter to confirm:" 28 72 17 \
        "base-devel"              "Build tools (gcc, make, etc.)"   ON  \
        "git"                     "Version control"                  ON  \
        "tmux"                    "Terminal multiplexer"             ON  \
        "vim"                     "Vi IMproved"                      ON  \
        "neovim"                  "Neovim"                           ON  \
        "docker"                  "Container runtime"                ON  \
        "docker-compose"          "Docker Compose"                   ON  \
        "nodejs"                  "Node.js runtime"                  ON  \
        "npm"                     "Node package manager"             ON  \
        "python"                  "Python 3"                         ON  \
        "python-pip"              "Python pip"                       ON  \
        "rustup"                  "Rust toolchain manager"           ON  \
        "ttf-jetbrains-mono-nerd" "JetBrains Mono Nerd Font"        ON  \
        "noto-fonts-emoji"        "Noto emoji fonts"                 ON  \
        "firefox"                 "Firefox browser"                  ON  \
        "rofi"                    "App launcher"                     ON  \
        "dunst"                   "Notification daemon"              ON  \
        3>&1 1>&2 2>&3) || true

    if [ -n "$CHOICES" ]; then
        if ! command -v paru &>/dev/null; then
            echo "Installing paru AUR helper..."
            sudo pacman -S --needed --noconfirm base-devel git
            PARU_TMP=$(mktemp -d)
            git clone https://aur.archlinux.org/paru.git "$PARU_TMP"
            (cd "$PARU_TMP" && makepkg -si --noconfirm)
            rm -rf "$PARU_TMP"
        fi

        for pkg in $CHOICES; do
            paru -S --needed --noconfirm "${pkg//\"/}"
        done

        if echo "$CHOICES" | grep -q '"docker"'; then
            sudo systemctl enable --now docker
            sudo usermod -aG docker "$USER"
            echo "Note: log out and back in for docker group to take effect."
        fi

        if echo "$CHOICES" | grep -q '"rustup"'; then
            rustup default stable
        fi
    else
        echo "No packages selected, skipping."
    fi
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
