{ config, lib, pkgs, ... }:

{
  imports = [ ];

  environment.systemPackages = with pkgs; [
    docker
    (import ./docker-containers/android-env)
    (import ./docker-containers/cling-env)
    (import ./docker-containers/vts-env)
  ];

  virtualisation.docker.enable = true;
}
