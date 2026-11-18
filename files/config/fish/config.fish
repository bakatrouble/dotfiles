if status is-interactive
    source ~/.fishrc
    # fish runs fish_user_key_bindings during its own reload, which can happen
    # before our functions path is ready, so call it here as well.
    fish_user_key_bindings

    # First prompt (after fish's greeting): start a background fetch and list
    # uncommitted and unpushed changes. Runs once.
    function __dotfiles_startup --on-event fish_prompt
        functions -e __dotfiles_startup
        dotfiles_check --startup
    end

    # After every command: offer a fetched update once, and warn if config.fish
    # has uncommitted changes.
    function __dotfiles_after_command --on-event fish_postexec
        dotfiles_offer_update
        dotfiles_check
    end
end
