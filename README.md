# dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level
directory is a package whose tree mirrors `$HOME`:

| Package | Links to                   |
|---------|----------------------------|
| `fish`  | `~/.config/fish`           |
| `nvim`  | `~/.config/nvim`           |
| `shell` | `~/.fishrc`                |

## Install

    ./install.sh

Requires `stow`. The script removes old symlinks from the previous layout and
then runs `stow --restow`. It never deletes real files; a conflict is reported
by stow instead.

## Fish plugins

Plugins are listed in `fish/.config/fish/fish_plugins` and are not vendored.
Install or restore them with `fisher update`. `fisher` itself is kept in
`functions/` as the bootstrap.

## Runtime state

`fish_variables*` is written by fish and is git-ignored.
