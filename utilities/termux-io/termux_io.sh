#!/bin/bash

this_root="$(pwd)"
folder_io=$(echo $0 | cut -d'/' -f 1)
termux_root="/data/data/com.termux/files/home"
do_backup_when_unpacking=true

# Function to display usage
usage() {
    echo "Usage: termux_io.sh [OPTION]"
    echo "Options:"
    echo "  -p, --pack      Pack the input folders into a tar.gz file"
    echo "  -u, --unpack    Unpack the most recent tar.gz file into the output root"
    echo "  --no-bak        Do not backup the current input folders when unpacking"
    echo "  -h, --help      Display this help and exit"
}

# Check for mandatory flag
if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -p|--pack)
            operation="pack"
            shift
            ;;
        -u|--unpack)
            operation="unpack"
            shift
            ;;
        --no-bak)
            do_backup_when_unpacking=false
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

# Set folder paths based on environment
if [[ "$this_root" == "$termux_root" ]]; then
    folder_io="$this_root/storage/shared/TermuxIO"
else
    folder_io="$this_root/TermuxIO"
fi

mkdir -p $folder_io
this_root="$termux_root/.termux/.."
path_current="$this_root/current_termux.txt"

ts="$(date +%Y%m%d_%H%M%S)"
paths_to_backup="$this_root/Desktop $this_root/.config $this_root/.termux"

# Perform the selected operation
if [[ "$operation" == "pack" ]]; then
    path_tar="$folder_io/$ts.tar.gz"
    echo "$ts" > "$path_current"

    echo "Packing to $path_tar"
    tar -czf "$path_tar" $paths_to_backup

elif [[ "$operation" == "unpack" ]]; then
    name_tar=$(ls -v "$folder_io" | grep -E "^[0-9]{8}_[0-9]{6}\.tar\.gz$" | tail -n 1) # find the most recent tar.gz file with the specific naming convention (timestamp)
    echo "$name_tar" > "$path_current"

    if [[ $do_backup_when_unpacking == true ]]; then
        path_tar_bak="$folder_io/$ts.tar.gz.bak"
        echo "Backing up to $path_tar_bak"
        tar -czf "$path_tar_bak" $paths_to_backup
    fi

    path_tar="$folder_io/$name_tar"

    echo "Unpacking from $path_tar"
    tar -xzf "$path_tar" -C "$this_root"
fi
