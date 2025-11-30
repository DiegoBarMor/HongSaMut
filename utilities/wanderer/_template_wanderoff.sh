#!/bin/bash
set -eu

ROOT=$(dirname "$(realpath "$0")")

### INSTALL BASIC STUFF
sudo apt install git make cmake
sudo apt install tree htop btop
sudo apt install micro tmux
sudo apt install vlc


### CLONE REPOSITORIES
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
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

rm -rf "$bindle_local" "$kwamlap"
cp -r "$ROOT/../"      "$bindle_local"
cp -r "$ROOT/kwamlap"  "$kwamlap"

./deploy_configs.sh
