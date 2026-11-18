# plugins_sync: install fish_plugins, plus fish_plugins_desktop on desktops.
#
# fish_plugins is read by fisher itself. Desktop-only plugins (tide) live in
# fish_plugins_desktop and are installed here only when is_desktop is true.
# `fisher install` records what it installs in fish_plugins, so the desktop
# entries are removed from fish_plugins again afterwards.

function plugins_sync -d "Install fish_plugins, and fish_plugins_desktop on desktops"
    fisher update; or return

    if not is_desktop
        echo "plugins_sync: not a desktop session, skipping fish_plugins_desktop"
        return
    end

    set -l plugins_file $__fish_config_dir/fish_plugins
    set -l desktop (cat $__fish_config_dir/fish_plugins_desktop)
    fisher install $desktop; or return

    set -l kept (string match -v -- $desktop (cat $plugins_file))
    printf '%s\n' $kept > $plugins_file
end
