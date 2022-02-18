{ config, stable, ... }:
{
  home.packages = with stable; [
    bashmount
    calibre
    deluge
    sshfsFuse
    vlc
  ];
}
