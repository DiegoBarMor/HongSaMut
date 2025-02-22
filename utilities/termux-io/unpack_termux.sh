#!/bin/bash
termux_root="/data/data/com.termux/files/home"
this_root="$(pwd)/.."

if [[ "$termux_root/Desktop/.." == "$this_root" ]]; then # runing inside termux
    folder_in="$termux_root/storage/shared/TermuxIO"
else
    folder_in="$this_root/../../TermuxIO"
fi

# Find the file with the highest numerical value i.e. most recent tar.gz
name_in=$(ls -v "$folder_in" | tail -n 1)

# Prepend the folder path to the file name
path_in="$folder_in/$name_in"

echo "Unpacking from $path_in"

# -----------------------------------------------
tempsh="../temp.sh"
echo "#!/bin/bash" > $tempsh

echo "root=\"$this_root\"" >> $tempsh # Define the parent as root directory
echo "tar -xzf \"$path_in\" -C \"\$root\"" >> $tempsh # Extract the contents of the tar.gz file into the root directory
echo "echo \"$name_in\" > current_termux.txt" >> $tempsh
echo "rm \$0" >> $tempsh # Remove the temporary script

chmod +x $tempsh
./$tempsh
