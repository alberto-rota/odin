#!/bin/sh
# Odin CLI - Management tool for Odin setup

VERSION="1.0.0"
REPO_URL="${ODIN_REPO_URL:-https://raw.githubusercontent.com/alberto-rota/odin/master}"
SETUP_SCRIPT_URL="$REPO_URL/setup.sh"
ODIN_CLI_URL="$REPO_URL/odin"
MOTD_URL="$REPO_URL/motd.txt"

show_installed() {
    cat <<'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Installed Tools & Features
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  oh-my-posh
     A prompt theme engine for your shell
     → Automatically activated in new shells
     → Theme: pata-odin-shell.omp.json
     → Customize: Edit ~/.cache/oh-my-posh/themes/pata-odin-shell.omp.json

  MOTD (Message of the Day)
     Custom welcome message displayed on login
     → Automatically shown when opening a new terminal
     → Location: /etc/motd

  tmux
     Terminal multiplexer for managing multiple sessions
     → Start: tmux
     → Attach: tmux attach or tma <session-name>
     → List: tml
     → Create: tmc <name>
     → Config: ~/.tmux.conf

  fzf (Fuzzy Finder)
     Fast fuzzy finder for files and commands
     → Command history: Ctrl+R
     → File search: fzf
     → Completion: Automatically configured in ~/.fzf.bash

  zoxide
     Smart directory jumper (smarter cd)
     → Use: z <directory-name> or just z
     → Jump to frequent directories automatically
     → Example: z projects (jumps to most used "projects" directory)

  eza
     Modern replacement for ls with better defaults
     → Use: ls (aliased to eza)
     → Features: Tree view, git status, icons
     → Example: ls (shows tree with git status)

  ripgrep (rg)
     Fast text search tool
     → Use: rg <pattern> [path]
     → Example: rg "function" src/
     → Faster than grep, respects .gitignore

  fd
     Simple and fast alternative to find
     → Use: fd <pattern> [path]
     → Example: fd "*.py" src/
     → Faster than find, respects .gitignore

  uv
     Fast Python package installer and resolver
     → Use: uv pip install <package>
     → Example: uv pip install requests
     → Much faster than pip

  tmx
     Interactive tmux session manager
     → Use: tmx
     → Interactive picker for tmux sessions
     → Create, attach, or switch between sessions

  Custom Functions & Aliases
     Personal productivity tools
     → bashrc: Edit ~/.bashrc
     → rebash: Reload ~/.bashrc
     → cda: Deactivate conda
     → dspace: Show large directories (>1GB)
     → wbr: Kill wandb service
     → wbclean: Clean wandb cache
     → jn: Start Jupyter notebook on port 33433

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
}

show_motd() {
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$MOTD_URL" 2>/dev/null || cat /etc/motd 2>/dev/null || echo "MOTD not available"
    else
        cat /etc/motd 2>/dev/null || echo "MOTD not available"
    fi
}

update_cli() {
    echo "Updating Odin CLI..."
    ODIN_CLI_PATH="/usr/local/bin/odin"
    
    if command -v curl >/dev/null 2>&1; then
        TMP_CLI=$(mktemp)
        if curl -fsSL "$ODIN_CLI_URL" -o "$TMP_CLI"; then
            # Remove old CLI if it exists
            if [ -f "$ODIN_CLI_PATH" ]; then
                if [ "$(id -u)" -eq 0 ]; then
                    rm -f "$ODIN_CLI_PATH"
                else
                    sudo rm -f "$ODIN_CLI_PATH"
                fi
            fi
            
            # Install new CLI
            if [ "$(id -u)" -eq 0 ]; then
                mv "$TMP_CLI" "$ODIN_CLI_PATH"
                chmod +x "$ODIN_CLI_PATH"
            else
                sudo mv "$TMP_CLI" "$ODIN_CLI_PATH"
                sudo chmod +x "$ODIN_CLI_PATH"
            fi
            
            if [ -f "$ODIN_CLI_PATH" ] && [ -x "$ODIN_CLI_PATH" ]; then
                echo "✓ Odin CLI updated successfully"
            else
                echo "ERROR: Failed to install updated CLI"
                exit 1
            fi
        else
            rm -f "$TMP_CLI"
            echo "ERROR: Failed to download Odin CLI from: $ODIN_CLI_URL"
            exit 1
        fi
    else
        echo "ERROR: curl not found; cannot update Odin CLI"
        exit 1
    fi
}

update_all() {
    echo "Updating all tools and configurations..."
    echo "Running setup script..."
    echo ""
    
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$SETUP_SCRIPT_URL" | sh
    else
        echo "ERROR: curl not found; cannot download setup script"
        exit 1
    fi
}

launch_gpu_monitor() {
    if ! command -v nvitop >/dev/null 2>&1; then
        echo "nvitop not found. Installing..."
        if command -v pip >/dev/null 2>&1; then
            pip install --user nvitop
        elif command -v pip3 >/dev/null 2>&1; then
            pip3 install --user nvitop
        elif command -v uv >/dev/null 2>&1; then
            uv pip install nvitop
        else
            echo "ERROR: No Python package manager found (pip, pip3, or uv)"
            echo "Please install nvitop manually: pip install nvitop"
            exit 1
        fi
        
        # Check if installation was successful
        if ! command -v nvitop >/dev/null 2>&1; then
            # Try to find it in user's local bin
            if [ -f "$HOME/.local/bin/nvitop" ]; then
                export PATH="$HOME/.local/bin:$PATH"
            else
                echo "ERROR: nvitop installation failed or not in PATH"
                echo "Please install manually: pip install nvitop"
                exit 1
            fi
        fi
    fi
    
    # Launch nvitop
    exec nvitop
}

show_help() {
    show_motd
    echo ""
    cat <<EOF
Odin CLI v${VERSION}

Usage: odin [command]

Commands:
  --installed, -i    Show list of installed tools and features
  --update           Re-run setup script to install/update all tools
  --update-cli       Update only the Odin CLI to latest version
  --gpu              Launch nvitop GPU monitoring tool
  --help, -h         Show this help message
  --version, -v      Show version information

Examples:
  odin --installed   List all installed tools
  odin -i            Short form
  odin --update      Update all tools and configurations
  odin --update-cli  Update only the CLI
  odin --gpu         Monitor GPU usage with nvitop

EOF
}

show_version() {
    echo "Odin CLI v${VERSION}"
}

# Main command handler
case "${1:-}" in
    --installed|-i)
        show_installed
        ;;
    --update)
        update_all
        ;;
    --update-cli)
        update_cli
        ;;
    --gpu)
        launch_gpu_monitor
        ;;
    --help|-h|"")
        show_help
        ;;
    --version|-v)
        show_version
        ;;
    *)
        echo "Unknown command: $1"
        echo "Run 'odin --help' for usage information."
        exit 1
        ;;
esac
