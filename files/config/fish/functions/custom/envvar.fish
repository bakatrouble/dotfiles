# envvar: persist exported environment variables without `set -U`.
#
#   envvar set [--secret] NAME VALUE   persist NAME and export it now
#   envvar unset NAME                  remove NAME from the config files and this session
#   envvar list                        list persisted names (secret values are never shown)
#
# Plain values go to conf.d/10-env.fish (tracked by git).
# With --secret, values go to conf.d/secrets.fish (git-ignored, mode 600).

function __envvar_write -a file name value
    set -l kept
    test -f $file; and set kept (string match -v -- "set -gx $name *" (cat $file))
    set -a kept "set -gx $name "(string escape -- $value)
    printf '%s\n' $kept > $file
end

function __envvar_remove -a file name
    test -f $file; or return 0
    set -l kept (string match -v -- "set -gx $name *" (cat $file))
    printf '%s\n' $kept > $file
end

function envvar -d "Persist exported environment variables in fish config"
    set -l conf $__fish_config_dir/conf.d
    set -l env_file $conf/10-env.fish
    set -l secret_file $conf/secrets.fish

    if test (count $argv) -eq 0
        echo "usage: envvar set [--secret] NAME VALUE | unset NAME | list" >&2
        return 2
    end

    set -l cmd $argv[1]
    set -e argv[1]
    argparse s/secret -- $argv; or return 2

    switch $cmd
        case set
            if test (count $argv) -ne 2
                echo "usage: envvar set [--secret] NAME VALUE" >&2
                return 2
            end
            set -l name $argv[1]
            set -l value $argv[2]
            if not string match -qr '^[A-Za-z_][A-Za-z0-9_]*$' -- $name
                echo "envvar: invalid name: $name" >&2
                return 2
            end
            if set -q _flag_secret
                __envvar_write $secret_file $name $value
                chmod 600 $secret_file
                set -gx $name $value
                echo "envvar: set $name (secret, $secret_file)"
            else
                __envvar_write $env_file $name $value
                set -gx $name $value
                echo "envvar: set $name"
            end

        case unset
            if test (count $argv) -ne 1
                echo "usage: envvar unset NAME" >&2
                return 2
            end
            set -l name $argv[1]
            __envvar_remove $env_file $name
            __envvar_remove $secret_file $name
            set -e $name
            echo "envvar: unset $name"

        case list
            for file in $env_file $secret_file
                test -f $file; or continue
                set -l tag
                test "$file" = "$secret_file"; and set tag " (secret, hidden)"
                for name in (string match -r '^set -gx [A-Za-z_][A-Za-z0-9_]*' -- (cat $file) | string replace -r '^set -gx ' '')
                    echo "$name$tag"
                end
            end

        case '*'
            echo "envvar: unknown command '$cmd' (use set, unset or list)" >&2
            return 2
    end
end
