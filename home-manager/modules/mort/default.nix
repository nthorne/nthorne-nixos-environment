{
  pkgs,
  ...
} @ args:
{
  imports = [
    (import ../../packages/copilot-cli args)
  ];

  config = {
    home.packages =
      with pkgs;
      [
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
