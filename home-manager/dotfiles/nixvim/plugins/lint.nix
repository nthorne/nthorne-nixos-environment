{pkgs, lib, ...}: {
  programs.nixvim = {
    plugins = {
      lint = {
        enable = true;
        linters = {
          mypy = {
            cmd = lib.getExe pkgs.mypy;
          };
        };
        lintersByFt = {
          python = [
            "ruff"
            "mypy"
          ];
        };
      };
    };
  };
}
