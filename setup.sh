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
STEP_NUM=0
TOTAL_STEPS=14

print_step() {
    STEP_NUM=$((STEP_NUM + 1))
    STEP_NAME="$1"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "STEP $STEP_NUM/$TOTAL_STEPS: $STEP_NAME"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

print_success() {
    echo "✓ $1"
}

print_warning() {
    echo "⚠ WARNING: $1"
}

print_error() {
    echo "✗ ERROR: $1"
}

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
print_step "Installing oh-my-posh"
if ! command -v oh-my-posh >/dev/null 2>&1; then
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
            print_success "oh-my-posh installed to $OMP_INSTALL_DIR/oh-my-posh (architecture: $ARCH)"
        else
            rm -f "$TMP_BINARY"
            print_error "Failed to download oh-my-posh. Please install manually."
        fi
    else
        print_error "curl not found; cannot download oh-my-posh."
    fi
else
    print_success "oh-my-posh already installed."
fi

# ---------------------------------------------------------
# 2. Install oh-my-posh theme
# ---------------------------------------------------------
print_step "Installing oh-my-posh theme"
mkdir -p "$THEME_DIR"
if command -v curl >/dev/null 2>&1; then
    if ! curl -fsSL "$OMP_THEME_URL" -o "$THEME_PATH"; then
        print_error "Failed to download theme from: $OMP_THEME_URL"
        echo "         You may need to place $THEME_NAME manually in $THEME_DIR"
    else
        print_success "Theme installed to $THEME_PATH"
    fi
else
    print_error "curl not found; cannot download theme."
fi

# ---------------------------------------------------------
# 3. Install MOTD
# ---------------------------------------------------------
print_step "Installing MOTD"
if command -v curl >/dev/null 2>&1; then
    if curl -fsSL "$MOTD_URL" | sudo tee "$MOTD" >/dev/null; then
        print_success "MOTD installed to $MOTD"
    else
        print_error "Failed to download or install MOTD from: $MOTD_URL"
    fi
else
    print_error "curl not found; cannot download MOTD."
fi

# ---------------------------------------------------------
# 4. Install tmux and configure
# ---------------------------------------------------------
print_step "Installing tmux"
if ! command -v tmux >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y tmux
        print_success "tmux installed successfully"
    else
        print_error "apt-get not found. Please install tmux manually."
    fi
else
    print_success "tmux already installed"
fi

print_step "Configuring tmux"
backup_file "$TMUXCONF"
if command -v curl >/dev/null 2>&1; then
    if curl -fsSL "$TMUXCONF_URL" -o "$TMUXCONF"; then
        print_success "tmux configuration installed to $TMUXCONF"
    else
        print_error "Failed to download .tmux.conf from: $TMUXCONF_URL"
    fi
else
    print_error "curl not found; cannot download .tmux.conf"
fi

# ---------------------------------------------------------
# 5. Install fzf, zoxide, and eza
# ---------------------------------------------------------
print_step "Installing fzf"
if ! command -v fzf >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get install -y fzf
        print_success "fzf installed successfully"
    else
        print_error "apt-get not found. Please install fzf manually."
    fi
else
    print_success "fzf already installed"
fi

# Set up fzf key bindings and fuzzy completion
if command -v fzf >/dev/null 2>&1; then
    if [ -f ~/.fzf.bash ]; then
        print_success "fzf completion already configured"
    else
        # Generate fzf completion file
        if fzf --bash > ~/.fzf.bash 2>/dev/null; then
            print_success "fzf completion configured"
        else
            print_warning "Could not generate fzf completion"
        fi
    fi
fi

print_step "Installing zoxide"
if ! command -v zoxide >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get install -y zoxide
        print_success "zoxide installed successfully"
    else
        print_error "apt-get not found. Please install zoxide manually."
    fi
else
    print_success "zoxide already installed"
fi

print_step "Installing eza"
if ! command -v eza >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get install -y eza
        print_success "eza installed successfully"
    else
        print_error "apt-get not found. Please install eza manually."
    fi
else
    print_success "eza already installed"
fi

print_step "Installing ripgrep"
if ! command -v rg >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get install -y ripgrep
        print_success "ripgrep installed successfully"
    else
        print_error "apt-get not found. Please install ripgrep manually."
    fi
else
    print_success "ripgrep already installed"
fi

print_step "Installing fd"
if ! command -v fd >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get install -y fd-find
        print_success "fd installed successfully"
    else
        print_error "apt-get not found. Please install fd manually."
    fi
else
    print_success "fd already installed"
fi

# ---------------------------------------------------------
# 6. Install uv python package manager
# ---------------------------------------------------------
print_step "Installing uv python package manager"
if ! command -v uv >/dev/null 2>&1; then
    if command -v curl >/dev/null 2>&1; then
        if curl -LsSf https://astral.sh/uv/install.sh | sh; then
            print_success "uv installed successfully"
            # Add uv to PATH (it installs to ~/.cargo/bin by default, or ~/.local/bin)
            UV_BIN_DIR="$HOME/.cargo/bin"
            if [ -d "$UV_BIN_DIR" ] && [ -f "$UV_BIN_DIR/uv" ]; then
                if ! echo "$PATH" | grep -q "$UV_BIN_DIR"; then
                    export PATH="$UV_BIN_DIR:$PATH"
                    ensure_line_in_file "export PATH=\"\$HOME/.cargo/bin:\$PATH\"" "$BASHRC"
                    print_success "Added $UV_BIN_DIR to PATH"
                fi
            fi
            # Also check ~/.local/bin as fallback
            UV_BIN_DIR_ALT="$HOME/.local/bin"
            if [ -d "$UV_BIN_DIR_ALT" ] && [ -f "$UV_BIN_DIR_ALT/uv" ]; then
                if ! echo "$PATH" | grep -q "$UV_BIN_DIR_ALT"; then
                    export PATH="$UV_BIN_DIR_ALT:$PATH"
                    ensure_line_in_file "export PATH=\"\$HOME/.local/bin:\$PATH\"" "$BASHRC"
                    print_success "Added $UV_BIN_DIR_ALT to PATH"
                fi
            fi
        else
            print_error "Failed to install uv. Please install manually."
        fi
    else
        print_error "curl not found; cannot install uv."
    fi
else
    print_success "uv already installed"
fi

# ---------------------------------------------------------
# 7. Install bashrc functions script
# ---------------------------------------------------------
print_step "Installing bashrc functions script"
backup_file "$BASHRC_FUNCTIONS"
if command -v curl >/dev/null 2>&1; then
    if curl -fsSL "$BASHRC_FUNCTIONS_URL" -o "$BASHRC_FUNCTIONS"; then
        print_success "bashrc functions script installed to $BASHRC_FUNCTIONS"
    else
        print_error "Failed to download bashrc-functions.sh from: $BASHRC_FUNCTIONS_URL"
    fi
else
    print_error "curl not found; cannot download bashrc-functions.sh"
fi

# ---------------------------------------------------------
# 8. Update ~/.bashrc to source the functions script
# ---------------------------------------------------------
print_step "Configuring ~/.bashrc"
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
    print_success "Updated $BASHRC to source bashrc-functions.sh"
else
    print_success "Custom block already present in $BASHRC"
fi

# ---------------------------------------------------------
# 9. Update ~/.profile (ensure it sources ~/.bashrc)
# ---------------------------------------------------------
print_step "Configuring ~/.profile"
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
        print_success "Updated $PROFILE to source ~/.bashrc"
    else
        print_success "$PROFILE already sources ~/.bashrc"
    fi
else
    cat <<'EOF' > "$PROFILE"
# ~/.profile

# Load bash configuration if present
if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
EOF
    print_success "Created $PROFILE"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Installation Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Backups (if any) are in:"
echo "  $BASHRC.bak"
echo "  $PROFILE.bak"
echo "  $TMUXCONF.bak"
echo "  $BASHRC_FUNCTIONS.bak"
echo ""
echo "Opening a new shell or running 'source ~/.bashrc' will apply all changes."
echo ""

