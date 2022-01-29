{ config, pkgs, ... }:

let
  # This file contains non-public information.
  private = /etc/nixos/private.nix;
in
{
  imports =
    [
    ] ++ (if builtins.pathExists private then [ private ] else []);

  # TODO: Got remark on this wile upgrading to 21.05, that there could be
  #       random failures (which there are).
  #networking.wireless.interfaces = "wlp1s0";

  environment.systemPackages = with pkgs; [
    dropbox
    dropbox-cli

    # Used in order to get deoplete up and running again, since
    # it requires a neovim python package that is not available
    # through Nix yet :/
    (python37.withPackages(ps: with ps; [ pip setuptools ]))
  ];



  networking.hostName = "nixlaptop"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  boot.loader = {
    # Use the GRUB 2 boot loader.
    grub = {
      enable = true;
      version = 2;

      # Define on which hard drive you want to install Grub.
      device = "/dev/sda"; # or "nodev" for efi only

      # efiSupport = true;
      # efiInstallAsRemovable = true;
    };

    # efi.efiSysMountPoint = "/boot/efi";
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.xserver.displayManager = {
    sessionCommands = ''
      dropbox &
    '';

    autoLogin = {
      enable = true;
      user = "nthorne";
    };
  };


  services.xserver.synaptics = {
      enable = true;
      accelFactor = "0.1";
      fingersMap = [ 1 3 2 ];
      palmDetect = true;
  };

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
  nixpkgs.config.pulseaudio = true;
  users.extraUsers.nthorne.extraGroups = [ "wheel" "audio" "docker" "dialout" ];

  virtualisation.docker.enable = true;
}

