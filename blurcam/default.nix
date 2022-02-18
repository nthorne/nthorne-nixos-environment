{ pkgs ? import <nixpkgs> {} }:
(pkgs.buildFHSUserEnv {
  name = "pipzone";
  targetPkgs = pkgs: (with pkgs; [
    python39
    python39Packages.pip
    python39Packages.virtualenv
    gcc10
    libglvnd
  ]);
  runScript = "bash";
}).env
