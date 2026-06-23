#!/bin/sh

cd $HOME
ln -sf .dotfiles/.fishrc .fishrc
rm -rf .config/fish .config/nvim
ln -sf ../.dotfiles/.config/fish .config/fish
ln -sf ../.dotfiles/.config/nvim .config/nvim
