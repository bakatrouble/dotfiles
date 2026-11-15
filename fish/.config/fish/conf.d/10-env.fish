# Exported environment variables. Managed with `envvar set NAME VALUE`
# (see functions/envvar.fish); secrets live in conf.d/secrets.fish instead.
set -gx EDITOR nvim
set -gx SUDO_EDITOR nvim
set -gx SYSTEMD_EDITOR nvim
set -gx ANDROID_HOME $HOME/Android/Sdk
set -gx PYENV_ROOT $HOME/.pyenv
set -gx VIRTUAL_ENV_DISABLE_PROMPT true
set -gx PNPM_HOME "/home/user/.local/share/pnpm"

# PATH entries, formerly fish_user_paths. Prepended in reverse so the final
# order matches the old list.
fish_add_path --global $HOME/.bin
fish_add_path --global $HOME/go/bin
fish_add_path --global /usr/bin/core_perl
fish_add_path --global /usr/bin/vendor_perl
fish_add_path --global /usr/bin/site_perl
fish_add_path --global /usr/lib/jvm/default/bin
fish_add_path --global /var/lib/flatpak/exports/bin
fish_add_path --global $HOME/.nimble/bin
fish_add_path --global $HOME/.cargo/bin
fish_add_path --global $HOME/.local/bin
fish_add_path --global $HOME/.yarn/bin
fish_add_path --global $HOME/.local/share/pnpm/bin
fish_add_path --global $HOME/.foundry/bin
