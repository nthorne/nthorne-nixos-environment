{ stable, lib, pkgs, ... }:
let
  utils = import ../../utils;
  insomnia-offloaded = utils.nvidia-offload pkgs stable.insomnia "insomnia";
in
{
  home.packages = with stable; [
    insomnia
    insomnia-offloaded
  ];
}
