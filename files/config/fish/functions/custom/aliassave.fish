# aliassave: create an alias and save it to functions/custom.
#
#   aliassave NAME DEFINITION
#   aliassave NAME=DEFINITION
#
# Same arguments as the builtin alias; `alias --save` writes to functions/
# instead, so this runs alias and then funcsave -d into functions/custom.

function aliassave -d "Create an alias and save it to functions/custom"
    if test (count $argv) -eq 0
        echo "usage: aliassave NAME DEFINITION | NAME=DEFINITION" >&2
        return 2
    end

    alias $argv; or return

    set -l name (string split -m 1 -- = $argv[1])[1]
    funcsave -d $__fish_config_dir/functions/custom $name
end
