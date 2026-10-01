{
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
