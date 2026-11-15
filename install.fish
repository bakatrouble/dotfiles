#!/usr/bin/env fish
# Stub for the one-liner:
#
#   curl -fsS https://dotfiles.bakatrouble.me | fish
#
# Short links and raw.githubusercontent.com cache this file for minutes, so it
# stays small and changes rarely. The real logic is bootstrap.fish in the repo,
# which git brings up to date on every run.

set -l repo $HOME/.dotfiles
set -l url https://github.com/bakatrouble/dotfiles.git

if not command -q git
    echo "install: git is required." >&2
    exit 1
end

if test -d $repo/.git
    # Existing checkout: fast-forward only. Local changes that the pull would
    # overwrite make it fail; nothing is reset or discarded.
    git -C $repo pull --ff-only --quiet </dev/null; or begin
        echo "install: $repo could not be fast-forwarded (local changes or diverged history). Not touching it; resolve that and run this again." >&2
        exit 1
    end
else if test -e $repo
    echo "install: $repo exists and is not a git checkout. Move it aside and run this again." >&2
    exit 1
else
    git clone --quiet $url $repo </dev/null; or begin
        echo "install: clone of $url failed." >&2
        exit 1
    end
end

exec fish $repo/bootstrap.fish $argv
