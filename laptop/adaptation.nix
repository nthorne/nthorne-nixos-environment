{ config, pkgs, ... }:

let
  # This file contains non-public information.
  private = /etc/nixos/private.nix;
in
{
  imports =
    [
    ] ++ (if builtins.pathExists private then [ private ] else []);

  networking.hostName = "nixlaptop"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  environment.systemPackages = with pkgs; [
    bashmount
    calibre
    conky
    deluge
    dropbox
    dropbox-cli
    sshfsFuse
    vlc

    # Used in order to get deoplete up and running again, since
    # it requires a neovim python package that is not available
    # through Nix yet :/
    (python36.withPackages(ps: with ps; [ pip setuptools ]))
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.xserver.displayManager.sessionCommands = ''
  dropbox &
  '';

  services.xserver.synaptics = {
      enable = true;
      accelFactor = "0.1";
      fingersMap = [ 1 3 2 ];
      palmDetect = true;
  };

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
}

