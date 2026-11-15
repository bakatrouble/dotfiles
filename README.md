# dotfiles

This repository is the global [mise](https://mise.jdx.dev) config. Setting
`MISE_CONFIG_DIR=~/.dotfiles` points mise at it. `config.toml` maps each
target in `$HOME` to a source here:

| Source                   | Target             |
|--------------------------|--------------------|
| `fish/.config/fish`      | `~/.config/fish`   |
| `nvim/.config/nvim`      | `~/.config/nvim`   |
| `shell/.fishrc`          | `~/.fishrc`        |

## Install on a new machine

With mise installed:

    env MISE_CONFIG_DIR=~/.dotfiles mise bootstrap --adopt bakatrouble/dotfiles

Or run `fish ~/.dotfiles/bootstrap.fish` after cloning. The script installs
mise if it is missing, and then adopts or applies this repository.

Check the result with `mise dot status`. Each target is a symlink into the
repo.

## Fish plugins

Plugins are listed in `fish/.config/fish/fish_plugins` and are not vendored.
Install or restore them with `fisher update`. `fisher` itself is kept in
`functions/` as the bootstrap. Tide is desktop-only and is listed in
`fish/.config/fish/fish_plugins_desktop`; `plugins_sync` installs it.

## Runtime state

`fish_variables*` and `secrets.fish` are written locally and git-ignored.

## Startup check

Each interactive fish shell fetches this repo (5 s timeout), offers to pull
updates with a `[Y/n]` prompt, and lists uncommitted changes and unpushed
commits. The check is `functions/custom/dotfiles_check.fish`, called from
`config.fish`.
