{ config, pkgs, lib, ... }:
#
# TODO:
#
# * Migrate tmux config here
# * Migrate xmonad config here
# * Restructure subfolders. Inconsistencies in default.nix vs named.nix
#
let
  unstable = import <nixos-unstable> {config={allowUnfree=true;};};
in
{
  imports = [
    ./common.nix
    ./dotfiles/conky.nix
    ./packages/clion
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
  ];
}
