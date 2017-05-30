# Description

This repository contains my NixOS configuration files, as well
as some assorted dotfiles.

# Installation

    sudo rm /etc/nixos/configuration.nix
    sudo ln -s $PWD/configuration.nix /etc/nixos/

Symlink the adaptation nix file in to place, if applicable; e.g.

    sudo ln -s $PWD/laptop/adaptation.nix /etc/nixos/

if the target is my home laptop.
