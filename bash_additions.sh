#!/usr/bin/env bash

################################### ALIASES ####################################

alias editbash='micro ~/.hongsamut/bash_additions.sh ~/.bash_extra'
alias funcs='_funcs # display custom functions, similar to calling alias'
alias snek='source ~/miniconda3/etc/profile.d/conda.sh; conda activate' # envname can be provided afterward e.g. "snek prisma" activates the "prisma" env



################################### FUNCTIONS ##################################

_funcs() { # FUNC: displays the functions present in ~/.hongsamut/bash_additions.sh
    parse_file() {
        regex='^(\s*alias\s+.+=.*)|(.+\(\s*\)\s*\{\s*#\s*FUNC.*)$'
        while IFS= read -r line; do
          if [[ $line =~ $regex ]]; then
            func_name=$(echo "$line" | cut -d'#' -f1)
            func_desc=$(echo "$line" | cut -d'#' -f2-)
            func_desc="${func_desc#*FUNC}"
            echo "$func_name"
            echo "    $func_desc"
            echo
          fi
        done < "$1"
    }

    parse_file "$HOME/.hongsamut/bash_additions.sh"
    parse_file "$HOME/.bash_extra"
}

dutree() { # FUNC: calls 'du' and 'tree' with the following arguments: path, magnitude (for 'du' threshold), filelimit (for 'tree')
    local path="${1:-.}"       # default path is current directory if not provided
    local magnitude="${2:-6}"  # for the "du" command, magnitude of 10; default is 6 (10^6)
    local filelimit="${3:-10}" # for the "tree" command

    local threshold=$((10 ** magnitude))
    du -hat "$threshold" "$path"
    tree -a --filelimit "$filelimit" "$path"
}

tmuxreset() { # FUNC: kills tmux server and restarts it by calling tmux-resurrect
    tmux kill-server
    rm -rf /tmp/tmux*
    tmux new-session -d

    SCRIPT_DIR="$HOME/.tmux/plugins/tmux-resurrect" # https://stackoverflow.com/questions/64995878/send-prefix-key-to-tmux-session
    tmux send-keys -t 0:0 "$SCRIPT_DIR/scripts/restore.sh" Enter

    tmux attach
}

showcolors() { # FUNC: display the 256 available colors
    for i in {0..255} ; do
        printf "\x1b[38;5;%smcolour%s\n" "${i}" "${i}"
    done
}

cdl() { # FUNC: change current directory and display all its contents
    local path="${1:-.}"
    cd "$path" && la
}

wanderoff() { # FUNC: packup configs and other stuff into a "bindle", ready to deploy to fresh Ubuntu installs (using "unpack.sh" in the bindle folder)
    set -eu
    bindle=~/Desktop/bindle
    kwamlap=~/.kwamlap
    hsm=~/.hongsamut
    wanderer=$hsm/utilities/wanderer

    rm -rf $bindle
    cp -r  $wanderer  $bindle
    cp -r  $kwamlap   $bindle/kwamlap

    mv $bindle/_template_wanderoff.sh $bindle/unpack.sh
    $bindle/pack_configs.sh

    ts="$(date +%Y%m%d_%H%M%S)"
    echo "$ts" > "$bindle/time_packed.txt"

    echo "Finished packing stuff to bindle at $bindle"
}

hongsamut() { # FUNC: main command for HongSaMut utilities; calls the utilities via sub-commands such as "prismacsv", "gitsummary", etc.
    usage() {
        echo "Usage: hongsamut <command> [options]"
        echo
        echo "Commands:"
        echo "  prismacsv files...      Open CSV viewer for specified files. Requires Python packages: pandas, prisma-tui"
        echo "  gitsummary [root] [out] Aggregate git logs for repos in the specified 'root' folder (default: current directory)"
        echo "                          If specified, outputs a CSV to 'out'/repos.csv (default: don't save, open in CSV viewer instead)."
        echo "                          Requires Python packages: pandas"
        echo "  termuxio [options]      Pack or unpack Termux configuration and data (see 'termuxio --help' for details)"
        echo
        echo "Options:"
        echo "  -h, --help              Show this help message and exit"
    }
    folder_utils=~/.hongsamut/utilities

    if [[ "$#" -eq 0 ]]; then
        usage
        return 1
    fi

    ### Parse command line arguments
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            prismacsv)
                python3 "$folder_utils/prisma_csv.py" "${@:2}"
                return 0
                ;;
            gitsummary)
                python3 "$folder_utils/git_summary.py" "${2:-.}" "${@:3}"
                return 0
                ;;
            termuxio)
                bash "$folder_utils/termux_io.sh" "${@:2}"
                return 0
                ;;
            -h|--help)
                usage
                return 0
                ;;
            *)
                usage
                return 1
                ;;
        esac
    done
}


##################################### EXTRA ####################################
if [[ -f ~/.bash_extra ]]; then
    # shellcheck disable=SC1090
    . ~/.bash_extra
fi



################################################################################
