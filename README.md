# Description

This repository contains my NixOS configuration files, as well
as some assorted dotfiles.

# Installation

```sh
sudo nixos-rebuild switch --flake .#<HOSTNAME>
```

## Temporary

In order to fix broken ath10k driver, I also copied the firmware-5.bin from
/nix/store/ for the QCA9377 that was closest to december, and added a nix
package for it, and included that package within `hardware-configuration.nix`.
This change should be reverted once the driver issue has been fixed for NixOS.
