{stable, ...}: {
  home.packages = with stable; [
    bashmount
    calibre
    deluge
    sshfs-fuse
    vlc
  ];
}
