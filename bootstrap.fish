#!/usr/bin/env fish
# Bootstrap these dotfiles on a new machine.
#
#   git clone git@github.com:bakatrouble/dotfiles.git ~/.dotfiles; and fish ~/.dotfiles/bootstrap.fish
#
# Needs fish, git and mise (https://mise.jdx.dev) on PATH. With --dry-run, only
# the mise preview runs and no plugins are installed.

set -l repo (realpath (dirname (status filename)))

if not command -q mise
    echo "bootstrap: mise is not installed. Install it, then run this again." >&2
    exit 1
end

set -l dry
contains -- --dry-run $argv; and set dry --dry-run

mise -C $repo trust; or exit 1
mise -C $repo dot apply $dry; or exit 1
mise -C $repo dot status

if test -z "$dry"
    fish -l -c plugins_sync; or exit 1
end

echo "bootstrap: done. Open a new fish shell to pick up the configuration."
