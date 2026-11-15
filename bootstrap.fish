#!/usr/bin/env fish
# Bootstrap these dotfiles on a new machine.
#
#   fish -c 'curl -fsSL https://mise.run | sh'   # only if mise is missing
#   env MISE_CONFIG_DIR=~/.dotfiles mise bootstrap --adopt bakatrouble/dotfiles
#
# This script runs the same thing. It needs fish, git and curl. It installs mise
# with `curl -fsSL https://mise.run | sh` when mise is missing. With --dry-run,
# only the preview runs and no plugins are installed.

set -gx MISE_CONFIG_DIR $HOME/.dotfiles

if not command -q mise
    echo "bootstrap: mise not found, installing it to ~/.local/bin"
    curl -fsSL https://mise.run | env MISE_INSTALL_HELP=0 sh
    set -l rc $pipestatus
    if test $rc[1] -ne 0; or test $rc[2] -ne 0
        echo "bootstrap: mise install failed" >&2
        exit 1
    end
    fish_add_path --global $HOME/.local/bin
    if not command -q mise
        echo "bootstrap: mise is still not on PATH after install" >&2
        exit 1
    end
end

set -l dry
contains -- --dry-run $argv; and set dry --dry-run

if test -d $MISE_CONFIG_DIR/.git
    # Already adopted: apply the existing checkout.
    mise bootstrap $dry; or exit 1
else
    mise bootstrap --adopt bakatrouble/dotfiles $dry; or exit 1
end

if test -z "$dry"
    fish -l -c plugins_sync; or exit 1
end

echo "bootstrap: done. Open a new fish shell to pick up the configuration."
