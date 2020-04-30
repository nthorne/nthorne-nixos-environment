with import <nixpkgs> { };

(import ../container.nix) {
  stdenv=stdenv;
  name = "vts-env";
  dockersource = (builtins.readFile ./Dockerfile);
  xhost = pkgs.xorg.xhost;
}
