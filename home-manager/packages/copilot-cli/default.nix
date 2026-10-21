{
  lib,
  pkgs,
  ...
}:
{
  home.file = {
    ".copilot/skills/caveman".source = ../copilot-cli/skills/caveman;
    ".copilot/skills/excel-toolkit".source = ../copilot-cli/skills/excel-toolkit;
    ".copilot/skills/executing-plan".source = ../copilot-cli/skills/executing-plan;
    ".copilot/skills/grill-me".source = ../copilot-cli/skills/grill-me;
    ".copilot/skills/hunk".source = ../copilot-cli/skills/hunk;
    ".copilot/skills/nixos-host".source = ../copilot-cli/skills/nixos-host;
    ".copilot/skills/obsidian-vault".source = ../copilot-cli/skills/obsidian-vault;
    ".copilot/skills/simplify-code".source = ../copilot-cli/skills/simplify-code;
    ".copilot/skills/skill-creator".source = ../copilot-cli/skills/skill-creator;

    ".copilot/copilot-instructions.md".source = ./instructions/instructions.md;

    # Under evaluation:
    ".copilot/skills/quiz-me".source = ../copilot-cli/skills/quiz-me;
    ".copilot/skills/reflect".source = ../copilot-cli/skills/reflect;
    ".copilot/skills/wait-what".source = ../copilot-cli/skills/wait-what;
  };

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
