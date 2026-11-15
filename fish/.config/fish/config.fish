if status is-interactive
    source ~/.fishrc
    # fish runs fish_user_key_bindings during its own reload, which can happen
    # before our functions path is ready, so call it here as well.
    fish_user_key_bindings
end
