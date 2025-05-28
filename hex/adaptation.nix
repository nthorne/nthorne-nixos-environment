{ ... }:

let
  # This file contains non-public information.
  private = /etc/nixos/private.nix;
in
{
  imports = [ ] ++ (if builtins.pathExists private then [ private ] else [ ]);

  networking.hostName = "hex"; # Define your hostname.
  networking.networkmanager.enable = true; # Enables wireless support via wpa_supplicant.

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

  services.tailscale.enable = true;

  hardware.graphics.enable = true;
  #hardware.opengl.driSupport = true;

  users.extraUsers.nthorne.extraGroups = [
    "wheel"
    "docker"
    "dialout"
  ];

  virtualisation = {
    podman = {
      enable = true;
    };
    docker.enable = true;
  };


  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
