{ config, pkgs, ... }:

let
  # This file contains non-public information.
  private = /etc/nixos/private.nix;

  #pidgin = pkgs.pidgin-with-plugins.override {
  #  plugins = [ pkgs.pidginsipe ];
  #};
in
{
  imports =
    [
    ] ++ (if builtins.pathExists private then [ private ] else []);

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
    #pidgin
    tmuxinator
    xdotool

    pkgs.pythonPackages.ipython
    pkgs.pythonPackages.pylint
    pkgs.pythonPackages.virtualenv

    (import ./cppclean)
    (import ./ntvim)

    # TODO: Can possibly drop this one.
    # Used in order to get deoplete up and running again, since
    # it requires a neovim python package that is not available
    # through Nix yet :/
    (python36.withPackages(ps: with ps; [ pip setuptools ]))
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
