#!/bin/bash
set -euo pipefail

if [ ! -d install_hsm ]; then
    echo "This script must be run from the root of the repository."
    exit 1
fi
if [ ! -d ../HongSaMut ]; then
    echo "No directory named 'HongSaMut' found in the parent directory."
    exit 1
fi
if [ ! -d ../Templates ]; then
    echo "No directory named 'Templates' found in the parent directory."
    exit 1
fi

rm -rf ~/.hongsamut

cp -r ../HongSaMut ~/.hongsamut
cp -r ../Templates ~/.hongsamut/plugins/templates

date "+%Y%m%d_%H%M%S" > ~/.hongsamut/time_installed.txt
