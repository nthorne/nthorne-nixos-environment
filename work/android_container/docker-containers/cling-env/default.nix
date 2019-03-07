with import <nixpkgs> { };

(import ../container.nix) {
  stdenv=stdenv;
  name = "cling-env";
  dockersource = (builtins.readFile ./Dockerfile);
  xhost = pkgs.xorg.xhost;
}
