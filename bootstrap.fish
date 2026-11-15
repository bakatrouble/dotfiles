#!/usr/bin/env fish
# Bootstrap these dotfiles on a new machine.
#
#   curl -fsSL https://is.gd/bakatrouble_dotfiles | fish
#
# Needs fish, git and curl. Installs mise with `curl -fsSL https://mise.run | sh`
# when it is missing. Existing files that the dotfiles would replace are listed,
# and you are asked before each one is removed. With --dry-run, nothing is
# removed, installed or applied.

set -gx MISE_CONFIG_DIR $HOME/.dotfiles

set -l dry
contains -- --dry-run $argv; and set dry --dry-run

# __bootstrap_confirm PROMPT: ask on the terminal (stdin may be the script itself).
function __bootstrap_confirm -a prompt
    test -r /dev/tty; or return 1
    read -l -P "$prompt" answer < /dev/tty
    string match -qri '^y(es)?$' -- $answer
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

# Files and directories the dotfiles link. A real one in the way is listed,
# and removed only after confirmation. Fish's own first-start files are removed
# without asking.
set -l targets $HOME/.config/fish $HOME/.config/nvim $HOME/.fishrc $HOME/.ssh/config $HOME/.ssh/hosts.d
for target in $targets
    if test -e $target; or test -L $target
        test -L $target; and continue
        if test "$target" = $HOME/.config/fish; and __bootstrap_is_scaffold $target
            test -z "$dry"; and rm -rf $target
            continue
        end
        echo "bootstrap: $target exists and is not a symlink:"
        if test -d $target
            command ls -A $target | sed 's/^/    /'
        end
        if test -n "$dry"
            echo "    (dry run: not replaced)"
            continue
        end
        if __bootstrap_confirm "Replace $target? [y/N] "
            rm -rf $target
        else
            echo "bootstrap: kept $target; stopping." >&2
            exit 1
        end
    end
end

if test -d $MISE_CONFIG_DIR/.git
    # Existing checkout: fast-forward it to the remote, then apply it.
    if test -z "$dry"
        git -C $MISE_CONFIG_DIR pull --ff-only --quiet </dev/null >/dev/null 2>&1; or echo "bootstrap: could not fast-forward $MISE_CONFIG_DIR; applying what is checked out." >&2
    end
    mise bootstrap $dry; or exit 1
else
    mise bootstrap --adopt bakatrouble/dotfiles $dry; or exit 1
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
