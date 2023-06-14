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

  home.packages = with stable; [
    bashdb
    cppcheck
    ctags
    gdb
    glances
    insomnia
    jetbrains.rider
    kdiff3
    lnav
    p7zip
    rr
    slack
    slock
    unstable.teams
    vagrant
    wget
    xdotool
    xorg.xbacklight

    # Evaluation
    rnix-lsp
  ];
}
