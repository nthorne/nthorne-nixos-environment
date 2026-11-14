{ pkgs, ... }:

let
  # This file contains non-public information.
  private = /etc/nixos/private.nix;
in
{
  imports = if builtins.pathExists private then [ private ] else [ ];

  networking.hostName = "nixlaptop"; # Define your hostname.

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

  services = {
    # Enable the OpenSSH daemon.
    openssh.enable = true;

    # greetd ignores services.displayManager.autoLogin; real autologin needs
    # services.greetd.settings.initial_session instead.

    blueman.enable = true;

    ollama = {
      enable = true;
      environmentVariables = {
        OLLAMA_ORIGINS = "app://obsidian.md*";
      };
    };
  };

  hardware.bluetooth.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alma = {
    isNormalUser = true;
    uid = 1001;
    extraGroups = [ "wheel" ];
    createHome = true;
    home = "/home/alma";
    shell = pkgs.zsh;

    packages = with pkgs; [
      ghostty
      firefox
      rofi
    ];
  };

  users.users.nthorne.extraGroups = [
    "audio"
    "dialout"
  ];

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
}
