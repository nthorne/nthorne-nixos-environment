{ pkgs, ... }:
{
  home.packages = [
    (pkgs.callPackage ./cppclean {pkgs=pkgs;})
  ];
}
