#!/usr/bin/env fish
# Bootstrap these dotfiles on a new machine.
#
#   curl -fsS https://dotfiles.bakatrouble.me | fish   (install.fish, the stub that runs this)
#
# Needs fish, git and curl. Installs mise with `curl -fsSL https://mise.run | sh`
# when it is missing. Anything at a target path that is not already linked to this
# repo is listed, and you are asked before it is replaced. With --dry-run, nothing
# is removed, installed or applied.

set -gx MISE_CONFIG_DIR $HOME/.dotfiles

set -l dry
contains -- --dry-run $argv; and set dry --dry-run

# __bootstrap_confirm PROMPT: ask on the terminal (stdin may be the script itself).
function __bootstrap_confirm -a prompt
    test -r /dev/tty; or return 1
    read -l -P "$prompt" answer < /dev/tty
    string match -qri '^y(es)?$' -- $answer
end

# __bootstrap_source_for TARGET: the repo path that TARGET should link to.
function __bootstrap_source_for -a target
    set -l repo $MISE_CONFIG_DIR
    switch $target
        case $HOME/.config/fish
            echo $repo/fish/.config/fish
        case $HOME/.config/nvim
            echo $repo/nvim/.config/nvim
        case $HOME/.fishrc
            echo $repo/shell/.fishrc
        case $HOME/.ssh/config
            echo $repo/ssh/config
        case $HOME/.ssh/hosts.d
            echo $repo/ssh/hosts.d
    end
end

# __bootstrap_is_scaffold PATH: true for what starting fish creates by itself:
# empty directories, fish_variables*, and fish's default config.fish.
function __bootstrap_is_scaffold -a path
    set -l template "if status is-interactive
    # Commands to run in interactive sessions can go here
end"
    if test -d $path
        for e in (command ls -A $path)
            set -l p $path/$e
            if string match -qr '^fish_variables' -- $e
                continue
            else if test "$e" = config.fish; and test -f $p
                set -l content (cat $p | string collect)
                test "$content" = "$template"; or return 1
            else if test -d $p; and test (count (command ls -A $p)) -eq 0
                continue
            else
                return 1
            end
        end
        return 0
    end
    return 1
end

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

# Targets the dotfiles link. Anything there that does not already point at the
# matching repo path is listed and removed only after confirmation. Fish's own
# first-start files are removed without asking.
set -l targets $HOME/.config/fish $HOME/.config/nvim $HOME/.fishrc $HOME/.ssh/config $HOME/.ssh/hosts.d
for target in $targets
    set -l source (__bootstrap_source_for $target)
    if test -L $target
        if test -e $source; and test (realpath $target) = (realpath $source)
            continue
        end
        echo "bootstrap: $target is a symlink to $(readlink $target), not $source:"
    else if test -e $target
        if test "$target" = $HOME/.config/fish; and __bootstrap_is_scaffold $target
            test -z "$dry"; and rm -rf $target
            continue
        end
        echo "bootstrap: $target exists and is not linked to $source:"
        if test -d $target
            command ls -A $target | sed 's/^/    /'
        end
    else
        continue
    end

    if test -n "$dry"
        echo "    (dry run: not replaced)"
        continue
    end
    if __bootstrap_confirm "Replace $target? [y/N] "
        if test -L $target; or not test -d $target
            rm -- $target
        else
            rm -rf $target
        end
    else
        echo "bootstrap: kept $target; stopping." >&2
        exit 1
    end
end

if test -d $MISE_CONFIG_DIR/.git
    # Existing checkout: fast-forward it to the remote, then apply it.
    if test -z "$dry"
        git -C $MISE_CONFIG_DIR pull --ff-only --quiet </dev/null >/dev/null 2>&1; or echo "bootstrap: could not fast-forward $MISE_CONFIG_DIR; applying what is checked out." >&2
    end
    mise bootstrap $dry --yes; or exit 1
else
    mise bootstrap --adopt bakatrouble/dotfiles $dry --yes; or exit 1
end

if test -z "$dry"
    # Load the functions from the checkout by path, not through fish's function path.
    set -l custom $MISE_CONFIG_DIR/fish/.config/fish/functions/custom
    if not test -f $custom/plugins_sync.fish
        echo "bootstrap: $custom/plugins_sync.fish is missing; update $MISE_CONFIG_DIR and run this again." >&2
        exit 1
    end
    fish -l -c "source $custom/is_desktop.fish; source $custom/plugins_sync.fish; plugins_sync" </dev/null; or exit 1
end

echo "bootstrap: done. Open a new fish shell to pick up the configuration."
