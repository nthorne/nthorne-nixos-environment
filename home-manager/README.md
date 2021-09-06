# About

This repository contains my home manager configurations.

# Installation


First symlink this subfolder into place:
    $ ln -s ${PWD}/workvm-home.nix ${HOME}/.config/nixpkgs/home.nix

Then install home manager:

    $ nix-channel --add https://github.com/rycee/home-manager/archive/release-20.09.tar.gz home-manager
    $ nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
    $ nix-channel --update
    # Logoff might be required for these settings to take effect
    $ nix-shell '<home-manager>' -A install

To build and install the home environment:

    $ home-manager switch