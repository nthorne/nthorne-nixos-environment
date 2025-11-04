{ config, pkgs, ... }:

let
  # This file contains non-public information.
  private = /etc/nixos/private.nix;
in
{
  imports = [ ] ++ (if builtins.pathExists private then [ private ] else [ ]);

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

  services.tailscale.enable = true;

  services.displayManager.autoLogin = {
    enable = true;
    user = "nthorne";
  };

  hardware.graphics.enable = true;
  #hardware.opengl.driSupport = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.alma = {
    isNormalUser = true;
    uid = 1001;
    extraGroups = ["wheel"];
    createHome = true;
    home = "/home/alma";
    shell = pkgs.zsh;

    packages = with pkgs; [
      ghostty
      firefox
      rofi
    ];
  };

  users.extraUsers.nthorne.extraGroups = [
    "wheel"
    "audio"
    "docker"
    "dialout"
  ];

  virtualisation.docker.enable = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
    accept-flake-config = true
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
