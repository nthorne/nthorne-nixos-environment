{ config, lib, pkgs, ... }:

let
  # Wraps the standard docker builder function with some defaults
  stdDockerBuilder = name: dockerfile: pkgs.callPackage ./lib/builder.nix {pkgs=pkgs; name=name; dockersource=(builtins.readFile dockerfile);};

  # Wraps the standard docker runner with some defaults
  stdDockerRunner = name: pkgs.callPackage ./lib/runner.nix {pkgs=pkgs; name=name; xhost=pkgs.xorg.xhost;};
in
{
  environment.systemPackages = with pkgs; [
    docker
    xorg.xhost

    (stdDockerBuilder "android-env" ./declarations/android-env/Dockerfile)
    (stdDockerRunner  "android-env")

    (stdDockerBuilder "cling-env" ./declarations/cling-env/Dockerfile)
    (stdDockerRunner  "cling-env")

    (stdDockerBuilder "vts-env" ./declarations/vts-env/Dockerfile)
    (stdDockerRunner  "vts-env")

    (stdDockerBuilder "qc-env" ./declarations/qc-env/Dockerfile)
    (pkgs.callPackage ./lib/runner.nix {pkgs=pkgs; name="qc-env"; xhost=pkgs.xorg.xhost; extras = ''
        -v /mnt/external:/mnt/external \
        -e HEXAGON_ROOT=/pkg/qct/software/hexagon/releases/tools
        '';})
  ];

  virtualisation.docker.enable = true;
  # The insecure-registry entries, and the first dns entry is for nexus.
  #virtualisation.docker.extraOptions = "--insecure-registry nexus.android.delphiauto.net:5050 --insecure-registry nexus.android.delphiauto.net:5000 --dns 10.236.88.104";
  # For docker build
  virtualisation.docker.extraOptions = "--dns 10.192.40.20 --dns 10.192.40.33";
}
