{ unstable, lib, pkgs, ... }:
let
  utils = import ../../utils;
  teams-offloaded = utils.nvidia-offload pkgs unstable.teams "teams";
in
{
  home.packages = with unstable; [
    unstable.teams
    teams-offloaded
  ];
}
