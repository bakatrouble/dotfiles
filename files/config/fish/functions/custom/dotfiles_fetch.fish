# dotfiles_fetch: fetch the dotfiles remote. Run in the background by dotfiles_check --startup.
# It must never prompt: no terminal, no credential or host-key questions.

function dotfiles_fetch -d "Fetch the dotfiles repo (background, never prompts)"
    set -l repo $MISE_CONFIG_DIR
    test -n "$repo"; or set repo $HOME/.dotfiles
    set -lx GIT_TERMINAL_PROMPT 0
    set -lx GIT_SSH_COMMAND "ssh -o BatchMode=yes"
    timeout 60 git -C $repo fetch --quiet </dev/null >/dev/null 2>&1
end
