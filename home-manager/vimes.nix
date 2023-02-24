args@{ stable, unstable, lib, ... }:
#
# TODO:
#
# * Restructure subfolders. Inconsistencies in default.nix vs named.nix
#
{
  imports = [
    (import ./packages/clion args)
    (import ./packages/insomnia args)
    (import ./packages/teams args)
    (import ./packages/slack args)
  ];

  # TODO: Figure out these odd developers' dependencies; are
  #   they because of a nvim plugin or something?
  home.packages = with stable; [
    bashdb      # Shell script debugger
    cppcheck    # Why did I have this one in my system config?
    ctags       # Why did I have this one in my system config?
    gdb
    glances
    jetbrains.rider
    kdiff3
    lnav
    p7zip
    rr
    slock
    vagrant
    wget
    xdotool
    xorg.xbacklight

    # Evaluation
    rnix-lsp
  ];
}
