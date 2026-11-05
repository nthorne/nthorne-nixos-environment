# Agent Guidelines — NixOS Environment

## Build and validation

- `just build` builds current host configuration without activating it.
- `just test` builds and activates configuration for testing without changing boot default.
- `just switch` activates configuration. It requires a clean Git worktree and tags the current
  system generation first; run only when the user explicitly asks to switch.
- `nix fmt` formats Nix files with the flake's `nixfmt-rfc-style` formatter.
- After NixOS or Home Manager changes, evaluate the full configuration for every affected host.
  Flake outputs include `vimes`, `nixlaptop`, `hex`, and `mort`; VM outputs include `vimes-vm`
  and `nixlaptop-vm`.

For example, evaluate `vimes` with:

```sh
nix eval --raw .#nixosConfigurations.vimes.config.system.build.toplevel.drvPath
```

Repeat for each affected host. This repository has no separate single-test framework.

## Code style

- Write Nix expressions and format them with `nixfmt-rfc-style` via `nix fmt`.
- Follow existing module patterns, including argument sets such as `{ pkgs, ... }:`.
- Use `let ... in` for local bindings when they clarify nontrivial expressions.
- Use `lib.mkIf` for conditional features; reserve `lib.mkForce` for intentional priority
  overrides. Avoid masking invalid required configuration with silent fallbacks.
- Use `#` comments sparingly. Prefer kebab-case filenames and existing attribute naming conventions.
- Prefer double-quoted strings; use `''` for multiline strings.

## Project layout

- Shared NixOS configuration: root `flake.nix`, `configuration.nix`, `desktop.nix`, and settings
  modules.
- Host-specific system and hardware configuration: `hosts/`. The `nixlaptop` flake output uses
  files under `hosts/laptop/`.
- Shared Home Manager configuration and dotfiles: `home-manager/home.nix` and
  `home-manager/dotfiles/`.
- Host-specific Home Manager modules, dotfiles, packages, and scripts:
  `home-manager/hosts/<hostname>/`.
- Home Manager package definitions: `home-manager/packages/`.

## GitHub workflow

- Reference the issue in branch or PR descriptions when applicable.
- Commit, push, or create a pull request only when the user explicitly asks.
- Never push directly to `main`.
