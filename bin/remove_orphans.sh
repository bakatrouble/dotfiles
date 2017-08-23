#/bin/bash

orphans=`pacman -Qqdt`
if [[ -z $orphans ]]; then
  echo "No orphan packages, bye"
  exit 0
fi

sudo pacman -R $orphans
