{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    bashmount
    calibre
    deluge
    sshfsFuse
    vlc
  ];
}
