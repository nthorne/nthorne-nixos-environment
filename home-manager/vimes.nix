args@{ stable, unstable, lib, ... }:
#
# TODO:
#
# * Restructure subfolders. Inconsistencies in default.nix vs named.nix
#
{
  imports = [
    (import ./packages/clion args)
  ];

  # TODO: Figure out these odd developers' dependencies; are
  #   they because of a nvim plugin or something?
  home.packages = with stable; [
    bashdb      # Shell script debugger
    cppcheck    # Why did I have this one in my system config?
    ctags       # Why did I have this one in my system config?
    glances
    kdiff3
    lnav
    p7zip
    slock
    wget
    xdotool

    # Evaluation
    # Teams and Slack must be executed with nvidia-offload, write
    # a function that generates a wrapper script for this.
    unstable.teams
    unstable.slack-dark
    vagrant
    insomnia
    thunderbird
    xorg.xbacklight
    gdb
    rr
    jetbrains.rider
    jetbrains.pycharm-community

    # For trying out flakes
    (pkgs.writeShellScriptBin "nixFlakes" ''
      exec ${pkgs.nixFlakes}/bin/nix --experimental-features "nix-command flakes" "$@"
    '')
  ];
}
