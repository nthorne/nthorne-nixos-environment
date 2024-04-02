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
    kdiff3
    lnav
    p7zip
    rr
    slack
    slock
    wget
    xdotool
    xorg.xbacklight
  ];
}
