#!/usr/bin/env bash

############################### GLOBAL VARIABLES ###############################

editor="micro"
visual="micro"


############################ ENVIRONMENT VARIABLES #############################

export EDITOR=$editor
export SUDO_EDITOR=$editor
export VISUAL=$visual


# export MANPAGER="less -R --use-color -Dd+g -Du+b" # Colored man
# export MANPAGER='less -s -M +Gg' # Percentages added to man
export MANPAGER="less -R --use-color -Dd+g -Du+b -s -M +Gg"
export GROFF_NO_SGR=1 # for konsole and gnome-terminal

### [TEMP] TERMUX
# alias grep='grep --color=auto'

################################ AUTOCOMPLETION ################################

# bind 'TAB:menu-complete' # cycle through all matches with 'TAB' key
shopt -s extglob # necessary for programmable completion
shopt -s autocd # cd when entering just a path


################################### ALIASES ####################################

alias xaddons='$EDITOR ~/.hongsamut/bash_additions.sh # ~/.bash_extra'
alias snek='source ~/miniconda3/etc/profile.d/conda.sh; conda activate' # envname can be provided afterward e.g. "snek prisma" activates the "prisma" env
alias nosnek='conda deactivate'

# shellcheck disable=SC2139
alias e="$editor"
alias p="python3"
alias mk="mkdir -vp"
alias ts="$(date +%Y%m%d_%H%M%S)"

alias manc="man libc" # overview of standard C libraries
alias rmpycache="find -name __pycache__ -exec rm -rf {} \;"


################################### FUNCTIONS ##################################

coloransi() { # FUNC: print text in ANSI color; args: text, short_code (0-7), do_bright (0/1). 0: black, 1: red, 2: green, 3: yellow, 4: blue, 5: magenta, 6: cyan, 7: white
    text="${1:-Sample Text}"
    short_code="${2:-1}"
    do_bright="${3:-1}"

    if [[ $do_bright -eq 1 ]]; then
        shift=90
    else
        shift=30
    fi

    code=$((short_code+shift))
    printf "\e[%sm%s\e[0m" "$code" "$text"
}

addons() { # FUNC: displays the functions present in ~/.hongsamut/bash_additions.sh
    parse_file() {
        regex='^(\s*alias\s+.+=.*)|(.+\(\s*\)\s*\{\s*#\s*FUNC.*)$'
        while IFS= read -r line; do
          if [[ $line =~ $regex ]]; then
            func_name=$(echo "$line" | cut -d'#' -f1)
            func_desc=$(echo "$line" | cut -d'#' -f2-)
            func_desc="${func_desc#*FUNC}"
            echo -e "$(coloransi "$func_name")\n    $func_desc\n"
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

tmuxreset() { # FUNC: (currently has some issues) kills tmux server and restarts it by calling tmux-resurrect
    tmux kill-server
    rm -rf /tmp/tmux*
    tmux new-session -d

    SCRIPT_DIR="$HOME/.tmux/plugins/tmux-resurrect" # https://stackoverflow.com/questions/64995878/send-prefix-key-to-tmux-session
    tmux send-keys -t 0:0 "$SCRIPT_DIR/scripts/restore.sh" Enter

    tmux attach
}

showcolors() { # FUNC: display the 256 available colors
    echo "Standard 8 ANSI colors (foreground):"
    for code in {0..7}; do # 30..37
        coloransi "$((code+30))  " "$code" 0
    done
    echo -e "\nBright ANSI colors (foreground):"
    for code in {0..7}; do # 90..97
        coloransi "$((code+90))  " "$code" 1
    done
    echo -e "\n"

    echo "256-color palette (foreground):"
    for i in {0..255}; do
        printf "\x1b[38;5;%sm%3s\x1b[0m " "$i" "$i"
        if (( (i + 1) % 16 == 0 )); then
            echo
        fi
    done
    echo
}

rendermd() { # FUNC: render Markdown files using pandoc and lynx
    local path="${1:-.}"
	pandoc "$path" | lynx -stdin
}

_shortcut_files() {
    local name="${1}"
    local cmd="${2}"
    local ext="${3}"
    local location="${4}"
    local path="$location/$name.$ext"

    if [ -z "$name" ] || [ ! -e "$path" ]; then
        cd "$location"
        echo "Usage: $cmd <file_stem>"
        echo "Available options:"        
        echo "$(coloransi "$(ls *.$ext | xargs -L1 basename --suffix=.$ext)" 3)"
        cd - >/dev/null
        return 1
    fi

	# rendermd "$path"
	$editor "$path"
}

snippets() { # FUNC: open snippets from hongsamut
    _shortcut_files "${1}" "snippets" md "$(realpath ~/".hongsamut/snippets")" 
}

guides() { # FUNC: open guides from hongsamut
    _shortcut_files "${1}" "guides" md "$(realpath ~/".hongsamut/guides")" 
}

explorer() { # FUNC: open file explorer at specified path (UBUNTU NAUTILUS)
    local path="${1:-.}"
    nautilus --browser "$path"

}

cdl() { # FUNC: change current directory and display all its contents
    local path="${1:-.}"
    cd "$path" && la
}

cpinto() { # FUNC: copy directory with 'cp -r' and cd into it
    if [[ $# -lt 2 ]]; then
        echo "Usage: cpinto <source> <destination>"
        return 1
    fi
    src="${1}"
    dest="${2}"

    if [ ! -d "$src" ]; then
        echo "Source '$src' is not a directory."
        return 2
    fi
    cp -r "$@"
    cd "$dest" || return 1
}

mkinto() { # FUNC: make directory and cd into it
    if [[ $# -lt 1 ]]; then
        echo "Usage: mkinto <directory>"
        return 1
    fi
    mkdir -p "$1" && cd "$1" || return 1
}

lsdeep() { # FUNC: list all files and directories from the specified directory. Display head and tail for every file. List contents for every subdirectory.
    local path="${1:-.}"
    children=$(ls -A1 "$path")
    color_file=3 # yellow
    color_dir=4 # blue
    for child in $children; do
        if [ -d "$path/$child" ]; then
            echo -e "==> Directory: $(coloransi "$child" $color_dir) <=="
            # contents=$(ls -Ap1 "$path/$child")
            # ncontents=$(ls -1 "$path/$child" | wc -l)
            ncontents=$(find . -maxdepth 1 | wc -l | wc -l)
            if (( ncontents > 25 )); then
                # echo $contents # WIP
                ls -Ap1 "$path/$child"
            else
                # echo $contents
                ls -Ap1 "$path/$child"
            fi

        elif [ -f "$path/$child" ]; then
            echo -e "==> File: $(coloransi "$child" $color_file) <=="
            nlines=$(cat "$path/$child" | wc -l)
            if (( nlines > 10 )); then
                head -n 5 "$path/$child"
                echo "$(coloransi "..." $color_file) "
                tail -n 5 "$path/$child"
            else
                cat "$path/$child"
            fi


        fi
        echo
    done
}

boiler() { # FUNC: create a boilerplate file at the specified path, based on the file extension
    local path="${1}"
    if [ -z "$path" ]; then
        echo "Usage: boiler <file_path>"
        return 1
    fi

    folder_boilers=~/.hongsamut/boilerplate
    ext="${path##*.}"
    case "$ext" in
        sh)
            cp "$folder_boilers/script.sh" "$path"
            ;;
        py)
            cp "$folder_boilers/main.py" "$path"
            ;;
        *)
            echo "No boilerplate available for extension: .$ext"
            return 2
            ;;
    esac
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
        echo "                          If specified, outputs a CSV to 'out'/repos.csv (default: don't save, view with prismacsv instead)."
        echo "                          Requires Python packages: pandas"
        # echo "  termuxio [options]      Pack or unpack Termux configuration and data (see 'termuxio --help' for details)"
        echo "  copygit [src] [dest]    ..."
        echo "  copysel [options]       ..."
        echo "  copyselssh [options]    ..."
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
            # termuxio)
            #     bash "$folder_utils/termux_io.sh" "${@:2}"
            #     return 0
            #     ;;
            copygit|copysel|copyselssh)
                bash "$folder_utils/sync_utils.sh" "$1" "${@:2}"
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
### SOURCES:
### https://github.com/knightfall-cs/termux-bashrc/blob/main/bash.bashrc
### https://wiki.archlinux.org/index.php/Color_output_in_console#man
### https://stackoverflow.com/a/19871578/5353461
