# Description

This repository contains my NixOS configuration files, as well
as some assorted dotfiles.

# Installation

```sh
sudo nixos-rebuild switch --flake .#<HOSTNAME>
```

# Secrets management

Secrets are managed using [sops-nix](https://github.com/Mic92/sops-nix), or
[git-agecrypt](https://github.com/vlaci/git-agecrypt), depending on whether
the secret is needed at build time or run time.

## Git-agecrypt

Add the file path to `.gitattribues`, and to `git-agecrypt.toml`

### Gotchas

`[filter "git-agecrypt"]` in `.git/config` might point to a non-existing binary
in case NixOS has been reinstalled or upgraded. To fix this, run:

```sh
git config --local filter.git-agecrypt.clean "$(which git-agecrypt) clean"
git config --local filter.git-agecrypt.smudge "$(which git-agecrypt) smudge"
```

## Keys

Age keys need to be stored in ~/.config/sops/age/keys.txt, and /etc/sops/age/keys.txt
(for vimes), as the home partition is decrypted at login.

## QCA9377 WiFi Firmware

To work around a broken ath10k driver, I've created a custom Nix package for the
QCA9377 WiFi firmware. This package copies the correct firmware binaries and is
included in the laptop's `hardware-configuration.nix`.

# Misc

## Fixing missing build environment dependency

I think that a dependency somehow got GC'd, even though it was
needed. To fix this, I ran the following command:

```sh
sudo nix-store --verify --check-contents --repair
just update default
```
