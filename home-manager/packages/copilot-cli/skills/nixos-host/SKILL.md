---
name: nixos-host
description: >
  Run one-off tools and scripts in temporary Nix environments on NixOS when required executables
  or dependencies are unavailable, including Python or Node.js tasks. Also use when asked how to
  use `nix shell` or `nix run`. Do not trigger for ordinary shell commands, NixOS or Home Manager
  configuration edits, or projects with their own documented development environment.
---

# Temporary Nix Environments

Use project-provided environments first (`nix develop`, `direnv`, or documented setup). For
one-off tasks, use Nix-provided tools without installing packages globally.

- Run an available command directly. Check `command -v <tool>` only when availability is unclear
  or command fails; do not probe PATH by default.
- Use `nix run` for one package and one command.
- Use `nix shell` when command needs multiple packages or libraries.
- Use `nix-shell` only when project instructions require it or flakes are unavailable.
- Find uncertain package names with `nix search nixpkgs <term>`.

## Examples

```bash
# Single tool
nix run nixpkgs#jq -- -r '.field' data.json

# Script needing one runtime
nix run nixpkgs#python3 -- script.py

# Python script needing external library
nix shell nixpkgs#python3 nixpkgs#python3Packages.requests -c python3 script.py

# Command needing multiple tools
nix shell nixpkgs#curl nixpkgs#jq -c bash -c 'curl -s https://example.com/data.json | jq .'
```

For an interactive environment, omit `-c <command>` and exit the resulting shell when finished.
Use `nix-shell -p <package> --run '<command>'` only for legacy project instructions.

If a command fails because a package is missing, report the failure and adjust package selection;
do not silently switch to a global installation.

## Permanent installation

For a package meant to remain installed, update the appropriate NixOS or Home Manager
configuration instead of using an ephemeral shell. Rebuild and activate the intended host config
using the repository's documented workflow.
