# envpath: manage PATH entries persisted in conf.d/10-env.fish.
#
#   envpath add [--append] DIR   add DIR to PATH (prepended by default) and persist it
#   envpath remove DIR           remove DIR from PATH and from the config
#   envpath list                 list persisted entries

function __envpath_store_form -a dir
    # Keep paths under $HOME as $HOME/... so the config stays portable.
    if string match -q -- "$HOME/*" $dir
        echo "\$HOME"(string sub -s (math (string length -- $HOME) + 1) -- $dir)
    else
        echo $dir
    end
end

function envpath -d "Manage PATH entries persisted in fish config"
    set -l env_file $__fish_config_dir/conf.d/10-env.fish

    if test (count $argv) -eq 0
        echo "usage: envpath add [--append] DIR | remove DIR | list" >&2
        return 2
    end

    set -l cmd $argv[1]
    set -e argv[1]
    argparse a/append -- $argv; or return 2

    switch $cmd
        case add
            if test (count $argv) -ne 1
                echo "usage: envpath add [--append] DIR" >&2
                return 2
            end
            set -l dir (realpath -m -- $argv[1])
            if not test -d $dir
                echo "envpath: not a directory: $dir" >&2
                return 1
            end

            set -l store (__envpath_store_form $dir)
            set -l opt
            set -q _flag_append; and set opt --append

            # Drop any earlier entry for this dir, then add the new one.
            set -l kept (string match -v -- "fish_add_path --global * $store" (cat $env_file) | string match -v -- "fish_add_path --global $store")
            set -a kept "fish_add_path --global $opt $store"
            printf '%s\n' $kept > $env_file

            fish_add_path --global $opt $dir
            echo "envpath: added $dir"

        case remove
            if test (count $argv) -ne 1
                echo "usage: envpath remove DIR" >&2
                return 2
            end
            set -l dir (realpath -m -- $argv[1])
            set -l store (__envpath_store_form $dir)

            set -l kept (string match -v -- "fish_add_path --global * $store" (cat $env_file) | string match -v -- "fish_add_path --global $store")
            printf '%s\n' $kept > $env_file

            set -l keep
            for p in $PATH
                test "$p" != "$dir"; and set -a keep $p
            end
            set -gx PATH $keep
            echo "envpath: removed $dir"

        case list
            for line in (string match -r '^fish_add_path --global.*' -- (cat $env_file))
                set -l tag prepend
                string match -q -- '*--append*' $line; and set tag append
                echo "$tag  "(string replace -r '^fish_add_path --global( --append)? ' '' -- $line)
            end

        case '*'
            echo "envpath: unknown command '$cmd' (use add, remove or list)" >&2
            return 2
    end
end
