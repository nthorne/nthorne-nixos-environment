{pkgs, lib, ...}:
{
  imports = [
    ../../dotfiles/clion.nix
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "clion"
  ];

  home.packages = with pkgs; [
    jetbrains.clion
  ];
}
