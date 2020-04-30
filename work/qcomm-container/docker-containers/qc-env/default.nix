with import <nixpkgs> { };

(import ../container.nix) {
  stdenv=stdenv;
  name = "qc-env";
  dockersource = (builtins.readFile ./Dockerfile);
  xhost = pkgs.xorg.xhost;
}
