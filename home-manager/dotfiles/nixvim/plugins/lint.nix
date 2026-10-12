{ pkgs, lib, ... }: {
  programs.nixvim = {
    plugins = {
      lint = {
        enable = true;
        linters = {
          deadnix = {
            cmd = lib.getExe pkgs.deadnix;
          };
          mypy = {
            cmd = lib.getExe pkgs.mypy;
          };
          statix = {
            cmd = lib.getExe pkgs.statix;
          };
          vale = {
            cmd = lib.getExe pkgs.vale;
          };
        };
        lintersByFt = {
          markdown = [
            "vale"
          ];
          nix = [
            "statix"
            "deadnix"
          ];
          python = [
            "ruff"
            "mypy"
          ];
          sh = [
            "shellcheck"
          ];
        };
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>li";
        action = "<cmd>lua require('lint').try_lint()<CR>";
        options.desc = "Run [L]int";
      }
    ];
  };

  home.file = {
    ".vale.ini".text = ''
MinAlertLevel = suggestion
SkippedScopes = script, style, pre, figure, blockquote

[*.md]
BasedOnStyles = Vale
    '';
  };
}
