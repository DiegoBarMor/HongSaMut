#!/bin/bash
set -euo pipefail

##### TODO: review this utility

if [[ $# -eq 0 ]]; then
  echo "No arguments supplied, exiting..."
  exit 1
fi

folder_root_in=$1  # e.g. /mnt/c
folder_root_out=$2 # e.g. /mnt/d/backup
path_folders_list=$3 # e.g. folders/example.txt

### Remove trailing slash from paths (if they exist)
folder_root_in=${folder_root_in%/}
folder_root_out=${folder_root_out%/}

### Check if paths exist and are directories
if [[ ! -d "$folder_root_in" ]]; then
  echo "The input root path $folder_root_in does not exist or is not a directory, exiting..."
  exit 1
fi
if [[ ! -d "$folder_root_out" ]]; then
  echo "The output root path $folder_root_out does not exist or is not a directory, exiting..."
  exit 1
fi

### Create a folder with today's date
folder_out=$folder_root_out/$(date +%Y%m%d)
mkdir -p "$folder_out"

while read foldername; do
    path_in="$folder_root_in/$foldername"
    path_out="$folder_out/$foldername.tar.gz"

    ### Skip if path_in is not a directory
    if [[ ! -d "$path_in" ]]; then
      echo "Skipping $path_in as it is not a directory"
      continue
    fi

    ### Remove the last folder from the path if '/' is in the string
    if [[ "$foldername" == */* ]]; then
        parent=$(echo "$foldername" | rev | cut -d'/' -f2- | rev)
        mkdir -p "$folder_out/$parent" # create parent directories if they don't exist
    fi

    echo "Backing up $path_in to $path_out"
    tar -czvf "$path_out" "$path_in"

done < "$path_folders_list"
