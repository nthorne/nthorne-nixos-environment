{ config, pkgs, ... }:
{
  imports = [
    ./dotfiles
    ./packages
    ./scripts
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "nthorne";
  home.homeDirectory = "/home/nthorne";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";

  # TODO: Figure out these odd developers' dependencies; are
  #   they because of a nvim plugin or something?
  home.packages = with pkgs; [
    bashdb    # Shell script debugger
    cppcheck  # Why did I have this one in my system config?
    ctags     # Why did I have this one in my system config?
    kdiff3
    lnav
    minicom
    p7zip
    wget
    xdotool
  ];
}
