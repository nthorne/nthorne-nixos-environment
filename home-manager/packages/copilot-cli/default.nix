{
  lib,
  pkgs,
  ...
}:
{
  home.file.".copilot/skills/caveman".source = ../copilot-cli/skills/caveman;
  home.file.".copilot/skills/excel-toolkit".source = ../copilot-cli/skills/excel-toolkit;
  home.file.".copilot/skills/executing-plan".source = ../copilot-cli/skills/executing-plan;
  home.file.".copilot/skills/grill-me".source = ../copilot-cli/skills/grill-me;
  home.file.".copilot/skills/hunk".source = ../copilot-cli/skills/hunk;
  home.file.".copilot/skills/mcp-builder".source = ../copilot-cli/skills/mcp-builder;
  home.file.".copilot/skills/nixos-host".source = ../copilot-cli/skills/nixos-host;
  home.file.".copilot/skills/obsidian-vault".source = ../copilot-cli/skills/obsidian-vault;
  home.file.".copilot/skills/skill-creator".source = ../copilot-cli/skills/skill-creator;

  home.file.".copilot/copilot-instructions.md".source = ./instructions/instructions.md;

  programs.github-copilot-cli = {
    enable = true;
    lspServers = {
      python = {
        command = "${lib.getExe pkgs.pyrefly}";
        args = [ "lsp" ];
        fileExtensions = {
          ".py" = "python";
          ".pyw" = "python";
          ".pyi" = "python";
        };
      };
      nix = {
        command = "${lib.getExe pkgs.nixd}";
        args = [ "lsp" ];
        fileExtensions = {
          ".nix" = "nix";
        };
      };
    };
  };
}
