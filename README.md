# Odin Setup

## Prerequisites

Before running the setup script, make sure to update your system and install curl:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl
```

## Installation

Run the following command to set up your shell environment:

```bash
curl -fsSL https://raw.githubusercontent.com/alberto-rota/odin/master/setup.sh | sh
```

This will install:
- Custom MOTD (message of the day)
- oh-my-posh with custom theme
- tmux with custom configuration
- Custom bash functions and aliases