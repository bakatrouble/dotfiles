# gabbr X Y: add abbreviation X that expands to Y anywhere on the command line.

function gabbr -d "Add a global abbreviation: gabbr NAME EXPANSION"
    if test (count $argv) -ne 2
        echo "usage: gabbr NAME EXPANSION" >&2
        return 2
    end

    abbr --add --position anywhere -- $argv[1] $argv[2]
end
