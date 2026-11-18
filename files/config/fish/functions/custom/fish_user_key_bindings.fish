# Our key bindings. fish calls this after fish_key_bindings
# (fish_default_key_bindings) is loaded, so these override the preset.

function fish_user_key_bindings
    bind down down-or-prefix-search
    bind up up-or-prefix-search
end
