#!/bin/bash
termux_root="/data/data/com.termux/files/home"
this_root="$(pwd)/.."

if [[ "$termux_root/Desktop/.." == "$this_root" ]]; then # runing inside termux
    folder_out="$termux_root/storage/shared/TermuxIO"
else
    folder_out="$this_root/../../TermuxIO"
fi

# -----------------------------------------------
ts="$(date +%Y%m%d_%H%M%S)"
paths_in="$this_root/Desktop $this_root/.config $this_root/.termux"
path_out="$folder_out/$ts.tar.gz"
echo $ts > current_termux.txt

echo "Packing to $path_out"
tar -czf $path_out $paths_in 2>/dev/null


# -----------------------------------------------
