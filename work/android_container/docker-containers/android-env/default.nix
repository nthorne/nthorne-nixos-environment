with import <nixpkgs> { };

(import ../container.nix) {
  stdenv=stdenv;
  name = "android-env";
  dockersource = (builtins.readFile ./Dockerfile);
  xhost = pkgs.xorg.xhost;
}
