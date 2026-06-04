---
name: nixos-host
description: Details how to use the `nix shell` or `nix-shell` command to run ephemeral packages that is needed for different tasks, if those packages are not available on this NixOS system with flakes enabled. Any time you want to run something more complex than a simple POSIX shell command, such as a Python script, use this skill to determine how to run it properly.

---
  
# NixOS Environment

## Overview

This host is a NixOS system with flakes enabled. This means package management and environment setup work differently than traditional Linux distributions.

## Core Concepts

1. **Immutable System**: Packages are not installed globally via traditional package managers (apt, yum, etc.). System packages are declared in Nix configuration files.
2. **Flakes Enabled**: The system uses Nix flakes for reproducible configurations.
3. **Ephemeral Environments**: Use `nix-shell` or `nix shell` to temporarily add packages without installing them permanently, or use `nix run` for one-off commands.

## Running Scripts with Dependencies

When you need to run a script that requires packages (like Python, Node.js, Ruby, etc.) that may not be installed system-wide, use ephemeral environments:

### Using nix run (flakes, preferred for single-package commands)
```bash
nix run nixpkgs#python3 -- script.py
nix run nixpkgs#nodejs -- script.js
nix run nixpkgs#bash -- script.sh
```

### Using nix shell (flakes, for multiple packages or custom commands)
```bash
# When you need multiple packages (e.g., Python + libraries)
nix shell nixpkgs#python3 nixpkgs#python3Packages.requests -c python3 script.py

# When running non-default commands
nix shell nixpkgs#nodejs nixpkgs#yarn -c yarn install
```

### Using nix-shell (legacy, still works)
```bash
nix-shell -p python3 --run "python3 script.py"
nix-shell -p python3 python3Packages.requests --run "python3 script.py"
```

### Interactive Shells
```bash
# Drop into a shell with packages available
nix shell nixpkgs#python3 nixpkgs#python3Packages.requests
# Or legacy: nix-shell -p python3 python3Packages.requests
```

## Common Patterns

- **Python scripts**: `nix run nixpkgs#python3 -- script.py`
- **Python with libraries**: `nix shell nixpkgs#python3 nixpkgs#python3Packages.requests -c python3 script.py`
- **Node.js scripts**: `nix run nixpkgs#nodejs -- script.js`
- **Shell scripts with tools**: `nix shell nixpkgs#curl nixpkgs#jq -c bash script.sh`
- **Compilation**: `nix shell nixpkgs#gcc nixpkgs#gnumake -c make`

## Key Rules

1. **Don't assume packages are installed**: Always check if a command exists before running it, or wrap it with `nix run` or `nix shell`.
2. **Prefer `nix run` for single-package commands**: Use `nix run nixpkgs#python3 -- script.py` when you only need one tool.
3. **Use `nix shell` for multiple dependencies**: Use `nix shell nixpkgs#python3 nixpkgs#python3Packages.requests -c python3 script.py` when you need multiple packages.
4. **Check system packages first**: Use `which <command>` or `command -v <command>` to check if a tool is already available.
5. **Package names**: Use `nix search nixpkgs <term>` to find package names if unsure.

## Examples

### User: "Run this Python script that uses requests library"
**Action**: 
1. Check if Python is available: `which python3`
2. If not, or if requests is needed: `nix shell nixpkgs#python3 nixpkgs#python3Packages.requests -c python3 script.py`

### User: "Run this simple Python script"
**Action**: `nix run nixpkgs#python3 -- script.py`

### User: "Install jq and use it"
**Action**: Don't permanently install. Instead: `nix run nixpkgs#jq -- -r '.field' data.json`

### User: "I need to compile this C program"
**Action**: `nix shell nixpkgs#gcc -c gcc -o program program.c`
