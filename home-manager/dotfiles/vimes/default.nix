{ pkgs, ...}:
{
  imports = [
    ./conky.nix
    ./gitconfig.nix
    ./tmux.nix
    ./xmonad.nix
  ];
}
