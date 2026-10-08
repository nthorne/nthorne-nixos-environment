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
        };
        lintersByFt = {
          nix = [
            "statix"
            "deadnix"
          ];
          python = [
            "ruff"
            "mypy"
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
}
