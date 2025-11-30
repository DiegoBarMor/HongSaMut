#!/bin/bash
set -eu

ROOT=$(dirname "$(realpath "$0")")

### INSTALL BASIC STUFF
sudo apt install git make cmake
sudo apt install tree htop btop
sudo apt install micro tmux
sudo apt install vlc


### DEPLOY SSH
mkdir -p ~/.ssh
cp "$ROOT/kwamlap/ssh/config" ~/.ssh/
cp "$ROOT/kwamlap/ssh/diegobm" ~/.ssh/
cp "$ROOT/kwamlap/ssh/diegobm.pub" ~/.ssh/
chmod 600 ~/.ssh/diegobm
chmod 600 ~/.ssh/diegobm.pub


### DEPLOY CONFIGS
bindle_local=~/Desktop/bindle
hongsamut=~/.hongsamut
kwamlap=~/.kwamlap

rm -rf "$bindle_local" "$hongsamut" "$kwamlap"
cp -r "$ROOT/../"       "$bindle_local"
cp -r "$ROOT/kwamlap"   "$kwamlap"
cp -r "$ROOT/hongsamut" "$hongsamut"

./deploy_configs.sh
