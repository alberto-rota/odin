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
: "${ODIN_CLI_URL:=$REPO_URL}"
: "${TMX_SCRIPT_URL:=$REPO_URL/bin/tmx}"

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
TOTAL_STEPS=16

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_step() {
    STEP_NUM=$((STEP_NUM + 1))
    STEP_NAME="$1"
    echo ""
    echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${BOLD}${WHITE}STEP ${BLUE}$STEP_NUM${WHITE}/${BLUE}$TOTAL_STEPS${WHITE}: ${CYAN}$STEP_NAME${NC}"
    echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo "${GREEN}✓${NC} ${GREEN}$1${NC}"
}

print_warning() {
    echo "${YELLOW}⚠ WARNING:${NC} ${YELLOW}$1${NC}"
}

print_error() {
    echo "${RED}✗ ERROR:${NC} ${RED}$1${NC}"
}

show_recap() {
    echo ""
    echo "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${BOLD}${WHITE}  Installation Complete!${NC}"
    echo "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    echo "${BOLD}${CYAN}Installed Tools:${NC}"
    echo "  ${GREEN}✓${NC} ${WHITE}oh-my-posh${NC} - Prompt theme engine"
    echo "  ${GREEN}✓${NC} ${WHITE}tmux${NC} - Terminal multiplexer"
    echo "  ${GREEN}✓${NC} ${WHITE}fzf${NC} - Fuzzy finder"
    echo "  ${GREEN}✓${NC} ${WHITE}zoxide${NC} - Smart directory jumper"
    echo "  ${GREEN}✓${NC} ${WHITE}eza${NC} - Modern ls replacement"
    echo "  ${GREEN}✓${NC} ${WHITE}ripgrep${NC} - Fast text search"
    echo "  ${GREEN}✓${NC} ${WHITE}fd${NC} - Fast file finder"
    echo "  ${GREEN}✓${NC} ${WHITE}uv${NC} - Fast Python package manager"
    echo "  ${GREEN}✓${NC} ${WHITE}tmx${NC} - Interactive tmux session manager"
    echo "  ${GREEN}✓${NC} ${WHITE}odin${NC} - Odin setup management CLI"
    echo ""
    
    echo "${BOLD}${CYAN}Configured Files:${NC}"
    echo "  ${GREEN}✓${NC} ${WHITE}~/.bashrc${NC} - Custom functions and aliases"
    echo "  ${GREEN}✓${NC} ${WHITE}~/.profile${NC} - Sources bashrc"
    echo "  ${GREEN}✓${NC} ${WHITE}~/.tmux.conf${NC} - Tmux configuration"
    echo "  ${GREEN}✓${NC} ${WHITE}~/.bashrc-functions.sh${NC} - Custom functions"
    echo "  ${GREEN}✓${NC} ${WHITE}/etc/motd${NC} - Message of the day"
    echo ""
    
    echo "${BOLD}${CYAN}Keyboard Shortcuts:${NC}"
    echo "  ${YELLOW}Ctrl+R${NC} - ${WHITE}Search command history with fzf${NC}"
    echo "  ${YELLOW}↑/↓${NC} - ${WHITE}History search (backward/forward)${NC}"
    echo ""
    
    echo "${BOLD}${CYAN}Aliases:${NC}"
    echo "  ${MAGENTA}bashrc${NC} - ${WHITE}Edit ~/.bashrc${NC}"
    echo "  ${MAGENTA}rebash${NC} - ${WHITE}Reload ~/.bashrc${NC}"
    echo "  ${MAGENTA}cda${NC} - ${WHITE}Deactivate conda${NC}"
    echo "  ${MAGENTA}dspace${NC} - ${WHITE}Show large directories (>1GB)${NC}"
    echo "  ${MAGENTA}wbr${NC} - ${WHITE}Kill wandb service${NC}"
    echo "  ${MAGENTA}wbclean${NC} - ${WHITE}Clean wandb cache${NC}"
    echo "  ${MAGENTA}jn${NC} - ${WHITE}Start Jupyter notebook on port 33433${NC}"
    echo "  ${MAGENTA}ls${NC} - ${WHITE}Enhanced with eza (tree, git, icons)${NC}"
    echo ""
    
    echo "${BOLD}${CYAN}Commands:${NC}"
    echo "  ${MAGENTA}tmx${NC} - ${WHITE}Interactive tmux session manager${NC}"
    echo "  ${MAGENTA}tma <name>${NC} - ${WHITE}Attach to tmux session${NC}"
    echo "  ${MAGENTA}tml${NC} - ${WHITE}List tmux sessions${NC}"
    echo "  ${MAGENTA}tmc <name>${NC} - ${WHITE}Create new tmux session${NC}"
    echo "  ${MAGENTA}z <dir>${NC} - ${WHITE}Jump to directory with zoxide${NC}"
    echo "  ${MAGENTA}rg <pattern>${NC} - ${WHITE}Search text with ripgrep${NC}"
    echo "  ${MAGENTA}fd <pattern>${NC} - ${WHITE}Find files with fd${NC}"
    echo "  ${MAGENTA}odin --installed${NC} - ${WHITE}Show all installed tools${NC}"
    echo ""
    
    echo "${BOLD}${YELLOW}Next Steps:${NC}"
    echo "  ${WHITE}1.${NC} Run: ${CYAN}source ~/.bashrc${NC} to activate all features"
    echo "  ${WHITE}2.${NC} Open a new terminal to see the custom MOTD"
    echo "  ${WHITE}3.${NC} Try: ${CYAN}tmx${NC} to manage tmux sessions interactively"
    echo "  ${WHITE}4.${NC} Try: ${CYAN}odin --installed${NC} to see all tools"
    echo ""
    
    echo "${BOLD}${BLUE}Tips:${NC}"
    echo "  ${WHITE}•${NC} Use ${CYAN}Ctrl+R${NC} to search your command history"
    echo "  ${WHITE}•${NC} Use ${CYAN}z <dir>${NC} to quickly jump to frequently used directories"
    echo "  ${WHITE}•${NC} Use ${CYAN}tmx${NC} for an interactive tmux session picker"
    echo "  ${WHITE}•${NC} Run ${CYAN}odin --update${NC} to update all tools and configurations"
    echo ""
    
    echo "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "${BOLD}Backups (if any) are in:${NC}"
    echo "  ${WHITE}$BASHRC.bak${NC}"
    echo "  ${WHITE}$PROFILE.bak${NC}"
    echo "  ${WHITE}$TMUXCONF.bak${NC}"
    echo "  ${WHITE}$BASHRC_FUNCTIONS.bak${NC}"
    echo ""
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
# 8. Install tmx script
# ---------------------------------------------------------
print_step "Installing tmx script"
TMX_SCRIPT_PATH="/usr/local/bin/tmx"
if command -v curl >/dev/null 2>&1; then
    TMP_TMX=$(mktemp)
    if curl -fsSL "$TMX_SCRIPT_URL" -o "$TMP_TMX"; then
        sudo mv "$TMP_TMX" "$TMX_SCRIPT_PATH"
        sudo chmod +x "$TMX_SCRIPT_PATH"
        print_success "tmx script installed to $TMX_SCRIPT_PATH"
    else
        rm -f "$TMP_TMX"
        print_error "Failed to download tmx script from: $TMX_SCRIPT_URL"
    fi
else
    print_error "curl not found; cannot download tmx script"
fi

# ---------------------------------------------------------
# 9. Install/Update Odin CLI (always updates)
# ---------------------------------------------------------
print_step "Installing/Updating Odin CLI"
ODIN_CLI_PATH="/usr/local/bin/odin"
if command -v curl >/dev/null 2>&1; then
    TMP_CLI=$(mktemp)
    if curl -fsSL "$ODIN_CLI_URL" -o "$TMP_CLI"; then
        # Remove old CLI if it exists
        if [ -f "$ODIN_CLI_PATH" ]; then
            sudo rm -f "$ODIN_CLI_PATH"
        fi
        # Install new CLI
        sudo mv "$TMP_CLI" "$ODIN_CLI_PATH"
        sudo chmod +x "$ODIN_CLI_PATH"
        if [ -f "$ODIN_CLI_PATH" ] && [ -x "$ODIN_CLI_PATH" ]; then
            print_success "Odin CLI installed/updated at $ODIN_CLI_PATH"
        else
            print_success "Odin CLI installed to $ODIN_CLI_PATH"
        fi
        print_success "Run 'odin --installed' to see all installed tools"
    else
        rm -f "$TMP_CLI"
        print_error "Failed to download Odin CLI from: $ODIN_CLI_URL"
    fi
else
    print_error "curl not found; cannot download Odin CLI"
fi

# ---------------------------------------------------------
# 10. Update ~/.bashrc to source the functions script
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
# 11. Update ~/.profile (ensure it sources ~/.bashrc)
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

show_recap