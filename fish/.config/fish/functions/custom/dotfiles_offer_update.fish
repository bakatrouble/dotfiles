# dotfiles_offer_update: once per shell, after the background fetch has updated the
# refs, offer the pending update (oh-my-zsh style). Stops after the first offer.

function dotfiles_offer_update -d "Offer a fetched dotfiles update once per shell"
    set -q __dotfiles_offered; and return 0

    set -l repo $MISE_CONFIG_DIR
    test -n "$repo"; or set repo $HOME/.dotfiles
    set -l upstream (git -C $repo rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)
    test -n "$upstream"; or return 0

    set -l behind (git -C $repo rev-list --count "HEAD..$upstream" 2>/dev/null)
    test -n "$behind"; and test "$behind" -gt 0; or return 0

    set -g __dotfiles_offered 1
    echo
    set_color --bold yellow
    echo -n "dotfiles: $behind update(s) available on $upstream."
    set_color normal
    echo
    set_color --bold
    read -l -P "Would you like to update? [Y/n] " answer
    set_color normal
    if test -z "$answer"; or string match -qri '^y(es)?$' -- $answer
        if git -C $repo pull --ff-only --quiet
            set_color green
            echo "✔ dotfiles updated. Run 'mise bootstrap' if the mise config changed."
        else
            set_color red
            echo "✘ dotfiles pull failed; resolve it in $repo." >&2
        end
        set_color normal
    end
    echo
end
