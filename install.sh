#!/bin/sh
# Link the dotfiles packages into $HOME with GNU Stow.
set -eu

command -v stow >/dev/null 2>&1 || { echo "stow is not installed" >&2; exit 1; }

REPO=$(cd "$(dirname "$0")" && pwd)
cd "$REPO"

# Remove links left over from the old layout (they point at paths that no
# longer exist). Only symlinks are removed; real files and directories are
# left alone so stow can report them as conflicts.
for target in "$HOME/.config/fish" "$HOME/.config/nvim" "$HOME/.fishrc"; do
    if [ -L "$target" ]; then
        rm -- "$target"
    fi
done

mkdir -p "$HOME/.config"
stow --restow --verbose=1 --target="$HOME" fish nvim shell
