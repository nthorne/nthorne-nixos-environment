{ config, lib, pkgs, ... }:

{
  imports = [ ];

  environment.systemPackages = with pkgs; [
    docker
    (import ./docker-containers/android-env)
    (import ./docker-containers/cling-env)
  ];

  virtualisation.docker.enable = true;
}
