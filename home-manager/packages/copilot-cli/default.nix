{
  lib,
  pkgs,
  ...
}:
{
  home.file.".copilot/skills".source = ./skills;
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
