# Agent Guidelines - NixOS Environment Configuration

## Build/Test Commands
- **Build**: `just build` (builds system configuration)
- **Test**: `just test` (builds and tests without switching)
- **Switch**: `just switch` (builds and switches system)
- **Format**: `nix fmt` (formats all .nix files using nixfmt-rfc-style)
- **Single test**: No specific single test framework - this is a NixOS system configuration

## Code Style
- **Language**: Nix expressions for system configuration
- **Formatting**: Use `nixfmt-rfc-style` formatter (configured in flake.nix:146)
- **Imports**: Follow existing patterns with `{pkgs, ...}:` or `{lib, pkgs, ...}:` syntax
- **Function style**: Use `let...in` blocks for complex configurations
- **Comments**: Use `#` for inline comments, avoid block comments unless necessary
- **Naming**: Use kebab-case for files, camelCase for Nix attributes
- **Strings**: Prefer double quotes, use `''` for multiline strings

## Project Structure
- System configs in root (configuration.nix, flake.nix)
- Host-specific configs in `work/`, `laptop/`, `hex/` directories
- Home-manager configs in `home-manager/` with dotfiles and modules
- Packages defined in `home-manager/packages/`
- Scripts in `home-manager/scripts/`

## Error Handling
- Use `lib.mkForce` for overrides when necessary
- Prefer conditional expressions with `lib.mkIf` for optional features
- Handle missing packages gracefully with null checks where appropriate