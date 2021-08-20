{ pkgs, ... }:
let
  unstable = import <nixos-unstable> {};
in
{
  # This derivation should contain configurations that are common
  # to all profiles.
  home.packages = with pkgs; [
    unstable.neovim
  ];
}
