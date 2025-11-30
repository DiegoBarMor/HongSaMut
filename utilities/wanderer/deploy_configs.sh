#!/bin/bash
set -eu

ROOT=$(dirname "$(realpath "$0")")
FOLDER_CONFIGS="$ROOT/configs"

### SETUP MICRO
echo "Deploying micro editor configuration"
rm -rf ~/.config/micro
cp -r  "$FOLDER_CONFIGS/.config/micro" ~/.config/micro

### SETUP TMUX
echo "Deploying tmux configuration and plugins"
rm -rf ~/.tmux*
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp "$FOLDER_CONFIGS/.tmux.conf" ~/
cd ~/.tmux/plugins/tpm/scripts && ./install_plugins.sh
cd "$FOLDER_CONFIGS"

### SETUP OTHERS
echo "Deploying .bash_aliases and .bash_functions"
rm -f ~/.bash_aliases ~/.bash_functions
cp    "$FOLDER_CONFIGS/.bash_aliases"   ~/
cp    "$FOLDER_CONFIGS/.bash_functions" ~/
