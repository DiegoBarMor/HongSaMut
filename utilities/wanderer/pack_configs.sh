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

### PACKUP OTHERS
cp ~/.bash_aliases   "$FOLDER_CONFIGS/"
cp ~/.bash_functions "$FOLDER_CONFIGS/"

### BACKUP BASHRC
cp ~/.bashrc "$FOLDER_CONFIGS/"

### SAVE TIMESTAMP
ts="$(date +%Y%m%d_%H%M%S)"
echo "$ts" > "$FOLDER_CONFIGS/time_packed.txt"
