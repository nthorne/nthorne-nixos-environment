{ pkgs, ... }:
{
  home.packages = [
    (pkgs.callPackage ./cppclean {})
  ];
}
