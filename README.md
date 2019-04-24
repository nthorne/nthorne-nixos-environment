# Description

This repository contains my NixOS configuration files, as well
as some assorted dotfiles.

# Installation

    sudo rm /etc/nixos/configuration.nix
    sudo ln -s $PWD/configuration.nix /etc/nixos/

Symlink the adaptation nix file in to place, if applicable; e.g.

    sudo ln -s $PWD/laptop/adaptation.nix /etc/nixos/

if the target is my home laptop.

Symlink any dotfiles into the appropriate place; e.g.

    ln -s $PWD/dotfiles/.direnvrc $HOME/

## Temporary

In order to fix broken ath10k driver, I also copied the firmware-5.bin from
/nix/store/ for the QCA9377 that was closest to december, and added a nix
package for it, and included that package within `hardware-configuration.nix`.
This change should be reverted once the driver issue has been fixed for NixOS.
