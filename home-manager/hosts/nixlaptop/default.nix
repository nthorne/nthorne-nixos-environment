{
  pkgs,
  ...
}@args:
{
  imports = [
    (import ../workstation.nix args)
  ];

  home.packages = with pkgs; [
    bashmount
    deluge
    obsidian
    sshfs-fuse
  ];
}
