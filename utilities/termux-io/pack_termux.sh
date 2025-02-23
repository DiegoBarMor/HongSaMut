#!/bin/bash
this_root="$(pwd)"
folder_io=$(echo $0 | cut -d'/' -f 1)
termux_root="/data/data/com.termux/files/home"

# -----------------------------------------------
if [[ "$this_root" == "$termux_root" ]]; then # runing inside termux
    folder_out="$this_root/storage/shared/TermuxIO"
else
    folder_out="$this_root/TermuxIO"
fi

mkdir -p $folder_out
this_root="$termux_root/.termux/.."
path_current="$this_root/current_termux.txt"

# -----------------------------------------------
ts="$(date +%Y%m%d_%H%M%S)"
echo "$ts" > "$path_current"

paths_in="$this_root/Desktop $this_root/.config $this_root/.termux"
path_out="$folder_out/$ts.tar.gz"

echo "Packing to $path_out"
tar -czf "$path_out" $paths_in

# -----------------------------------------------
