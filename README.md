# Odin Setup and CLI

Update and Upgrade the system to the newest stable tools and versions. This also installs **curl**.
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl
```

Copy-paste this command into the terminal. It downloads a script from this repo and executes it. 
```bash
curl -fsSL https://raw.githubusercontent.com/alberto-rota/odin/master/setup.sh | sh
```
The script installs several CLI / terminal tools you like, sets up your custom **tmux**, customizes your terminal and installs the **odin** CLI.

***

After the setup completes, activate all the new features by re-sourcing the bashrc with this line
```bash
source ~/.bashrc
```

Use 
```bash
tmux
```
to start a new **tmux** session, rr use your custom interactive tmux session manager:
```bash
tmx
```
***

## The odin CLI
Just type 
```bash
odin --help
```
to see what you can do.
