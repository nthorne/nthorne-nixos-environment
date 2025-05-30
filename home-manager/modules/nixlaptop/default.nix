{pkgs, ...} @ args: {
  imports = [
    (import ../workstation.nix args)
  ];

  home.packages = with pkgs; [
    bashmount
    calibre
    deluge
    sshfs-fuse
    vlc
  ];
}
