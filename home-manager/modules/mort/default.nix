{
  flake-inputs,
  lib,
  pkgs,
  ...
} @ args:
let
  copilotWrapped = pkgs.writeShellScriptBin "copilot-wrapped" ''
    exec ${lib.getExe pkgs.github-copilot-cli} \
      --allow-tool view \
      --allow-tool grep \
      --allow-tool glob \
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
    home.packages =
      with pkgs;
      [
        copilotWrapped
        entr
        hunk
        lnav
        xlsx2csv

        flake-inputs.robotcode.packages.${pkgs.system}.default
      ];

    nixvim = {
      # We use GitHub Enterprise for Copilot Vim plugins ..
      useGHE = true;
      gheURL = "https://logisnext.ghe.com/";
    };

    tmux.codingagent = "copilot-wrapped";

    # Add the private notes repo as a Obsidian vault
    programs.nixvim.plugins.obsidian.settings.workspaces = [
      {
        name = "private-notes";
        path = "/home/nthorne/repos/private-notes/";
      }
    ];

    programs.nixvim.plugins.lsp.servers.robotframework_ls = {
      enable = true;
      package = flake-inputs.robotcode.packages.${pkgs.system}.default;
      # TODO: Figure out a good way to propagate the "right" pythonpath to the robotframework_ls server.
      cmd = [ "robotcode" "language-server" ];
      filetypes = [ "robot" "resource" ];
    };

    programs.ssh = {
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
}
