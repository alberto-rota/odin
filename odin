#!/bin/sh
# Odin CLI - Management tool for Odin setup

VERSION="1.0.0"

show_installed() {
    cat <<'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Installed Tools & Features
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  📦 oh-my-posh
     A prompt theme engine for your shell
     → Automatically activated in new shells
     → Theme: pata-odin-shell.omp.json
     → Customize: Edit ~/.cache/oh-my-posh/themes/pata-odin-shell.omp.json

  🎨 MOTD (Message of the Day)
     Custom welcome message displayed on login
     → Automatically shown when opening a new terminal
     → Location: /etc/motd

  🪟 tmux
     Terminal multiplexer for managing multiple sessions
     → Start: tmux
     → Attach: tmux attach or tma <session-name>
     → List: tml
     → Create: tmc <name>
     → Config: ~/.tmux.conf

  🔍 fzf (Fuzzy Finder)
     Fast fuzzy finder for files and commands
     → Command history: Ctrl+R
     → File search: fzf
     → Completion: Automatically configured in ~/.fzf.bash

  📁 zoxide
     Smart directory jumper (smarter cd)
     → Use: z <directory-name> or just z
     → Jump to frequent directories automatically
     → Example: z projects (jumps to most used "projects" directory)

  📋 eza
     Modern replacement for ls with better defaults
     → Use: ls (aliased to eza)
     → Features: Tree view, git status, icons
     → Example: ls (shows tree with git status)

  🔎 ripgrep (rg)
     Fast text search tool
     → Use: rg <pattern> [path]
     → Example: rg "function" src/
     → Faster than grep, respects .gitignore

  📂 fd
     Simple and fast alternative to find
     → Use: fd <pattern> [path]
     → Example: fd "*.py" src/
     → Faster than find, respects .gitignore

  🐍 uv
     Fast Python package installer and resolver
     → Use: uv pip install <package>
     → Example: uv pip install requests
     → Much faster than pip

  ⚙️  Custom Functions & Aliases
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

show_help() {
    cat <<EOF
Odin CLI v${VERSION}

Usage: odin [command]

Commands:
  --installed, -i    Show list of installed tools and features
  --help, -h         Show this help message
  --version, -v      Show version information

Examples:
  odin --installed   List all installed tools
  odin -i            Short form
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

