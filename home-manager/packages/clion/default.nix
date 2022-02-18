{ stable, lib, ... }:
{
  imports = [
    ../../dotfiles/clion.nix
  ];

  home.packages = with stable; [
    jetbrains.clion
  ];
}
