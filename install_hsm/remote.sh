#!/bin/bash
set -euo pipefail

rm -rf ~/.hongsamut

git clone https://github.com/DiegoBarMor/HongSaMut ~/.hongsamut
git clone https://github.com/DiegoBarMor/Templates ~/.hongsamut/plugins/templates

date "+%Y%m%d_%H%M%S" > ~/.hongsamut/time_installed.txt
