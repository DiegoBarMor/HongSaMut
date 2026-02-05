#!/bin/bash
set -eu

ROOT=$(dirname "$(realpath "$0")")

### INSTALL BASIC STUFF
sudo apt install git gcc clang make cmake
sudo apt install tree htop btop
sudo apt install micro tmux lynx
sudo apt install vlc pandoc

### CLONE REPOSITORIES
if [[ ! -e ~/.tmux/plugins/tpm ]]; then
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
# git clone https://github.com/DiegoBarMor/HongSaMut ~/.hongsamut


### DEPLOY SSH
mkdir -p ~/.ssh
cp "$ROOT/kwamlap/ssh/config" ~/.ssh/
cp "$ROOT/kwamlap/ssh/diegobm" ~/.ssh/
cp "$ROOT/kwamlap/ssh/diegobm.pub" ~/.ssh/
chmod 600 ~/.ssh/diegobm
chmod 600 ~/.ssh/diegobm.pub


### DEPLOY CONFIGS
bindle_local=~/Desktop/bindle
kwamlap=~/.kwamlap

if [[ "$bindle_local" != "$ROOT" ]]; then
	rm -rf "$bindle_local"
	cp -r "$ROOT/../"      "$bindle_local"
fi

rm -rf "$kwamlap"
cp -r "$ROOT/kwamlap"  "$kwamlap"

./deploy_configs.sh
