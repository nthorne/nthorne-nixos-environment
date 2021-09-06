{ pkgs, ... }:
let
  unstable = import <nixos-unstable> {};
in
{
  # This derivation should contain configurations that are common
  # to all profiles.
  home.packages = with pkgs; [
    ag
    evince
    fasd
    fd
    file
    gparted
    htop
    hyperfine
    irssi
    qalculate-gtk
    ranger
    shellcheck
    tldr
    tmux
    tree
    xsel
    yank

    unstable.firefox
    unstable.neovim
  ];
}
