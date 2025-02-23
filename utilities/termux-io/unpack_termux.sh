#!/bin/bash
this_root="$(pwd)"
folder_io=$(echo $0 | cut -d'/' -f 1)
termux_root="/data/data/com.termux/files/home"

# -----------------------------------------------
if [[ "$this_root" == "$termux_root" ]]; then # runing inside termux
    folder_in="$this_root/storage/shared/TermuxIO"
else
    folder_in="$this_root/TermuxIO"
fi

mkdir -p $folder_in
this_root="$termux_root/.termux/.."
path_current="$this_root/current_termux.txt"

# -----------------------------------------------
name_in=$(ls -v "$folder_in" | tail -n 1) # Find the file with the highest numerical value i. e. most recent tar.gz
echo "$name_in" > "$path_current"

path_in="$folder_in/$name_in" # Prepend the folder path to the file name
path_out="$this_root"

echo "Unpacking from $path_in"
tar -xzf "$path_in" -C "$path_out" # Extract the contents of the tar.gz file into the root directory

# -----------------------------------------------
