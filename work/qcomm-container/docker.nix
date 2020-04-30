{ config, lib, pkgs, ... }:

{
  imports = [ ];

  environment.systemPackages = with pkgs; [
    docker
    (import ./docker-containers/qc-env)
  ];

  virtualisation.docker.enable = true;
}
