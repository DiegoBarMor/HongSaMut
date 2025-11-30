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
rm -rf ~/.tmux.conf
cp "$FOLDER_CONFIGS/.tmux.conf" ~/
cd ~/.tmux/plugins/tpm/scripts && ./install_plugins.sh
cd "$FOLDER_CONFIGS"


### SETUP HONGSAMUT AND BASH CUSTOMIZATIONS
touch ~/.bashrc
if ! grep -q ".hongsamut/bash_additions.sh" ~/.bashrc; then
    echo -e "\nif [[ -f $HOME/.hongsamut/bash_additions.sh ]]; then . $HOME/.hongsamut/bash_additions.sh; fi" >> ~/.bashrc
fi

rm -f ~/.bash_extra
cp -r "$FOLDER_CONFIGS/.bash_extra"   ~/.bash_extra

echo "Deploying HongSaMut"
rm -rf ~/.hongsamut
cp -r "$FOLDER_CONFIGS/.hongsamut"   ~/.hongsamut
