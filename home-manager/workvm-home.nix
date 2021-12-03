{ config, pkgs, ... }:
let
  unstable = import <nixos-unstable> {};
in
{
  imports = [
    ./common.nix
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
  home.stateVersion = "21.11";

  # TODO: Figure out these odd developers' dependencies; are
  #   they because of a nvim plugin or something?
  home.packages = with pkgs; [
    bashdb      # Shell script debugger
    cppcheck    # Why did I have this one in my system config?
    ctags       # Why did I have this one in my system config?
    glances
    kdiff3
    lnav
    minicom
    p7zip
    tmuxinator  # I don't see the point in using `programs` here..
    wget
    xdotool
  ];

  # NOTE: If reverting to regular direnv, remember to reinstall ~/.direnrc
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;


  programs.kitty = {
    enable = true;

    extraConfig = ''
      font_family      JetBrains Mono
      bold_font        auto
      italic_font      auto
      bold_italic_font auto
      font_size        12.0

      # Solarized Dark
      background #002b36
      foreground #839496
      cursor #708183
      selection_background #073642
      color0 #002731
      color8 #001e26
      color1 #d01b24
      color9 #bd3612
      color2 #728905
      color10 #465a61
      color3 #a57705
      color11 #52676f
      color4 #2075c7
      color12 #708183
      color5 #c61b6e
      color13 #5856b9
      color6 #259185
      color14 #81908f
      color7 #e9e2cb
      color15 #fcf4dc
      selection_foreground #93a1a1
      '';
  };
}
