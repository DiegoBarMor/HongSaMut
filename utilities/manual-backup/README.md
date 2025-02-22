# Manual backups of large folders with Bash
This script is meant to facilitate the process of creating backups of multiple folders from a `root_in` location into a `root_out` location. A list of folders is to be provided in a `folders.txt` file; this must be relative to the `root_in` location. Each of these folders will get compressed and sent to `root_out`, while preserving the original folder hierarchy.

## Usage
1) Create a file `folders.txt` with a list of folders you would like to backup. An example is provided as `folders.example.txt`, for a typical use of backing up user data in a device with a Windows installation (if running this script from WSL, `root_in` would be `/mnt/c`).
2) Run the script and specify the path to the `root_in` first, followed by the path to `root_out`.
```bash
./run.sh [path_to_in] [path_to_out]
```

## Example of preservation of the folder hierarchy
Given a `root_in` with the following hierarchy:
```
path_to_in
|-a
| |-p
| | |-0.txt
| | `-1.txt
| `-q
|   |-r
|   | `2.txt
|   `-3.txt
|-b
| |-x
| | `4.txt
| `5.txt
`-c
  `...
```

You could specify a `folders.txt` with the following paths:
```
a/p
a/q/r
b
```

After running `./run.sh $path_to_in $path_to_out`, the final backup created in `root_out` will be placed in a folder with the current time (`YYYYMMDD`) with the following structure:
```
path_to_out
`-YYYYMMDD
| |-a
| | |-p.tar.gz
| | `-q
| |   `-r.tar.gz
| `-b.tar.gz
`...
```
Note that, for this example, almost everything would be backed up. Only the contents of `3.txt` and the folder `c` are left out, as they aren't inside the folders specified in `folders.txt`
