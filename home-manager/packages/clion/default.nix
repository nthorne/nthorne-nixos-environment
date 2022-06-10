{ stable, lib, ... }:
{
  imports = [
    ../../dotfiles/clion.nix
  ];

  # Pin this in a nix shell instead; apparently needed now for
  # clion to have access to e.g. conan
  #home.packages = with stable; [
  #  jetbrains.clion
  #];
}
