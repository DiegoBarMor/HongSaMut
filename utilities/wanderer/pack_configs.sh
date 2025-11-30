#!/bin/bash
set -eu

ROOT=$(dirname "$(realpath "$0")")
FOLDER_CONFIGS="$ROOT/configs"

rm   -rf "$FOLDER_CONFIGS"
mkdir -p "$FOLDER_CONFIGS"

echo "Packing configurations into $FOLDER_CONFIGS"


### PACKUP MICRO
mkdir -p "$FOLDER_CONFIGS/.config"
cp -r ~/.config/micro "$FOLDER_CONFIGS/.config/micro"


### PACKUP TMUX
cp ~/.tmux.conf "$FOLDER_CONFIGS/"


### PACKUP HONGSAMUT AND BASH CUSTOMIZATIONS
cp -r ~/.hongsamut "$FOLDER_CONFIGS/.hongsamut"
if [[ -f ~/.bash_extra ]]; then
    cp -r ~/.bash_extra "$FOLDER_CONFIGS/.bash_extra"
fi
cp ~/.bashrc "$FOLDER_CONFIGS/" # just for backup, won't be deployed


### SAVE TIMESTAMP
ts="$(date +%Y%m%d_%H%M%S)"
echo "$ts" > "$FOLDER_CONFIGS/time_packed.txt"
