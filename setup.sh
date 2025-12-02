#!/bin/sh
set -eu

# ---------------------------------------------------------
# Config – URLs for downloading files from GitHub
# ---------------------------------------------------------
: "${REPO_URL:=https://raw.githubusercontent.com/alberto-rota/odin/master}"
: "${OMP_THEME_URL:=$REPO_URL/pata-odin-shell.omp.json}"
: "${BASHRC_FUNCTIONS_URL:=$REPO_URL/bashrc-functions.sh}"
: "${TMUXCONF_URL:=$REPO_URL/.tmux.conf}"
: "${MOTD_URL:=$REPO_URL/motd.txt}"

THEME_NAME="pata-odin-shell.omp.json"
THEME_DIR="$HOME/.cache/oh-my-posh/themes"
THEME_PATH="$THEME_DIR/$THEME_NAME"

BASHRC="$HOME/.bashrc"  
PROFILE="$HOME/.profile"
TMUXCONF="$HOME/.tmux.conf"
MOTD="/etc/motd"
BASHRC_FUNCTIONS="$HOME/.bashrc-functions.sh"

# ---------------------------------------------------------
# Helpers
# ---------------------------------------------------------
backup_file() {
    file="$1"
    if [ -f "$file" ] && [ ! -f "$file.bak" ]; then
        cp "$file" "$file.bak"
        echo "Backed up $file -> $file.bak"
    fi
}

ensure_line_in_file() {
    line="$1"
    file="$2"
    # Append line only if it's not already present
    if ! grep -Fq "$line" "$file" 2>/dev/null; then
        printf "%s\n" "$line" >> "$file"
    fi
}

# ---------------------------------------------------------
# 1. Install oh-my-posh
# ---------------------------------------------------------
echo "Checking for oh-my-posh..."
if ! command -v oh-my-posh >/dev/null 2>&1; then
    echo "Installing oh-my-posh..."
    OMP_VERSION="v19.7.0"
    OMP_INSTALL_DIR="/usr/local/bin"
    
    # Detect architecture
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)
            OMP_BINARY="posh-linux-amd64"
            ;;
        aarch64|arm64)
            OMP_BINARY="posh-linux-arm64"
            ;;
        armv7l|armv6l)
            OMP_BINARY="posh-linux-arm"
            ;;
        *)
            echo "WARNING: Unsupported architecture: $ARCH"
            echo "         Attempting to use amd64 binary..."
            OMP_BINARY="posh-linux-amd64"
            ;;
    esac
    
    if command -v curl >/dev/null 2>&1; then
        TMP_BINARY=$(mktemp)
        if curl -fsSL "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/${OMP_VERSION}/${OMP_BINARY}" -o "$TMP_BINARY"; then
            sudo mv "$TMP_BINARY" "$OMP_INSTALL_DIR/oh-my-posh"
            sudo chmod +x "$OMP_INSTALL_DIR/oh-my-posh"
            echo "oh-my-posh installed to $OMP_INSTALL_DIR/oh-my-posh (architecture: $ARCH)"
        else
            rm -f "$TMP_BINARY"
            echo "WARNING: Failed to download oh-my-posh. Please install manually."
        fi
    else
        echo "WARNING: curl not found; cannot download oh-my-posh."
    fi
else
    echo "oh-my-posh already installed."
fi

# ---------------------------------------------------------
# 2. Install oh-my-posh theme
# ---------------------------------------------------------
echo "Installing oh-my-posh theme to: $THEME_PATH"
mkdir -p "$THEME_DIR"
if command -v curl >/dev/null 2>&1; then
    if ! curl -fsSL "$OMP_THEME_URL" -o "$THEME_PATH"; then
        echo "WARNING: Failed to download theme from:"
        echo "         $OMP_THEME_URL"
        echo "         You may need to place $THEME_NAME manually in $THEME_DIR"
    else
        echo "Theme installed successfully."
    fi
else
    echo "WARNING: curl not found; cannot download theme."
fi

# ---------------------------------------------------------
# 3. Install MOTD
# ---------------------------------------------------------
echo "Installing MOTD..."
if command -v curl >/dev/null 2>&1; then
    if curl -fsSL "$MOTD_URL" | sudo tee "$MOTD" >/dev/null; then
        echo "MOTD installed successfully."
    else
        echo "WARNING: Failed to download or install MOTD from: $MOTD_URL"
    fi
else
    echo "WARNING: curl not found; cannot download MOTD."
fi

# ---------------------------------------------------------
# 4. Install tmux and configure
# ---------------------------------------------------------
echo "Checking for tmux..."
if ! command -v tmux >/dev/null 2>&1; then
    echo "Installing tmux..."
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y tmux
        echo "tmux installed successfully."
    else
        echo "WARNING: apt-get not found. Please install tmux manually."
    fi
else
    echo "tmux already installed."
fi

# Install .tmux.conf
backup_file "$TMUXCONF"
if command -v curl >/dev/null 2>&1; then
    if curl -fsSL "$TMUXCONF_URL" -o "$TMUXCONF"; then
        echo "tmux configuration installed successfully."
    else
        echo "WARNING: Failed to download .tmux.conf from: $TMUXCONF_URL"
    fi
else
    echo "WARNING: curl not found; cannot download .tmux.conf."
fi

# ---------------------------------------------------------
# 5. Install bashrc functions script
# ---------------------------------------------------------
backup_file "$BASHRC_FUNCTIONS"
if command -v curl >/dev/null 2>&1; then
    if curl -fsSL "$BASHRC_FUNCTIONS_URL" -o "$BASHRC_FUNCTIONS"; then
        echo "bashrc functions script installed successfully."
    else
        echo "WARNING: Failed to download bashrc-functions.sh from: $BASHRC_FUNCTIONS_URL"
    fi
else
    echo "WARNING: curl not found; cannot download bashrc-functions.sh."
fi

# ---------------------------------------------------------
# 6. Update ~/.bashrc to source the functions script
# ---------------------------------------------------------
backup_file "$BASHRC"

# Create file if missing
[ -f "$BASHRC" ] || : > "$BASHRC"

if ! grep -Fq ">>> BEGIN_ALBERTO_BASHRC >>>" "$BASHRC"; then
    cat <<EOF >> "$BASHRC"

# >>> BEGIN_ALBERTO_BASHRC >>>
# Source custom functions and aliases
if [ -f "$BASHRC_FUNCTIONS" ]; then
    . "$BASHRC_FUNCTIONS"
fi
# <<< END_ALBERTO_BASHRC <<<
EOF
    echo "Updated $BASHRC to source bashrc-functions.sh"
else
    echo "Custom block already present in $BASHRC – skipping."
fi

# ---------------------------------------------------------
# 7. Update ~/.profile (ensure it sources ~/.bashrc)
# ---------------------------------------------------------
backup_file "$PROFILE"

if [ -f "$PROFILE" ]; then
    if ! grep -Fq '. "$HOME/.bashrc"' "$PROFILE" && \
       ! grep -Fq 'source "$HOME/.bashrc"' "$PROFILE" && \
       ! grep -Fq '. ~/.bashrc' "$PROFILE"
    then
        cat <<'EOF' >> "$PROFILE"

# Load bash configuration if present
if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
EOF
        echo "Updated $PROFILE to source ~/.bashrc"
    else
        echo "$PROFILE already sources ~/.bashrc – skipping."
    fi
else
    cat <<'EOF' > "$PROFILE"
# ~/.profile

# Load bash configuration if present
if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
EOF
    echo "Created $PROFILE"
fi

echo
echo "Done."
echo "Backups (if any) are in:"
echo "  $BASHRC.bak"
echo "  $PROFILE.bak"
echo "  $TMUXCONF.bak"
echo "  $BASHRC_FUNCTIONS.bak"
echo
echo "Open a new shell or run:  source \"$BASHRC\""
