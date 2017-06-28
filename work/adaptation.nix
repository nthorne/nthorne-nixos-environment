{ config, pkgs, ... }:

{
  imports =
    [
      # Corporate proxy derivation.
      ./proxy.nix

      # For Android development
      ./android_container/docker.nix
    ];

  networking.hostName = "nixos";

  # Virtualbox settings
  virtualisation.virtualbox.guest.enable = true;

  fileSystems."/virtualboxshare" = {
    fsType = "vboxsf";
    device = "transfer";
    options = [ "rw" ];
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    arandr
    bashdb
    ctags
    gitRepo  # For the repo command.
    lnav
    minicom
    tmuxinator
    xdotool

    pkgs.pythonPackages.ipython
    pkgs.pythonPackages.pylint
    pkgs.pythonPackages.virtualenv

    (import ./cppclean)
    (import ./ddoc)
    (import ./ntvim)
  ];

  services.udev.extraRules = ''
    # IHU
    SUBSYSTEM=="usb", ATTR{idVendor}=="8087", MODE="0666", GROUP="plugdev"
    '';

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.nthorne.extraGroups =[ "wheel" "vboxsf" "docker" "dialout" ];
}
