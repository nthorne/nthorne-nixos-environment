{pkgs, ...}: {
  home.packages = with pkgs; [
    bashmount
    calibre
    deluge
    sshfs-fuse
    vlc
  ];
}
