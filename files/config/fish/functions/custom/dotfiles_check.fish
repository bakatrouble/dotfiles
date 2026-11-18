# dotfiles_check: report dotfiles state.
#
#   dotfiles_check --startup   start a background fetch, then list uncommitted
#                              and unpushed changes
#   dotfiles_check             after each command: warn only if config.fish has
#                              uncommitted changes
#
# Called from config.fish. The fetch never blocks the shell.

# __dotfiles_print STYLE... TEXT   print TEXT with the set_color STYLE (e.g. bold yellow).
function __dotfiles_print
    set -l text $argv[-1]
    set -l style $argv[1..-2]
    set_color $style
    printf '%s' $text
    set_color normal
    echo
end

# __dotfiles_status_line PORCELAIN_LINE   "XY path" -> colored status letter and path.
function __dotfiles_status_line
    set -l code (string sub -l 2 -- $argv[1])
    set -l path (string sub -s 4 -- $argv[1])
    set -l letter (string trim -- $code)
    set -l color normal
    switch $code
        case '??'
            set letter '?'
            set color magenta
        case '*M*' 'M*'
            set letter M
            set color yellow
        case '*A*' 'A*'
            set letter A
            set color green
        case '*D*' 'D*'
            set letter D
            set color red
        case '*R*' 'R*'
            set letter R
            set color cyan
    end
    set_color $color
    printf '    %-2s' $letter
    set_color normal
    printf ' %s\n' $path
end

function dotfiles_check -d "Report dotfiles state"
    argparse startup -- $argv; or return 2

    set -l repo $MISE_CONFIG_DIR
    test -n "$repo"; or set repo $HOME/.dotfiles
    git -C $repo rev-parse --git-dir >/dev/null 2>&1; or return 0

    if set -q _flag_startup
        set -l fetch_cmd "fish --no-config -c 'source $__fish_config_dir/functions/custom/dotfiles_fetch.fish; dotfiles_fetch' </dev/null >/dev/null 2>&1 &"
        sh -c $fetch_cmd

        set -l changes (git -C $repo status --porcelain)
        set -l upstream (git -C $repo rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)
        set -l unpushed
        if test -n "$upstream"
            set unpushed (git -C $repo log --format='%h %s' "$upstream..HEAD" 2>/dev/null)
        end

        if test (count $changes) -eq 0; and test (count $unpushed) -eq 0
            return
        end

        echo
        __dotfiles_print --bold cyan "dotfiles  $repo"
        if test (count $changes) -gt 0
            __dotfiles_print --bold yellow "  uncommitted ("(count $changes)")"
            for line in $changes
                __dotfiles_status_line $line
            end
        end
        if test (count $unpushed) -gt 0
            __dotfiles_print --bold yellow "  unpushed ("(count $unpushed)")"
            for line in $unpushed
                set -l parts (string split -m 1 ' ' -- $line)
                set_color yellow
                printf '    %s' $parts[1]
                set_color normal
                printf ' %s\n' $parts[2]
            end
        end
        echo
        return
    end

    set -l config_changes (git -C $repo status --porcelain -- files/config/fish/config.fish)
    if test (count $config_changes) -gt 0
        __dotfiles_print yellow '⚠ files/config/fish/config.fish has uncommitted changes'
    end
end
