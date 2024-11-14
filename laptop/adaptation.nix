{ config, pkgs, ... }:

let
  # This file contains non-public information.
  private = /etc/nixos/private.nix;
in
{
  imports = [ ] ++ (if builtins.pathExists private then [ private ] else [ ]);

  environment.systemPackages = with pkgs; [
    # Used in order to get deoplete up and running again, since
    # it requires a neovim python package that is not available
    # through Nix yet :/
    (python310.withPackages (
      ps: with ps; [
        pip
        setuptools
      ]
    ))
  ];

  networking.hostName = "nixlaptop"; # Define your hostname.
  networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  boot.loader = {
    # Use the GRUB 2 boot loader.
    grub = {
      enable = true;

      # Define on which hard drive you want to install Grub.
      device = "/dev/sda"; # or "nodev" for efi only

      # efiSupport = true;
      # efiInstallAsRemovable = true;
    };

    # efi.efiSysMountPoint = "/boot/efi";
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.displayManager.autoLogin = {
    enable = true;
    user = "nthorne";
  };

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
  nixpkgs.config.pulseaudio = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  users.extraUsers.nthorne.extraGroups = [
    "wheel"
    "audio"
    "docker"
    "dialout"
  ];

  virtualisation.docker.enable = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  services.ollama = {
    enable = true;
    environmentVariables = {
      OLLAMA_ORIGINS = "app://obsidian.md*";
    };
  };
}
