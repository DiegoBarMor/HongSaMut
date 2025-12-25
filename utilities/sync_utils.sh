#!/usr/bin/env bash
set -euo pipefail

copy_git() {
  ### DISCLAIMER: this function was originally provided by VSCode Copilot.
  ### It has been modified and tested accordingly.

  local SRC="$1"
  local DST="$2"

  if [ -z "${SRC:-}" ] || [ -z "${DST:-}" ]; then
    printf 'Usage: %s /path/to/source-repo /path/to/dest-sync-folder\n' "$0" >&2
    return 2
  fi

  # ensure absolute paths
  SRC="$(readlink -f "$SRC")"
  DST="$(readlink -f "$DST")"

  if ! git -C "$SRC" rev-parse --git-dir >/dev/null 2>&1; then
    printf "Source '%s' is not a git repository.\n" "$SRC" >&2
    return 3
  fi

  mkdir -p "$DST"

  # manifest stored in DST and keyed by SHA1 of source path to allow multiple repos
  local manifest
  manifest="$DST/.sync_manifest_$(printf '%s' "$SRC" | sha1sum | awk '{print $1}').txt"

  local tmp_z tmp_nl
  tmp_z="$(mktemp)"
  tmp_nl="$(mktemp)"

  # ensure cleanup on function exit; save old trap to restore later
  local old_trap
  old_trap="$(trap -p EXIT || true)"
  trap 'rm -f "$tmp_z" "$tmp_nl"' EXIT

  # Get all tracked + untracked-but-not-ignored files (NUL separated)
  git -C "$SRC" ls-files --cached --others --exclude-standard -z > "$tmp_z"

  # convert to newline-separated list for rsync (does not handle filenames with newlines)
  tr '\0' '\n' < "$tmp_z" > "$tmp_nl"

  # Add the .git directory contents in the list for rsync
  echo $(cd "$SRC"; tree .git -if --noreport) | tr ' ' '\n' >> "$tmp_nl"

  # Sync files listed from SRC -> DST (preserve paths)
  # --relative not strictly necessary if files are relative, but keeps path structure safe
  rsync -a --files-from="$tmp_nl" --relative "$SRC"/ "$DST"/

  # If we have a previous manifest, delete entries that were synced before but are no longer present
  if [ -f "$manifest" ]; then
    local prev_sorted cur_sorted to_delete
    prev_sorted="$(mktemp)"
    cur_sorted="$(mktemp)"
    to_delete="$(mktemp)"
    trap 'rm -f "$prev_sorted" "$cur_sorted" "$to_delete" "$tmp_z" "$tmp_nl"' EXIT

    sort -u "$manifest" > "$prev_sorted"
    sort -u "$tmp_nl" > "$cur_sorted"
    comm -23 "$prev_sorted" "$cur_sorted" > "$to_delete"

    while IFS= read -r relpath; do
      [ -z "$relpath" ] && continue
      target="$DST/$relpath"
      if [ -e "$target" ]; then
        rm -rf -- "$target"
        # try to remove empty parent directories up to DST
        dir=$(dirname -- "$target")
        while [ "$dir" != "$DST" ] && [ -d "$dir" ] && [ -z "$(ls -A -- "$dir")" ]; do
          rmdir -- "$dir" || break
          dir=$(dirname -- "$dir")
        done
      fi
    done < "$to_delete"
  fi

  # update manifest (newline-separated list)
  mv "$tmp_nl" "$manifest"
  rm -f "$tmp_z" || true

  # restore previous EXIT trap (if any) and clear our trap
  trap - EXIT
  if [ -n "$old_trap" ]; then
    eval "$old_trap"
  fi

  return 0
}

copy_selective() {
    ##### DISCLAIMER: this is a simple function used for some personal projects. Might improve in the future. Use with caution.

    if [[ $# -ne 3 ]]; then
        echo "Usage: copy_selective_ssh <source_dir> <destination_dir> <paths_selective>"
        exit 1
    fi

    local SRC="$1"
    local DST="$2"
    local paths_selective="$3"

    for path in $paths_selective; do
        mkdir -p "$DST"
        # shellcheck disable=SC2086
        rm -rf "${DST:?}"/$path;
        # shellcheck disable=SC2086
        cp -r "$SRC"/$path "$DST/"
    done
}

copy_selective_ssh() {
    ##### DISCLAIMER: this is a simple function used for some personal projects. Might improve in the future. Use with caution.

    if [[ $# -ne 4 ]]; then
        echo "Usage: copy_selective_ssh <source_dir> <destination_dir> <paths_selective> <ssh_host>"
        exit 1
    fi

    local SRC="$1"
    local DST="$2"
    local paths_selective="$3"
    local ssh_host="$4"

    for path in $paths_selective; do
        # shellcheck disable=SC2029
        ssh "$ssh_host" "mkdir -p \"$DST\"; rm -rf \"$DST\"/$path;"
        # shellcheck disable=SC2086
        scp -rpC "$SRC"/$path "$ssh_host:$DST/"
    done
}


if [[ $# -lt 1 ]]; then
    echo "Usage: $0 {copygit|copysel|copyselssh} [arguments...]"
    exit 1
fi

command="$1"
shift

case "$command" in
    copygit)
        copy_git "$@"
        ;;
    copysel)
        copy_selective "$@"
        ;;
    copyselssh)
        copy_selective_ssh "$@"
        ;;
    *)
        echo "Error: Unknown command '$command'. Valid commands are: copygit, copysel, copyselssh."
        exit 1
        ;;
esac
