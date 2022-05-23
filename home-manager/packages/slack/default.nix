{ unstable, lib, pkgs, ... }:
let
  utils = import ../../utils;
  slack-offloaded = utils.nvidia-offload pkgs unstable.slack-dark "slack";
in
{
  home.packages = with unstable; [
    slack-dark
    slack-offloaded
  ];
}
