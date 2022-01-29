{ pkgs, ...}:
{
  imports = [
    ./conky.nix
    ./tmux.nix
    ./xmonad.nix
  ];
}
