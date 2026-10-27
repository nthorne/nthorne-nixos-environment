{
  flake-inputs,
  lib,
  pkgs,
  ...
}@args:
let
  eaSearch = pkgs.callPackage ./packages/ea-search.nix { };

  copilotWrapped = pkgs.writeShellScriptBin "copilot-wrapped" ''
    exec ${lib.getExe pkgs.github-copilot-cli} \
      --allow-tool awk \
      --allow-tool glob \
      --allow-tool grep \
      --allow-tool ls \
      --allow-tool readlink \
      --allow-tool sed \
      --allow-tool view \
      --add-dir ~/.copilot/memory \
      --add-dir ~/src/vcm5 \
      --add-dir ~/src/vcm5-local \
      --add-dir ~/repos/notes \
      "$@"
  '';
in
{
  imports = [
    (import ../../packages/copilot-cli args)
  ];

  config = {
    home.packages = with pkgs; [
      copilotWrapped
      entr
      hunk
      lnav
      obsidian
      xlsx2csv

      flake-inputs.robotcode.packages.${pkgs.stdenv.hostPlatform.system}.default
      eaSearch
    ];

    nixvim = {
      # We use GitHub Enterprise for Copilot Vim plugins ..
      useGHE = true;
      gheURL = "https://logisnext.ghe.com/";
    };

    tmux.codingagent = lib.getExe copilotWrapped;

    # Add the private notes repo as a Obsidian vault
    programs = {
      nixvim = {
        extraConfigLua = ''
          local lint = require("lint")
          lint.linters.robotcode = {
            cmd = "robotcode",
            args = { "analyze", "code", "-mi ImportContainsError" },
            stdin = false,
            ignore_exitcode = true,
            parser = require("lint.parser").from_pattern(
              "^(.+):(%d+):(%d+): %[([A-Z]+)%] (.+)$",
              { "file", "lnum", "col", "severity", "message" },
              {
                ["ERROR"] = vim.diagnostic.severity.ERROR,
                ["WARNING"] = vim.diagnostic.severity.WARN,
                ["INFO"] = vim.diagnostic.severity.INFO,
                ["HINT"] = vim.diagnostic.severity.HINT,
              },
              { source = "robotcode" }
            )
          }
          lint.linters_by_ft.robot = { "robotcode" }
        '';

        plugins = {
          obsidian.settings.workspaces = [
            {
              name = "private-notes";
              path = "/home/nthorne/repos/private-notes/";
            }
          ];
          lsp.servers.robotcode = {
            enable = true;
            package = flake-inputs.robotcode.packages.${pkgs.stdenv.hostPlatform.system}.default;
            # TODO: Figure out a good way to propagate the "right" pythonpath to the robotframework_ls server.
            cmd = [
              "robotcode"
              "language-server"
            ];
            filetypes = [
              "robot"
              "resource"
            ];
          };
        };
      };

      ssh = {
        enable = true;
        enableDefaultConfig = false;

        settings = {
          "github.com" = {
            hostname = "ssh.github.com";
            port = 443;
            user = "git";
          };
        };
      };
    };

  };
}
