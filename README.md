# dotfiles

This repository is the global [mise](https://mise.jdx.dev) config. Setting
`MISE_CONFIG_DIR=~/.dotfiles` points mise at it. `config.toml` maps each
target in `$HOME` to a source here:

| Source                  | Target              |
|-------------------------|---------------------|
| `files/config/fish`     | `~/.config/fish`    |
| `files/config/nvim`     | `~/.config/nvim`    |
| `files/config/git`      | `~/.config/git`     |
| `files/.fishrc`         | `~/.fishrc`         |
| `files/ssh/config`      | `~/.ssh/config`     |
| `files/ssh/hosts.d`     | `~/.ssh/hosts.d`    |

Everything under `files/` mirrors `$HOME`: `files/config/` is `~/.config`,
`files/ssh/` is `~/.ssh`, and the rest sits at the root of `files/`.

## Install on a new machine

Needs fish, git and curl. The one-liner downloads the `install.fish` stub, which
updates or clones `~/.dotfiles` and then runs `bootstrap.fish`:

    curl -fsS https://dotfiles.bakatrouble.me | fish

The script installs mise if it is missing, then adopts this repository into
`~/.dotfiles` and applies it. Run it from a checkout with `--dry-run` to preview
the mise step only.

Without the one-liner, with mise installed:

    env MISE_CONFIG_DIR=~/.dotfiles mise bootstrap --adopt bakatrouble/dotfiles

Check the result with `mise dot status`. Each target is a symlink into the
repo.

## Fish plugins

Plugins are listed in `files/config/fish/fish_plugins` and are not vendored.
Install or restore them with `fisher update`. `fisher` itself is kept in
`functions/` as the bootstrap. Tide is desktop-only and is listed in
`files/config/fish/fish_plugins_desktop`; `plugins_sync` installs it.

## Runtime state

`fish_variables*` and `secrets.fish` are written locally and git-ignored.

## Startup check

Each interactive fish shell fetches this repo (5 s timeout), offers to pull
updates with a `[Y/n]` prompt, and lists uncommitted changes and unpushed
commits. The check is `functions/custom/dotfiles_check.fish`, called from
`config.fish`.
