#!/usr/bin/env bash

# Remove old gtk themes to replace with ours
if [ -e "$HOME/.config/gtk-3.0" ]; then
  rm -f "$HOME/.config/gtk-3.0/settings.ini"
fi

if [ -e "$HOME/.config/gtk-4.0" ]; then
  rm -f "$HOME/.config/gtk-4.0/settings.ini"
fi

# Set cwd
DIR=$(pwd)
# Copy hardware configuration to install with
cp -f /etc/nixos/hardware-configuration.nix "$DIR"/nixos/

# Copy my wallpapers into home folder
if [ ! -f ~/wallpapers ]; then
  cp -rf "$DIR"/home/wallpapers ~
fi

# Build system
sudo nixos-rebuild switch --flake . --show-trace
