{ unstable, lib, pkgs, ... }:
let
  utils = import ../../utils;
  slack-offloaded = utils.nvidia-offload pkgs unstable.slack "slack";
in
{
  home.packages = with unstable; [
    slack
    slack-offloaded
  ];
}
