{
  pkgs,
  ...
}: let
in {
  home.packages = [
    pkgs.github-copilot-cli
  ];

  home.file.".copilot/skills/nixos-environment/SKILL.md" = {
    text = ''
---
name: nixos-environment
description: 'Understand that you are running on a NixOS system with flakes enabled. Use nix-shell or nix shell for ephemeral packages when running scripts that require dependencies not installed system-wide.'
---

# NixOS Environment

## Overview

You are running on a NixOS system with flakes enabled. This means package management and environment setup work differently than traditional Linux distributions.

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
    '';
  };

  home.file.".copilot/skills/nuget-manager/SKILL.md" = {
    text = ''
---
name: nuget-manager
description: 'Manage NuGet packages in .NET projects/solutions. Use this skill when adding, removing, or updating NuGet package versions. It enforces using `dotnet` CLI for package management and provides strict procedures for direct file edits only when updating versions.'
---

# NuGet Manager

## Overview

This skill ensures consistent and safe management of NuGet packages across .NET projects. It prioritizes using the `dotnet` CLI to maintain project integrity and enforces a strict verification and restoration workflow for version updates.

## Prerequisites

- .NET SDK installed (typically .NET 8.0 SDK or later, or a version compatible with the target solution).
- `dotnet` CLI available on your `PATH`.
- `jq` (JSON processor) OR PowerShell (for version verification using `dotnet package search`).

## Core Rules

1.  **NEVER** directly edit `.csproj`, `.props`, or `Directory.Packages.props` files to **add** or **remove** packages. Always use `dotnet add package` and `dotnet remove package` commands.
2.  **DIRECT EDITING** is ONLY permitted for **changing versions** of existing packages.
3.  **VERSION UPDATES** must follow the mandatory workflow:
    - Verify the target version exists on NuGet.
    - Determine if versions are managed per-project (`.csproj`) or centrally (`Directory.Packages.props`).
    - Update the version string in the appropriate file.
    - Immediately run `dotnet restore` to verify compatibility.

## Workflows

### Adding a Package
Use `dotnet add [<PROJECT>] package <PACKAGE_NAME> [--version <VERSION>]`.
Example: `dotnet add src/MyProject/MyProject.csproj package Newtonsoft.Json`

### Removing a Package
Use `dotnet remove [<PROJECT>] package <PACKAGE_NAME>`.
Example: `dotnet remove src/MyProject/MyProject.csproj package Newtonsoft.Json`

### Updating Package Versions
When updating a version, follow these steps:

1.  **Verify Version Existence**:
    Check if the version exists using the `dotnet package search` command with exact match and JSON formatting. 
    Using `jq`:
    `dotnet package search <PACKAGE_NAME> --exact-match --format json | jq -e '.searchResult[].packages[] | select(.version == "<VERSION>")'`
    Using PowerShell:
    `(dotnet package search <PACKAGE_NAME> --exact-match --format json | ConvertFrom-Json).searchResult.packages | Where-Object { $_.version -eq "<VERSION>" }`
    
2.  **Determine Version Management**:
    - Search for `Directory.Packages.props` in the solution root. If present, versions should be managed there via `<PackageVersion Include="Package.Name" Version="1.2.3" />`.
    - If absent, check individual `.csproj` files for `<PackageReference Include="Package.Name" Version="1.2.3" />`.

3.  **Apply Changes**:
    Modify the identified file with the new version string.

4.  **Verify Stability**:
    Run `dotnet restore` on the project or solution. If errors occur, revert the change and investigate.

## Examples

### User: "Add Serilog to the WebApi project"
**Action**: Execute `dotnet add src/WebApi/WebApi.csproj package Serilog`.

### User: "Update Newtonsoft.Json to 13.0.3 in the whole solution"
**Action**:
1. Verify 13.0.3 exists: `dotnet package search Newtonsoft.Json --exact-match --format json` (and parse output to confirm "13.0.3" is present).
2. Find where it's defined (e.g., `Directory.Packages.props`).
3. Edit the file to update the version.
4. Run `dotnet restore`.
    '';
  };
}
