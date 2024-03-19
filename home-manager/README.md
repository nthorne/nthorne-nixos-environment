# About

This repository contains my home manager configurations.

# Installation

First symlink the home manager declaration into place:
    $ ln -s ${PWD}/home.nix ${HOME}/.config/nixpkgs/home.nix

Then install home manager:

    $ nix-channel --add https://github.com/rycee/home-manager/archive/release-21.11.tar.gz home-manager
    $ nix-channel --update
    # Logoff might be required for these settings to take effect
    $ nix-shell '<home-manager>' -A install

To build and install the home environment:

    $ home-manager switch

# Updating

    $ nix flake update-lock-file .#
    $ _ nixos-rebuild build --flake .#
    $ _ nixos-rebuild switch --flake .#

To see what an upgrade will bring in

    $ nvd diff nix/var/nix/profiles/system result
