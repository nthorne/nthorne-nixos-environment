{ config, pkgs, ... }:

{
  networking.hostName = "nixlaptop"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  environment.systemPackages = with pkgs; [
    afuse
    bashmount
    calibre
    conky
    deluge
    dropbox
    dropbox-cli
    sshfsFuse
    vlc
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
}

