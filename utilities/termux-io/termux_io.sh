#!/bin/bash

this_root="$(pwd)"
folder_io=$(echo $0 | cut -d'/' -f 1)
termux_root="/data/data/com.termux/files/home"

# Function to display usage
usage() {
    echo "Usage: $0 [-p|--pack] [-u|--unpack]"
    exit 1
}

# Check for mandatory flag
if [[ $# -ne 1 ]]; then
    usage
fi

# Determine operation mode
case "$1" in
    -p|--pack)
        operation="pack"
        ;;
    -u|--unpack)
        operation="unpack"
        ;;
    *)
        usage
        ;;
esac

# Set folder paths based on environment
if [[ "$this_root" == "$termux_root" ]]; then
    folder_io="$this_root/storage/shared/TermuxIO"
else
    folder_io="$this_root/TermuxIO"
fi

mkdir -p $folder_io
this_root="$termux_root/.termux/.."
path_current="$this_root/current_termux.txt"

# Perform the selected operation
if [[ "$operation" == "pack" ]]; then
    ts="$(date +%Y%m%d_%H%M%S)"
    echo "$ts" > "$path_current"

    paths_in="$this_root/Desktop $this_root/.config $this_root/.termux"
    path_out="$folder_io/$ts.tar.gz"

    echo "Packing to $path_out"
    tar -czf "$path_out" $paths_in

elif [[ "$operation" == "unpack" ]]; then
    name_in=$(ls -v "$folder_io" | tail -n 1) # find the file with the highest numerical value i. e. most recent tar.gz
    echo "$name_in" > "$path_current"

    path_in="$folder_io/$name_in"
    path_out="$this_root"

    echo "Unpacking from $path_in"
    tar -xzf "$path_in" -C "$path_out"
fi
